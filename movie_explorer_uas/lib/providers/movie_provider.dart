import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../services/movie_service.dart';

class MovieProvider extends ChangeNotifier {
  final MovieService _movieService = MovieService();

  List<MovieModel> _movies = [];
  List<MovieModel> _visibleMovies = [];
  bool _isLoading = false;
  bool _isFromCache = false;
  String _selectedGenre = 'All';
  String _searchQuery = '';
  String? _errorMessage;
  String? _lastCacheTime;

  List<MovieModel> get movies => _visibleMovies;
  bool get isLoading => _isLoading;
  bool get isFromCache => _isFromCache;
  String get selectedGenre => _selectedGenre;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get lastCacheTime => _lastCacheTime;

  List<String> get availableGenres {
    final genres = _movies.expand((movie) => movie.genres).toSet().toList();
    genres.sort();
    return ['All', ...genres];
  }

  Future<void> loadShows() async {
    _searchQuery = '';
    _errorMessage = null;

    final hasCache = await _showCacheFirst();
    if (!hasCache) {
      _setLoading(true);
    }

    try {
      final result = await _movieService.fetchShows();
      _movies = result;
      _isFromCache = false;
      _errorMessage = null;
      _lastCacheTime = await _movieService.getLastCacheTime();
      _applyFilter();
    } catch (_) {
      if (_movies.isNotEmpty) {
        _isFromCache = true;
        _errorMessage =
            'Data terbaru belum bisa dimuat. Aplikasi menampilkan data terakhir yang berhasil disimpan.';
        _applyFilter();
      } else {
        _movies = [];
        _visibleMovies = [];
        _isFromCache = false;
        _errorMessage =
            'Data belum tersedia. Periksa koneksi internet lalu coba kembali.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    _searchQuery = query.trim();
    _errorMessage = null;

    if (_searchQuery.isEmpty) {
      await loadShows();
      return;
    }

    _setLoading(true);

    try {
      final result = await _movieService.searchShows(_searchQuery);
      _movies = result;
      _isFromCache = false;
      _errorMessage = null;
      _lastCacheTime = await _movieService.getLastCacheTime();
      _applyFilter();
    } catch (_) {
      final cachedMovies = await _movieService.getCachedShows();
      _lastCacheTime = await _movieService.getLastCacheTime();

      if (cachedMovies.isNotEmpty) {
        _movies = cachedMovies;
        _isFromCache = true;
        _errorMessage =
            'Pencarian gagal karena koneksi bermasalah. Data terakhir tetap ditampilkan agar aplikasi masih bisa digunakan.';
        _applyFilter();
      } else {
        _movies = [];
        _visibleMovies = [];
        _isFromCache = false;
        _errorMessage =
            'Pencarian gagal. Periksa koneksi internet lalu coba kembali.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _showCacheFirst() async {
    final cachedMovies = await _movieService.getCachedShows();
    _lastCacheTime = await _movieService.getLastCacheTime();

    if (cachedMovies.isEmpty) {
      return false;
    }

    _movies = cachedMovies;
    _isFromCache = true;
    _applyFilter();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void filterByGenre(String genre) {
    _selectedGenre = genre;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedGenre == 'All') {
      _visibleMovies = List.from(_movies);
      return;
    }

    _visibleMovies = _movies
        .where((movie) => movie.genres.contains(_selectedGenre))
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

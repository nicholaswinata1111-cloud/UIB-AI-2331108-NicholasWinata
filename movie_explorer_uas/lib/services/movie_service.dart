import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie_model.dart';
import '../utils/app_constants.dart';

class MovieService {
  Future<List<MovieModel>> fetchShows() async {
    final uri = Uri.parse('${AppConstants.baseUrl}/shows?page=0');
    return _fetchList(uri);
  }

  Future<List<MovieModel>> searchShows(String query) async {
    final keyword = query.trim();
    if (keyword.isEmpty) {
      return fetchShows();
    }

    final uri = Uri.https('api.tvmaze.com', '/search/shows', {'q': keyword});
    return _fetchList(uri);
  }

  Future<List<MovieModel>> _fetchList(Uri uri) async {
    final response = await http.get(uri).timeout(AppConstants.requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Server returned status code ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid data format from API');
    }

    final movies = decoded
        .map((item) => MovieModel.fromTvMazeJson(item as Map<String, dynamic>))
        .where((movie) => movie.name.isNotEmpty)
        .toList();

    await saveCache(movies);
    return movies;
  }

  Future<void> saveCache(List<MovieModel> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final data = movies.map((movie) => movie.toJson()).toList();

    await prefs.setString(AppConstants.cacheKey, jsonEncode(data));
    await prefs.setString(
      AppConstants.cacheTimeKey,
      DateTime.now().toIso8601String(),
    );
  }

  Future<List<MovieModel>> getCachedShows() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(AppConstants.cacheKey);

    if (cachedData == null || cachedData.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(cachedData);
    if (decoded is! List) {
      return [];
    }

    return decoded
        .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getLastCacheTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.cacheTimeKey);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_provider.dart';
import '../widgets/custom_loading.dart';
import '../widgets/error_view.dart';
import '../widgets/genre_filter_chip.dart';
import '../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _initialLoadFuture;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = context.read<MovieProvider>().loadShows();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<MovieProvider>().searchMovies(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Movie Explorer'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh data',
            onPressed: () => context.read<MovieProvider>().loadShows(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          return Consumer<MovieProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  _HeaderSearch(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  _GenreFilter(provider: provider),
                  if (provider.errorMessage != null && provider.movies.isNotEmpty)
                    _InfoBanner(provider: provider),
                  Expanded(
                    child: _MovieContent(provider: provider),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HeaderSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _HeaderSearch({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find your favorite movie or series',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search movie title...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreFilter extends StatelessWidget {
  final MovieProvider provider;

  const _GenreFilter({required this.provider});

  @override
  Widget build(BuildContext context) {
    final genres = provider.availableGenres;

    return Container(
      height: 58,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          return GenreFilterChip(
            genre: genre,
            isSelected: genre == provider.selectedGenre,
            onSelected: () => context.read<MovieProvider>().filterByGenre(genre),
          );
        },
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final MovieProvider provider;

  const _InfoBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage ?? '',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieContent extends StatelessWidget {
  final MovieProvider provider;

  const _MovieContent({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const CustomLoading();
    }

    if (provider.errorMessage != null && provider.movies.isEmpty) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => context.read<MovieProvider>().loadShows(),
      );
    }

    if (provider.movies.isEmpty) {
      return ErrorView(
        message: 'Data tidak ditemukan. Coba gunakan kata kunci lain.',
        onRetry: () => context.read<MovieProvider>().loadShows(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: provider.movies.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: provider.movies[index]);
      },
    );
  }
}

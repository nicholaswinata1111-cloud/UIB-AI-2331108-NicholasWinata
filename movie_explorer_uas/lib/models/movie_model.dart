class MovieModel {
  final int id;
  final String name;
  final String imageUrl;
  final String summary;
  final List<String> genres;
  final double rating;
  final String language;
  final String status;

  const MovieModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.summary,
    required this.genres,
    required this.rating,
    required this.language,
    required this.status,
  });

  factory MovieModel.fromTvMazeJson(Map<String, dynamic> json) {
    final Map<String, dynamic> showJson =
        json.containsKey('show') && json['show'] is Map<String, dynamic>
            ? json['show'] as Map<String, dynamic>
            : json;

    final image = showJson['image'];
    final ratingData = showJson['rating'];

    return MovieModel(
      id: showJson['id'] ?? 0,
      name: showJson['name'] ?? 'Untitled',
      imageUrl: image is Map<String, dynamic>
          ? (image['medium'] ?? image['original'] ?? '')
          : '',
      summary: _cleanHtml(showJson['summary'] ?? 'No description available.'),
      genres: showJson['genres'] is List
          ? List<String>.from(showJson['genres'])
          : const [],
      rating: ratingData is Map<String, dynamic> && ratingData['average'] != null
          ? (ratingData['average'] as num).toDouble()
          : 0.0,
      language: showJson['language'] ?? 'Unknown',
      status: showJson['status'] ?? 'Unknown',
    );
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Untitled',
      imageUrl: json['imageUrl'] ?? '',
      summary: json['summary'] ?? 'No description available.',
      genres: json['genres'] is List ? List<String>.from(json['genres']) : const [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      language: json['language'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'summary': summary,
      'genres': genres,
      'rating': rating,
      'language': language,
      'status': status,
    };
  }

  static String _cleanHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }
}

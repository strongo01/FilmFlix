class MovieSearchItem {
  final String id;
  final String title;
  final int? year;
  final String? poster;
  final Map<String, dynamic> raw; 
final String? tmdbId; 

  MovieSearchItem({
    required this.id,
    required this.title,
    this.year,
    this.poster,
    required this.raw,
    this.tmdbId,
  });

  factory MovieSearchItem.fromJson(Map<String, dynamic> json) {
    return MovieSearchItem(
      id: json['imdbId'] ??
          json['id'] ??
          '',
      title: json['title'] ?? '',
      year: json['releaseYear'],
      poster: json['imageSet']?['verticalPoster']?['w240'],
      raw: json, 
      tmdbId: json['tmdbId'],
    );
  }
}

class MovieDetail {
  final Map<String, dynamic> rapid;
  final Map<String, dynamic>? omdb;
  final Map<String, dynamic>? supabase;

  MovieDetail({
    required this.rapid,
    this.omdb,
    this.supabase,
    
  });
}

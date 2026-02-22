class MovieSearchItem {
  //dit betekent dat er een movie search item is, en dat er een id, title, year, poster, raw data en tmdbId is. De raw data is de originele data van de API, en de tmdbId is de id van de film op TMDb.
  final String id;
  final String title;
  final int? year;
  final String? poster;
  final Map<String, dynamic> raw;
  final String? tmdbId;

  MovieSearchItem({ //dit zorgt voor een constructor voor de MovieSearchItem class, waarbij deid, title en raw data verplicht zijn, en de year, poster en tmdbId optioneel zijn.
    required this.id,
    required this.title,
    this.year,
    this.poster,
    required this.raw,
    this.tmdbId,
  });

  factory MovieSearchItem.fromJson(Map<String, dynamic> json) { //dit zorgt voor een factory constructor die een MovieSearchItem maakt van een JSON object. Hierbij wordt gekeken naar de id, title, year, poster en tmdbId in het JSON object, en worden deze gebruikt om een MovieSearchItem te maken.
    return MovieSearchItem( //dit maakt een MovieSearchItem aan met de id, title, year, poster, raw data en tmdbId uit het JSON object. Hierbij wordt gekeken naar de id, title, year, poster en tmdbId in het JSON object, en worden deze gebruikt om een MovieSearchItem te maken.
      id: json['imdbId'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      year: json['releaseYear'],
      poster: json['imageSet']?['verticalPoster']?['w240'],
      raw: json,
      tmdbId: json['tmdbId'],
    );
  }
}
//deze class is voor de details van een film, waarbij er een rapid data en een omdb data is. De rapid data is de originele data van de API, en de omdb data is de data van OMDb.
class MovieDetail {
  final Map<String, dynamic> rapid;
  final Map<String, dynamic>? omdb;
  MovieDetail({required this.rapid, this.omdb});
}

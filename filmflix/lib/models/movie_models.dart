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
  final dynamic rapid;
  final dynamic omdb;

  MovieDetail({this.rapid, this.omdb});
}

class Season {
  final String? title;
  final List<Episode> episodes;

  Season({this.title, this.episodes = const []});

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      title: json['title'] as String?,
      episodes: (json['episodes'] as List<dynamic>? ?? [])
          .map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}

class Episode {
  final String? title;
  final String? overview;
  final ImageSet? imageSet;

  Episode({this.title, this.overview, this.imageSet});

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      title: json['title'] as String?,
      overview: json['overview'] as String?,
      imageSet: json['imageSet'] != null
          ? ImageSet.fromJson(json['imageSet'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'overview': overview,
      'imageSet': imageSet?.toJson(),
    };
  }
}

class ImageSet {
  final VerticalPoster? verticalPoster;

  ImageSet({this.verticalPoster});

  factory ImageSet.fromJson(Map<String, dynamic> json) {
    return ImageSet(
      verticalPoster: json['verticalPoster'] != null
          ? VerticalPoster.fromJson(
              json['verticalPoster'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verticalPoster': verticalPoster?.toJson(),
    };
  }
}

class VerticalPoster {
  final String? w160;

  VerticalPoster({this.w160});

  factory VerticalPoster.fromJson(Map<String, dynamic> json) {
    return VerticalPoster(
      w160: json['w160'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'w160': w160,
    };
  }
}

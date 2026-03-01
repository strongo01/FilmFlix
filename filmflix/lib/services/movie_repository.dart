import '../models/movie_models.dart';
import 'movie_api.dart';

class MovieRepository { // Repository class die doet als een laag tussen de API helper (MovieApi) en de rest van de app. Deze klasse bevat functies die de API helper aanroepen, en kan ook extra logica bevatten zoals data transformatie, caching, of het combineren van meerdere API calls. In dit geval zijn er functies voor het zoeken naar films en het ophalen van volledige details van een film.
  // Search
  static Future<List<MovieSearchItem>> search(String query) async { // Deze functie voert een zoekopdracht uit naar films op basis van een query string. Het roept de search functie van MovieApi aan, en transformeert het resultaat in een lijst van MovieSearchItem objecten, die makkelijker te gebruiken zijn in de rest van de app.
    final data = await MovieApi.search(title: query);

    final results = data['results'] as List<dynamic>? ?? []; // De API response bevat meestal een 'results' veld met een lijst van zoekresultaten. We halen deze lijst op, en zorgen dat het altijd een lijst is (zelfs als er geen resultaten zijn, dan is het een lege lijst).

    return results.map((e) => MovieSearchItem.fromJson(e)).toList();
  }

  // Get full details by combining base and episodes
  static Future<MovieDetail> getFullMovie(String imdbId) async {
    // Roep beide functies parallel aan
    final results = await Future.wait([
      getMovieBaseDetails(imdbId),
      getMovieEpisodes(imdbId),
    ]);

    final movieDetail = results[0] as MovieDetail;
    final seasons = results[1] as List<Season>;

    // Voeg de seizoenen toe aan de rapid data van de movieDetail
    if (movieDetail.rapid != null && movieDetail.rapid is Map<String, dynamic>) {
      (movieDetail.rapid as Map<String, dynamic>)['seasons'] = seasons.map((s) => s.toJson()).toList();
    }

    return movieDetail;
  }

  // Get base details (RapidAPI + OMDb)
  static Future<MovieDetail> getMovieBaseDetails(String imdbId) async {
    final rapid = await MovieApi.getDetailsBase(id: imdbId);
    final omdb = await MovieApi.omdbGet(imdbId: imdbId, plot: 'full');

    return MovieDetail(rapid: rapid, omdb: omdb);
  }

  // Get episodes (RapidAPI)
  static Future<List<Season>> getMovieEpisodes(String imdbId) async {
    final data = await MovieApi.getDetailsEpisodes(id: imdbId);
    final seasons = (data['result']['seasons'] as List<dynamic>? ?? [])
        .map((e) => Season.fromJson(e))
        .toList();
    return seasons;
  }
}

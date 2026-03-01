import '../models/movie_models.dart';
import 'movie_api.dart';

class MovieRepository { // Repository class die doet als een laag tussen de API helper (MovieApi) en de rest van de app. Deze klasse bevat functies die de API helper aanroepen, en kan ook extra logica bevatten zoals data transformatie, caching, of het combineren van meerdere API calls. In dit geval zijn er functies voor het zoeken naar films en het ophalen van volledige details van een film.
  // Search
  static Future<List<MovieSearchItem>> search(String query) async { // Deze functie voert een zoekopdracht uit naar films op basis van een query string. Het roept de search functie van MovieApi aan, en transformeert het resultaat in een lijst van MovieSearchItem objecten, die makkelijker te gebruiken zijn in de rest van de app.
    final data = await MovieApi.search(title: query);

    final results = data['results'] as List<dynamic>? ?? []; // De API response bevat meestal een 'results' veld met een lijst van zoekresultaten. We halen deze lijst op, en zorgen dat het altijd een lijst is (zelfs als er geen resultaten zijn, dan is het een lege lijst).

    return results.map((e) => MovieSearchItem.fromJson(e)).toList();
  }

  // Get full details (RapidAPI + OMDb)
  static Future<MovieDetail> getFullMovie(String imdbId) async {
    // Fetch both show- and episode-granularity in parallel, plus OMDb.
    final showFuture = getRapidDetailsShow(imdbId);
    final episodeFuture = getRapidDetailsEpisode(imdbId);
    final omdbFuture = MovieApi.omdbGet(imdbId: imdbId, plot: 'full');

    // Wait for both rapid responses and OMDb; prefer episode data for final return if available.
    final results = await Future.wait([showFuture, episodeFuture, omdbFuture]);

    final showRapid = results[0] as Map<String, dynamic>?;
    final episodeRapid = results[1] as Map<String, dynamic>?;
    final omdb = results[2] as Map<String, dynamic>?;

    final rapid = episodeRapid ?? showRapid ?? <String, dynamic>{};

    print("IMDB ID: $imdbId");
    print("OMDB RESPONSE: $omdb");

    return MovieDetail(rapid: rapid, omdb: omdb);
  }

  // Rapid detail helpers (separate granularity)
  static Future<Map<String, dynamic>> getRapidDetailsShow(String imdbId) {
    return MovieApi.getDetails(id: imdbId, seriesGranularity: 'show');
  }

  static Future<Map<String, dynamic>> getRapidDetailsEpisode(String imdbId) {
    return MovieApi.getDetails(id: imdbId, seriesGranularity: 'episode');
  }
}
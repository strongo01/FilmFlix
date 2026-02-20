import '../models/movie_models.dart';
import 'movie_api.dart';

class MovieRepository {

  // 🔍 Search
  static Future<List<MovieSearchItem>> search(String query) async {
    final data = await MovieApi.search(title: query);

    final results = data['result'] as List<dynamic>? ?? [];

    return results
        .map((e) => MovieSearchItem.fromJson(e))
        .toList();
  }

  // 🎬 Get ALL details automatically
static Future<MovieDetail> getFullMovie(String imdbId) async {

  final rapid = await MovieApi.getDetails(id: imdbId);
  final omdb = await MovieApi.omdbGet(
    imdbId: imdbId,
    plot: 'full',
  );
  final supabase = await MovieApi.supabaseTitles(
    tconst: imdbId,
  );

  print("IMDB ID: $imdbId");
  print("OMDB RESPONSE: $omdb");

  return MovieDetail(
    rapid: rapid,
    omdb: omdb,
    supabase: supabase,
  );
}
}
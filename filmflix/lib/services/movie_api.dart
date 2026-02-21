import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApi {
  static const String _baseUrl =
      'https://film-flix-olive.vercel.app/api/movies';

  /// Algemene GET helper
  static Future<Map<String, dynamic>> _get(
      Map<String, dynamic> params) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List<dynamic>) {
        return {'result': decoded};
      }
      // fallback: wrap other types
      return {'result': [decoded]};
    } else {
      throw Exception('API error: ${response.body}');
    }
  }

  // 🔍 SEARCH (RapidAPI)
  static Future<Map<String, dynamic>> search({
    required String title,
    String country = 'nl',
    String showType = '',
    String outputLanguage = 'en',
  }) {
    return _get({
      'type': 'search',
      'title': title,
      'country': country,
      'show_type': showType.isEmpty ? null : showType,
      'output_language': outputLanguage,
    });
  }

  // 🎬 GET DETAILS (RapidAPI)
  static Future<Map<String, dynamic>> getDetails({
    required String id,
    String outputLanguage = 'en',
  }) {
    return _get({
      'type': 'get',
      'id': id,
      'output_language': outputLanguage,
      'series_granularity': 'episode', 
    });
  }

  // 🎯 FILTER (RapidAPI)
  static Future<Map<String, dynamic>> filter({
    String country = 'nl',
    int ratingMin = 0,
    int ratingMax = 100,
    String? genres,
    String? catalogs,
    int? yearMin,
    int? yearMax,
    String? orderBy,
  }) {
    return _get({
      'type': 'filter',
      'country': country,
      'rating_min': ratingMin,
      'rating_max': ratingMax,
      'genres': genres,
      'catalogs': catalogs,
      'year_min': yearMin,
      'year_max': yearMax,
      'order_by': orderBy,
    });
  }

  // 📚 OMDB GET (by imdb id OR title)
  static Future<Map<String, dynamic>> omdbGet({
    String? imdbId,
    String? title,
    String plot = 'short',
  }) {
    return _get({
      'type': 'omdb-get',
      'i': imdbId,
      't': title,
      'plot': plot,
    });
  }

  // 🔎 OMDB SEARCH
  static Future<Map<String, dynamic>> omdbSearch({
    required String searchTitle,
    int page = 1,
  }) {
    return _get({
      'type': 'omdb-search',
      's': searchTitle,
      'page': page,
    });
  }
}
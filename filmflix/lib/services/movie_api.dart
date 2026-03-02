import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApi { //  API Helper class voor alle movie-gerelateerde API calls
  static const String _baseUrl =
      'https://film-flix-olive.vercel.app/api/movies';

  // Algemene GET helper die alle API calls afhandelt. Deze functie bouwt de URL op basis van de meegegeven parameters, maakt de HTTP GET request, en decodeert het JSON antwoord. Het resultaat is altijd een Map<String, dynamic>, waarbij de daadwerkelijke data meestal in een 'result' veld zit.
  static Future<Map<String, dynamic>> _get(Map<String, dynamic> params) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: params.map(
        (key, value) => MapEntry(key, value?.toString()), // Zorgt dat alle parameters als strings worden toegevoegd, en dat null waarden worden genegeerd
      ),
    );

    final response = await http.get(uri); // Maakt de HTTP GET request naar de API

    if (response.statusCode == 200) { // Als de response succesvol is, decodeer het JSON antwoord
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List<dynamic>) {
        return {'result': decoded}; // Sommige API endpoints kunnen een lijst teruggeven, dus we wrappen dit in een 'result' veld voor consistentie
      }
      // Als het antwoord niet het verwachte formaat heeft, gooien we een fout
      return {
        'result': [decoded],
      };
    } else {
      throw Exception('API error: ${response.body}');
    }
  }

  //  SEARCH (RapidAPI)
  static Future<Map<String, dynamic>> search({
    required String title,
    String country = 'nl',
    String showType = '',
    String outputLanguage = 'en',
  }) {
    return _get({ // Deze functie maakt een zoekopdracht naar films/series op basis van de titel en andere optionele parameters zoals land, type (film/serie), en output taal. De parameters worden doorgegeven aan de _get helper, die de daadwerkelijke API call maakt.
      'type': 'search',
      'title': title,
      'country': country,
      'show_type': showType.isEmpty ? null : showType,
      'output_language': outputLanguage,
    });
  }

  // DETAILS (RapidAPI)
  static Future<Map<String, dynamic>> getDetails({
    required String id,
    String outputLanguage = 'en',
    String seriesGranularity = 'episode',
  }) {
    return _get({
      'type': 'get',
      'id': id,
      'output_language': outputLanguage,
      'series_granularity': seriesGranularity,
    });
  }

  // FILTER (RapidAPI)
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

  //  OMDB GET
  static Future<Map<String, dynamic>> omdbGet({
    String? imdbId,
    String? title,
    String plot = 'short',
  }) {
    return _get({'type': 'omdb-get', 'i': imdbId, 't': title, 'plot': plot});
  }

  // OMDB SEARCH
  static Future<Map<String, dynamic>> omdbSearch({
    required String searchTitle,
    int page = 1,
  }) {
    return _get({'type': 'omdb-search', 's': searchTitle, 'page': page});
  }
}
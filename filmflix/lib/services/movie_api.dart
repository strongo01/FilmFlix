import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class MovieApi {
  //  API Helper class voor alle movie-gerelateerde API calls
  static const String _baseUrl =
      'https://film-flix-olive.vercel.app/apiv2/movies';

  // Algemene GET helper die alle API calls afhandelt. Deze functie bouwt de URL op basis van de meegegeven parameters, maakt de HTTP GET request, en decodeert het JSON antwoord. Het resultaat is altijd een Map<String, dynamic>, waarbij de daadwerkelijke data meestal in een 'result' veld zit.
  static Future<Map<String, dynamic>> _get(Map<String, dynamic> params) async {
    await _ensureEnvLoaded();
    final cleanParams = Map<String, dynamic>.from(params);
    cleanParams.removeWhere(
      (key, value) => value == null || value.toString().isEmpty,
    );

    // Handle cursor separately to avoid double-encoding
    String? cursor;
    if (cleanParams.containsKey('cursor')) {
      cursor = cleanParams.remove('cursor');
    }

    var uri = Uri.parse(_baseUrl).replace(
      queryParameters: cleanParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    if (cursor != null) {
      final String connector = uri.query.isEmpty ? '?' : '&';
      uri = Uri.parse(
        '${uri.toString()}${connector}cursor=${Uri.encodeComponent(cursor)}',
      );
    }

    debugPrint('API GET Request: $uri');
    debugPrint('Final API GET Request URL: $uri');
    final headers = <String, String>{};
    if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) {
      headers['x-app-api-key'] = _xAppApiKey!;
    }

    final response = await http.get(uri, headers: headers);
    // Uncomment the following lines to debug the response if needed
    // final response = await http.get(uri);
    debugPrint('API Response status: ${response.statusCode}');
    //debugPrint('API Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Als de response succesvol is, decodeer het JSON antwoord
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is List<dynamic>) {
        return {
          'result': decoded,
        }; // Sommige API endpoints kunnen een lijst teruggeven, dus we wrappen dit in een 'result' veld voor consistentie
      }
      // Als het antwoord niet het verwachte formaat heeft, gooien we een fout
      return {
        'result': [decoded],
      };
    } else {
      throw Exception('API error: ${response.body}');
    }
  }

  static String? _xAppApiKey;

  static Future<void> _ensureEnvLoaded() async {
    if (_xAppApiKey != null) return;
    try {
      final content = await rootBundle.loadString('assets/env/.env');
      final lines = const LineSplitter().convert(content);
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final idx = trimmed.indexOf('=');
        if (idx <= 0) continue;
        final key = trimmed.substring(0, idx).trim();
        final value = trimmed.substring(idx + 1).trim();
        if (key == 'X_APP_API_KEY') {
          _xAppApiKey = value;
          break;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      if (kDebugMode) print('Failed to load .env: $e');
    }
  }

  //  SEARCH (RapidAPI)
  static Future<Map<String, dynamic>> search({
    required String title,
    String country = 'nl',
    String showType = '',
    String outputLanguage = 'en',
  }) {
    return _get({
      // Deze functie maakt een zoekopdracht naar films/series op basis van de titel en andere optionele parameters zoals land, type (film/serie), en output taal. De parameters worden doorgegeven aan de _get helper, die de daadwerkelijke API call maakt.
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
    String? orderDirection,
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
      'order_direction': orderDirection,
    });
  }

  // Advanced filter wrapper that exposes more of the Rapid filters
  static Future<Map<String, dynamic>> filterAdvanced({
    String country = 'nl',
    String? seriesGranularity,
    String outputLanguage = 'en',
    String? showType,
    int? ratingMin,
    int? ratingMax,
    String? catalogs,
    String? genres,
    String? genresRelation,
    String? keyword,
    String? showOriginalLanguage,
    int? yearMin,
    int? yearMax,
    String? orderBy,
    String? orderDirection,
    String? cursor,
  }) {
    return _get({
      'type': 'filter',
      'country': country,
      'series_granularity': seriesGranularity,
      'output_language': outputLanguage,
      'show_type': showType,
      'rating_min': ratingMin,
      'rating_max': ratingMax,
      'catalogs': catalogs,
      'genres': genres,
      'genres_relation': genresRelation,
      'keyword': keyword,
      'show_original_language': showOriginalLanguage,
      'year_min': yearMin,
      'year_max': yearMax,
      'order_by': orderBy,
      'order_direction': orderDirection,
      'cursor': cursor,
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

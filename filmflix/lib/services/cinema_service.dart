import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _kCachedCinemasKey = 'cached_cinemas_v1';

Future<List<Map<String, dynamic>>> fetchCinemasFromOverpass() async {
  final query = '''
[out:json][timeout:25];
( 
  node["amenity"="cinema"](50.5,3.3,53.7,7.2);
  way["amenity"="cinema"](50.5,3.3,53.7,7.2);
  relation["amenity"="cinema"](50.5,3.3,53.7,7.2);
);
out center;
''';

  final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
  final resp = await http.get(url);
  if (resp.statusCode != 200) {
    throw Exception('Overpass error: ${resp.statusCode}');
  }

  final data = json.decode(resp.body) as Map<String, dynamic>;
  final elems = data['elements'] as List<dynamic>? ?? [];
  final cinemas = <Map<String, dynamic>>[];

  for (final e in elems) {
    final Map<String, dynamic> elem = Map<String, dynamic>.from(e as Map);
    double? lat;
    double? lon;
    if (elem.containsKey('lat') && elem.containsKey('lon')) {
      lat = (elem['lat'] as num).toDouble();
      lon = (elem['lon'] as num).toDouble();
    } else if (elem.containsKey('center')) {
      final center = elem['center'] as Map<String, dynamic>?;
      if (center != null && center['lat'] != null && center['lon'] != null) {
        lat = (center['lat'] as num).toDouble();
        lon = (center['lon'] as num).toDouble();
      }
    }

    if (lat == null || lon == null) continue;

    String name = 'Onbekend';
    if (elem.containsKey('tags')) {
      final tags = Map<String, dynamic>.from(elem['tags'] as Map);
      if (tags.containsKey('name')) name = tags['name'] as String;
      else if (tags.containsKey('operator')) name = tags['operator'] as String;
      // Extract website if available
      String? website;
      if (tags.containsKey('website')) website = tags['website'] as String;
      else if (tags.containsKey('url')) website = tags['url'] as String;
      else if (tags.containsKey('contact:website')) website = tags['contact:website'] as String;
      cinemas.add({'name': name, 'lat': lat, 'lng': lon, 'website': website});
      continue;
    }

    cinemas.add({'name': name, 'lat': lat, 'lng': lon, 'website': null});
  }

  return cinemas;
}

Future<void> cacheCinemas(List<Map<String, dynamic>> cinemas) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kCachedCinemasKey, json.encode(cinemas));
}

Future<List<Map<String, dynamic>>> loadCachedCinemas() async {
  final prefs = await SharedPreferences.getInstance();
  final s = prefs.getString(_kCachedCinemasKey);
  if (s == null) return [];
  try {
    final List<dynamic> decoded = json.decode(s) as List<dynamic>;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    return [];
  }
}

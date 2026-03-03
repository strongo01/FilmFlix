import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const _kCachedCinemasKey = 'cached_cinemas_v1';

Future<List<Map<String, dynamic>>> fetchCinemasFromOverpass() async {
  // Switched to Nominatim search for 'cinema' within the same bbox.
  // BBox from previous Overpass query: south, west, north, east = 50.5,3.3,53.7,7.2
  final bboxMinLon = 3.3;
  final bboxMinLat = 50.5;
  final bboxMaxLon = 7.2;
  final bboxMaxLat = 53.7;

  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'q': 'cinema',
    'format': 'json',
    'limit': '200',
    'viewbox': '$bboxMinLon,$bboxMinLat,$bboxMaxLon,$bboxMaxLat',
    'bounded': '1',
    'extratags': '1',
    'namedetails': '1',
  });

  final resp = await http.get(uri, headers: {
    'User-Agent': 'filmflix_app',
    'Accept': 'application/json',
  }).timeout(const Duration(seconds: 30));

  if (resp.statusCode != 200) throw Exception('Nominatim error: ${resp.statusCode}');

  final List<dynamic> elems = json.decode(resp.body) as List<dynamic>;
  final cinemas = <Map<String, dynamic>>[];

  for (final e in elems) {
    final Map<String, dynamic> elem = Map<String, dynamic>.from(e as Map);
    double? lat;
    double? lon;
    // Nominatim returns lat/lon as strings; handle both string and numeric.
    if (elem.containsKey('lat') && elem.containsKey('lon')) {
      final latVal = elem['lat'];
      final lonVal = elem['lon'];
      if (latVal is String) lat = double.tryParse(latVal);
      else if (latVal is num) lat = latVal.toDouble();

      if (lonVal is String) lon = double.tryParse(lonVal);
      else if (lonVal is num) lon = lonVal.toDouble();
    }

    if (lat == null || lon == null) continue;

    String name = 'Onbekend';
    String? website;

    // Nominatim may provide namedetails and extratags
    if (elem.containsKey('namedetails') && elem['namedetails'] is Map) {
      final named = Map<String, dynamic>.from(elem['namedetails'] as Map);
      if (named.containsKey('name')) name = named['name'] as String;
    }

    if (elem.containsKey('extratags') && elem['extratags'] is Map) {
      final tags = Map<String, dynamic>.from(elem['extratags'] as Map);
      if (tags.containsKey('name')) name = tags['name'] as String;
      if (tags.containsKey('website')) website = tags['website'] as String;
      else if (tags.containsKey('url')) website = tags['url'] as String;
    }

    // Fall back to display_name
    if ((name == 'Onbekend' || name.isEmpty) && elem.containsKey('display_name')) {
      final dn = elem['display_name'] as String;
      name = dn.split(',').first.trim();
    }

    cinemas.add({'name': name, 'lat': lat, 'lng': lon, 'website': website});
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

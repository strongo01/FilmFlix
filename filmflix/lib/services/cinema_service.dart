import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

const _kCachedCinemasKey = 'cached_cinemas_v1';

Future<List<Map<String, dynamic>>> fetchCinemasFromOverpass() async {
  // Load local GeoJSON asset instead of fetching from Overpass API.
  final s = await rootBundle.loadString('assets/kaart/export.geojson');
  final data = json.decode(s) as Map<String, dynamic>;
  final features = data['features'] as List<dynamic>? ?? [];
  final cinemas = <Map<String, dynamic>>[];

  for (final f in features) {
    final Map<String, dynamic> feat = Map<String, dynamic>.from(f as Map);
    double? lat;
    double? lon;

    final geometry = feat['geometry'] as Map<String, dynamic>?;
    if (geometry != null && geometry['type'] == 'Point' && geometry['coordinates'] is List) {
      final coords = (geometry['coordinates'] as List).map((e) => e as num).toList();
      if (coords.length >= 2) {
        lon = coords[0].toDouble();
        lat = coords[1].toDouble();
      }
    }

    if (lat == null || lon == null) continue;

    String name = 'Onbekend';
    String? website;
    final props = feat['properties'] as Map<String, dynamic>?;
    if (props != null) {
      if (props.containsKey('name')) name = props['name']?.toString() ?? name;
      else if (props.containsKey('operator')) name = props['operator']?.toString() ?? name;

      if (props.containsKey('website')) website = props['website']?.toString();
      else if (props.containsKey('url')) website = props['url']?.toString();
      else if (props.containsKey('contact:website')) website = props['contact:website']?.toString();
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

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CinemasMapView extends StatelessWidget {
  const CinemasMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // ←←← HIER ALLE BIOSCOOPEN TOEVOEGEN ←←←
    // Je kunt coördinaten makkelijk vinden via Google Maps:
    // Rechtsklik op de bioscoop → "Wat is hier?" → kopieer lat, lng
    final List<Map<String, dynamic>> cinemas = [
      {'name': 'Pathé Tuschinski', 'lat': 52.3665, 'lng': 4.8960},
      {'name': 'Pathé De Munt', 'lat': 52.3678, 'lng': 4.8935},
      {'name': 'Pathé Arena', 'lat': 52.3100, 'lng': 4.9365},
      {'name': 'Vue Amsterdam', 'lat': 52.3105, 'lng': 4.9360},
      {'name': 'Vue Alkmaar', 'lat': 52.6350, 'lng': 4.7530},
      {'name': 'Vue Alphen aan den Rijn', 'lat': 52.1300, 'lng': 4.6550},
      {'name': 'Vue Amersfoort', 'lat': 52.1550, 'lng': 5.3850},
      {'name': 'Kinepolis Almere', 'lat': 52.3750, 'lng': 5.2200},
      {'name': 'Pathé Rotterdam', 'lat': 51.9200, 'lng': 4.4800},
      {'name': 'Kinepolis Breda', 'lat': 51.5900, 'lng': 4.7800},
      {'name': 'Pathé Utrecht', 'lat': 52.0900, 'lng': 5.1100},
      {'name': 'Vue Groningen', 'lat': 53.2100, 'lng': 6.5600},
      // Voeg hier alle andere bioscopen toe (er zijn ±200 in NL)
      // Voorbeeld extra:
      // {'name': 'Filmhuis Den Haag', 'lat': 52.0800, 'lng': 4.3100},
    ];

    final markers = cinemas.map((cinema) {
      return Marker(
        point: LatLng(cinema['lat'] as double, cinema['lng'] as double),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(cinema['name']),
                content: const Text('Bioscoop gevonden! 🎥'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alle bioscopen in Nederland'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(52.15, 5.3), // Midden van Nederland
          initialZoom: 7.5,
          minZoom: 6,
          maxZoom: 18,
        ),
        children: [
          // Gratis OpenStreetMap tegels
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'nl.bioscopen.app',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Eventueel later: zoom naar gebruiker locatie of filter
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zoom uit of in om alle bioscopen te zien')),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
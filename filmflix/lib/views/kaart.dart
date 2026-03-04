import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cinetrackr/services/cinema_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class CinemasMapView extends StatefulWidget {
  const CinemasMapView({super.key});

  @override
  State<CinemasMapView> createState() => _CinemasMapViewState();
}

class _CinemasMapViewState extends State<CinemasMapView> {
  bool _loading = true;
  List<Map<String, dynamic>> _cinemas = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    // First load cached cinemas (if any) to show immediate results
    try {
      final cached = await loadCachedCinemas();
      if (cached.isNotEmpty) {
        setState(() {
          _cinemas = cached;
          _loading = false;
        });
      }

      // Then fetch fresh data and update cache+UI
      final results = await fetchCinemasFromOverpass();
      await cacheCinemas(results);
      setState(() {
        _cinemas = results;
        _loading = false;
      });
    } catch (e) {
      if (mounted && _cinemas.isEmpty) {
        setState(() => _loading = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij laden bioscopen: $e')),
      );
    }
  }

  Future<void> _goToUserLocation() async {
    final contextMounted = mounted;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locatiedienst is uitgeschakeld')));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locatie toegang geweigerd')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Locatiepermissies permanent geweigerd. Schakel in instellingen.')));
      return;
    }

    try {
      if (contextMounted) setState(() => _loading = true);
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
    } catch (e) {
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kon locatie niet ophalen: $e')));
    } finally {
      if (contextMounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = _cinemas.map((cinema) {
      return Marker(
        point: LatLng(cinema['lat'] as double, cinema['lng'] as double),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () async {
            final website = cinema['website'] as String?;
            if (website != null && website.isNotEmpty) {
              var uri = Uri.tryParse(website);
              if (uri == null || uri.scheme.isEmpty) {
                uri = Uri.tryParse('https://$website');
              }
              if (uri != null) {
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return;
                } catch (_) {
                  // fallthrough to dialog
                }
              }
            }

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(cinema['name'] ?? 'Onbekend'),
                content: const Text('Geen website beschikbaar — Bioscoop gevonden! 🎥'),
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
        backgroundColor: const Color.fromARGB(255, 49, 225, 244),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
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
        onPressed: _goToUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
import 'package:flutter/material.dart'; // Importeert Flutter's Material Design componenten
import 'package:flutter_map/flutter_map.dart'; // Importeert de kaartweergave bibliotheek
import 'package:latlong2/latlong.dart'; // Importeert de LatLng klasse voor coördinaten
import 'package:cinetrackr/services/cinema_service.dart'; // Importeert de cinema-service voor dataloading
import 'package:url_launcher/url_launcher.dart'; // Importeert de bibliotheek om URLs te openen
import 'package:geolocator/geolocator.dart'; // Importeert de locatieservice voor GPS
import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeert de meertalenondersteuning
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeert de custom top bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Importeert de custom achtergrond widget

class CinemasMapView extends StatefulWidget { // Definieert een stateful widget voor de kaartweergave
  const CinemasMapView({super.key}); // Constructor met optionele key parameter

  @override
  State<CinemasMapView> createState() => _CinemasMapViewState(); // Maakt de state klasse aan
}

class _CinemasMapViewState extends State<CinemasMapView> { // State klasse met mutable data
  bool _loading = true; // Boolean voor laadstatus
  List<Map<String, dynamic>> _cinemas = []; // Lijst met cinema-gegevens
  final MapController _mapController = MapController(); // Controller voor kaartbewegingen
  final Color movieBlue = const Color.fromRGBO(43, 77, 91, 1); // Definieert een blauwe kleur constante
  bool _initialized = false; // Boolean om eenmalige initialisatie te controleren
  
  @override
  void initState() { // Initialisatiemethode die eenmalig wordt aangeroepen
    super.initState(); // Roept de parent initState aan
  }

  @override
  void didChangeDependencies() { // Wordt aangeroepen wanneer dependencies veranderen
    super.didChangeDependencies(); // Roept de parent didChangeDependencies aan
    if (!_initialized) { // Controleert of dit al eerder is gedaan
      _initialized = true; // Markeert als geïnitialiseerd
      _loadCinemas(); // Laadt de cinemalijst
    }
  }

  Future<void> _loadCinemas() async { // Asynchrone methode om cinemas te laden
    final loc = AppLocalizations.of(context)!; // Haalt de taalvertaalhulp op
    try { // Start een try-catch block voor foutafhandeling
      final cached = await loadCachedCinemas(); // Laadt cinemas uit de cache
      if (cached.isNotEmpty) { // Controleert of er gecachte data is
        setState(() { // Gebruikt setState om de UI bij te werken
          _cinemas = cached; // Stelt de cinemas in op gecachte waarden
          _loading = false; // Zet laadstatus op false
        });
      }

      final results = await fetchCinemasFromOverpass(); // Haalt verse cinemagevens op van Overpass
      await cacheCinemas(results); // Slaat de nieuwe gegevens op in cache
      setState(() { // Gebruikt setState om de UI bij te werken
        _cinemas = results; // Stelt de cinemas in op verse gegevens
        _loading = false; // Zet laadstatus op false
      });
    } catch (e) { // Vangt eventuele exceptions
      if (mounted && _cinemas.isEmpty) { // Controleert of widget nog bestaat en geen cinemas zijn geladen
        setState(() => _loading = false); // Zet laadstatus op false
      }
      ScaffoldMessenger.of(context).showSnackBar( // Toont een snackbar met foutmelding
        SnackBar(content: Text(loc.map_load_error(e.toString()))), // Weergeeft de foutmelding
      );
    }
  }

  Future<void> _goToUserLocation() async { // Asynchrone methode om naar gebruikerslocatie te gaan
    final contextMounted = mounted; // Slaat op of de widget nog bestaat
    final loc = AppLocalizations.of(context)!; // Haalt de taalvertaalhulp op
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled(); // Controleert of locatieservice ingeschakeld is
    if (!serviceEnabled) { // Als locatieservice niet ingeschakeld is
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.map_location_service_disabled))); // Toont waarschuwing
      return; // Beëindigt de methode
    }

    LocationPermission permission = await Geolocator.checkPermission(); // Controleert huidige locatiemachtiging
    if (permission == LocationPermission.denied) { // Als machtiging geweigerd is
      permission = await Geolocator.requestPermission(); // Vraagt machtiging aan gebruiker
      if (permission == LocationPermission.denied) { // Als gebruiker weigert
        if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.map_location_permission_denied))); // Toont waarschuwing
        return; // Beëindigt de methode
      }
    }

    if (permission == LocationPermission.deniedForever) { // Als machtiging permanent geweigerd is
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.map_location_permission_denied_forever))); // Toont waarschuwing
      return; // Beëindigt de methode
    }

    try { // Start een try-catch block voor foutafhandeling
      if (contextMounted) setState(() => _loading = true); // Zet laadstatus op true
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best); // Haalt huidige positie op
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0); // Beweegt de kaart naar gebruikerslocatie
    } catch (e) { // Vangt eventuele exceptions
      if (contextMounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.map_location_fetch_error(e.toString())))); // Toont foutmelding
    } finally { // Code die altijd wordt uitgevoerd
      if (contextMounted) setState(() => _loading = false); // Zet laadstatus op false
    }
  }

  @override
  Widget build(BuildContext context) { // Bouwt de UI
    final loc = AppLocalizations.of(context)!; // Haalt de taalvertaalhulp op

    final markers = _cinemas.map((cinema) { // Creëert markers voor iedere cinema
      return Marker( // Definieert een kaartmarker
        point: LatLng(cinema['lat'] as double, cinema['lng'] as double), // Stelt coördinaten in
        width: 50, // Breedte van marker
        height: 50, // Hoogte van marker
        child: GestureDetector( // Maakt marker taps gevoelig
          onTap: () async { // Handelaar voor taps op marker
            final website = cinema['website'] as String?; // Haalt website van cinema op
            if (website != null && website.isNotEmpty) { // Controleert of website bestaat
              var uri = Uri.tryParse(website); // Probeert website als URI te parsen
              if (uri == null || uri.scheme.isEmpty) { // Als parsing mislukt of geen protocol
                uri = Uri.tryParse('https://$website'); // Voegt https:// toe
              }
              if (uri != null) { // Als URI valid is
                try { // Probeert URL te openen
                  await launchUrl(uri, mode: LaunchMode.externalApplication); // Opent URL in externe app
                  return; // Beëindigt het taphandelaar
                } catch (_) { // Als openen mislukt
                  // fallthrough to dialog
                }
              }
            }

            showDialog( // Toont dialoogvenster
              context: context, // Context van de dialoog
              builder: (_) => AlertDialog( // Maakt een AlertDialog
                title: Text(cinema['name'] ?? loc.unknown), // Titel met cinémanaam
                content: Text(loc.map_no_website_content), // Inhoud van dialoog
                actions: [ // Actieknoppen
                  TextButton( // Definieert een tekstknop
                    onPressed: () => Navigator.pop(context), // Sluit dialoog
                    child: Text(loc.ok), // Knoptekst
                  ),
                ],
              ),
            );
          },
          child: const Icon( // Icoon voor marker
            Icons.location_on, // Locatiepinpictogram
            color: Colors.red, // Rode kleur
            size: 40, // Grootte van icoon
          ),
        ),
      );
    }).toList(); // Converteert map iterator naar lijst

    return AppBackground( // Wrapper voor app-achtergrond
      child: Scaffold( // Hoofdscherm-widget
        backgroundColor: Colors.transparent, // Transparante achtergrond
        appBar: PreferredSize( // Custom AppBar met aangegeven grootte
          preferredSize: const Size.fromHeight(56), // Hoogte van 56 pixels
          child: AppTopBar( // Custom top bar widget
            title: loc.map_all_cinemas_title, // Titel van de pagina
            backgroundColor: Colors.transparent, // Transparante achtergrond
          ),
        ),
        body: _loading // Controleert laadstatus
          ? const Center(child: CircularProgressIndicator()) // Toont laadwiel als aan het laden
          : FlutterMap( // Toont kaart als geladen
              mapController: _mapController, // Controller voor kaart
              options: const MapOptions( // Instellingen voor kaart
                initialCenter: LatLng(52.15, 5.3), // Beginpositie in het midden van Nederland
                initialZoom: 7.5, // Zoomniveau bij starten
                minZoom: 6, // Minimale inzooming
                maxZoom: 18, // Maximale inzooming
              ),
              children: [ // Lagen van de kaart
                TileLayer( // Tegellaag voor kaartachtergrond
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OpenStreetMap tegels
                  userAgentPackageName: 'nl.bioscopen.app', // User-agent pakket naam
                ),
                MarkerLayer(markers: markers), // Laag met cinemamarkers
              ],
            ),
        floatingActionButton: FloatingActionButton( // Ronde actieknop
          onPressed: _goToUserLocation, // Gaat naar gebruikerslocatie
          child: const Icon(Icons.my_location), // Locatiepictogram
        ),
      ),
    );
  }
}

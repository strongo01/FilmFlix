import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinetrackr/views/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinetrackr/services/movie_repository.dart';
import 'package:http/http.dart' as http;

class MovieDetailScreen extends StatefulWidget {
  // Deze screen toont de details van een specifieke film. We verwachten een imdbId als parameter, die we gebruiken om de details van de film op te halen via onze MovieRepository. In deze screen tonen we informatie zoals de poster, titel, overzicht, genres, cast, en streaming opties. We hebben ook functionaliteit voor gebruikers om films aan hun watchlist toe te voegen en om te markeren welke afleveringen ze hebben gezien (voor series). We gebruiken Firebase Authentication om gebruikers te identificeren, en Firestore om hun watchlist en seen episodes op te slaan.
  final String imdbId;

  const MovieDetailScreen({super.key, required this.imdbId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  static const Map<String, String> _serviceAssetMap = {
    // Deze map bevat een mapping van streaming service namen naar de corresponderende asset bestandsnamen voor hun logo's. We gebruiken deze map om het juiste logo te tonen voor elke streaming optie die we van de API krijgen. De keys in deze map zijn de mogelijke waarden van 'serviceName' die we in de streaming opties kunnen tegenkomen, en de values zijn de bestandsnamen van de logo
    'Netflix': 'netflix',
    'Amazon Prime Video': 'prime_video',
    'Prime Video': 'prime_video',
    'Disney+': 'disney+',
    'HBO Max': 'hbo_max',
    'Hulu': 'hulu',
    'Apple TV': 'apple_tv',
    'Google Play': 'googleplay',
    'YouTube': 'youtube',
    'Crunchyroll': 'crunchyroll',
    'Curiosity Stream': 'curiosity_stream',
    'Mejane': 'mejane',
    'MUBI': 'mubi',
    'SkyShowtime': 'skyshowtime',
    'Zee5': 'zee5',
  };

  Map<String, dynamic>? _rapidData;
  Map<String, dynamic>? _omdbData;
  String? _poster;
  String? _title;
  String? _overview;
  String? _rating;
  List<String> _genres = [];
  List<String> _creators = [];
  List<String> _cast = [];
  List<dynamic> _seasons = [];
  List<dynamic> _streaming = [];
  bool _loadingMovie = true;
  String? _error;
  String? _rated;

  Map<String, String> _translatedTexts = {};
  Map<String, bool> _isTranslating = {};

  User? _user;
  StreamSubscription<User?>? _authSub;
  bool _isInWatchlist = false;
  final Set<String> _seenSet =
      {}; // Deze set bevat de identifiers van de afleveringen die de gebruiker heeft gezien. Voor films kan dit leeg blijven, maar voor series kunnen we hier bijvoorbeeld strings in opslaan zoals "S1E3" om aan te geven dat de gebruiker seizoen 1, aflevering 3 heeft gezien. We gebruiken een set omdat we snel willen kunnen controleren of een bepaalde aflevering al als gezien is gemarkeerd.
  bool _loadingUserData = false;

  String _formatStreamingType(Map<String, dynamic> option) {
    // Deze functie neemt een streaming optie (zoals die we van de API krijgen) en formatteert het type van de optie in een leesbaar formaat. We kijken naar het 'type' veld van de optie, en afhankelijk van of het een abonnement, koopoptie, of huur optie is, formatteren we het label dienovereenkomstig. Voor koop- en huur opties voegen we ook de prijs toe als deze beschikbaar is. Dit maakt het duidelijker voor de gebruiker wat voor soort streaming optie het is en wat de kosten zijn.
    final type = option['type']?.toString();

    switch (type) {
      // We gebruiken een switch statement om het type te bepalen en het juiste label te retourneren
      case 'subscription':
        return 'Included with subscription';
      case 'buy':
        final price = option['price']?['formatted'];
        return price != null ? 'Buy • $price' : 'Buy';
      case 'rent':
        final price = option['price']?['formatted'];
        return price != null ? 'Rent • $price' : 'Rent';
      default:
        return type ?? '';
    }
  }

  // Sorteer volgorde
  int _typePriority(String? type) {
    // Deze functie geeft een prioriteitswaarde terug voor een gegeven streaming type. We gebruiken deze prioriteit om de streaming opties te sorteren, zodat abonnementen bovenaan staan, gevolgd door koopopties, huur opties, en dan andere types. Dit zorgt ervoor dat de meest aantrekkelijke opties (zoals abonnementen) eerst worden getoond aan de gebruiker.
    switch (type) {
      case 'subscription':
        return 0;
      case 'rent':
        return 1;
      case 'buy':
        return 2;
      default:
        return 3;
    }
  }

  // Badge met kleur
  Widget _buildTypeChip(Map<String, dynamic> option) {
    final type = option['type']?.toString();
    final price = option['price']?['formatted'];

    Color bg;
    String label;

    switch (type) {
      case 'subscription':
        bg = Colors.green.shade100;
        label = 'Inbegrepen';
        break;
      case 'rent':
        bg = Colors.blue.shade100;
        label = price != null ? 'Huren • $price' : 'Huren';
        break;
      case 'buy':
        bg = Colors.orange.shade100;
        label = price != null ? 'Kopen • $price' : 'Kopen';
        break;
      default:
        bg = Colors.grey.shade200;
        label = type ?? '';
    }

    return Chip(
      label: Text(label),
      backgroundColor: bg,
    ); // Deze functie bouwt een Chip widget die het type van de streaming optie weergeeft met een bijpassende achtergrondkleur. Abonnementen krijgen een groene achtergrond, huur opties krijgen blauw, koopopties krijgen oranje, en andere types krijgen grijs. De chip toont ook de prijs als deze beschikbaar is. Dit maakt het visueel gemakkelijk te onderscheiden welke opties inbegrepen zijn bij een abonnement en welke extra kosten met zich meebrengen.
  }

  Future<void> _openLink(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ); // Deze functie probeert een URL te openen in de externe browser van het apparaat. We controleren eerst of de URL geldig is en of we deze kunnen openen. Als dat het geval is, gebruiken we launchUrl met de mode set op externalApplication, zodat de link buiten onze app wordt geopend. Dit is handig voor streaming links die vaak in een webbrowser moeten worden geopend.
    } else {
      debugPrint('Cannot launch url: $url');
    }
  }

  List<dynamic> _toList(dynamic maybeListOrMap) {
    // Deze helperfunctie neemt een dynamisch object dat ofwel een lijst of een map kan zijn, en zet het om in een lijst. Sommige API responses kunnen soms een lijst teruggeven, maar als er maar één item is, kunnen ze ook een map teruggeven. Deze functie zorgt ervoor dat we altijd een lijst hebben om mee te werken, ongeacht het oorspronkelijke formaat van de data. Als het object null is, geven we een lege lijst terug. Als het al een lijst is, geven we het direct terug. Als het een map is, nemen we de waarden van de map en zetten die om in een lijst.
    if (maybeListOrMap == null) return [];
    if (maybeListOrMap is List) return maybeListOrMap;
    if (maybeListOrMap is Map) {
      return maybeListOrMap.entries.map((e) => e.value).toList();
    }
    return [];
  }

  Widget _buildServiceIconAsset(
    // Deze functie bouwt een widget die het logo van een streaming service toont op basis van de service naam. We gebruiken de _serviceAssetMap om de juiste asset bestandsnaam te vinden voor de gegeven service naam. We detecteren ook of de app in dark mode is, zodat we het juiste logo kunnen tonen (sommige logo's hebben een donkere en lichte versie). Als we geen match vinden voor de service naam, tonen we een standaard tv-icoon. Dit zorgt
    String? serviceName, {
    double height = 28,
    required BuildContext context,
  }) {
    if (serviceName == null) return const Icon(Icons.tv);

    final key = _serviceAssetMap.entries
        .firstWhere(
          // We zoeken in de _serviceAssetMap naar een entry waarbij de key overeenkomt met de serviceName (case-insensitive). Als we een match vinden, gebruiken we de bijbehorende value als het bestandsnaam van het logo. Als we geen match vinden, geven we een lege string terug.
          (entry) => entry.key.toLowerCase() == serviceName.toLowerCase(),
          orElse: () => const MapEntry('', ''),
        )
        .value;

    if (key.isEmpty)
      return const Icon(
        Icons.tv,
      ); // Als we geen match hebben gevonden in de map, tonen we een standaard tv-icoon.

    // Detecteer of de app dark mode gebruikt
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folder = isDark
        ? 'dark'
        : 'light'; // Sommige logo's hebben een donkere en lichte versie, dus we bepalen welke map we moeten gebruiken op basis van de huidige thema-instelling van de app.

    final path = 'assets/logos/$folder/$key.png';
    return Image.asset(path, height: height);
  }

  Future<String?> _fetchTmdbPosterFromRapid(Map<String, dynamic> rapid) async {
    try {
      final tmdbIdRaw = rapid['tmdbId']
          ?.toString(); // We halen de tmdbId op uit de rapid data. Deze tmdbId is meestal in het formaat "movie/123456" of "tv/654321". We hebben deze ID nodig om onze backend te vragen naar de bijbehorende TMDb afbeeldingen. Als er geen tmdbId aanwezig is, kunnen we geen fallback poster ophalen, dus we loggen dit en returnen null.
      if (tmdbIdRaw == null || tmdbIdRaw.isEmpty) {
        debugPrint('No tmdbId present in rapid data');
        return null;
      }

      // tmdbId is like "movie/1321624" or "tv/XXXX" — we want only the numeric id
      final parts = tmdbIdRaw.split('/');
      final movieId = parts.length > 1 ? parts.last : tmdbIdRaw;

      // call your backend endpoint
      final uri = Uri.parse(
        'https://film-flix-olive.vercel.app/api/movies',
      ).replace(queryParameters: {'type': 'tmdb-images', 'movie_id': movieId});

      debugPrint('Fetching TMDb images from backend: $uri');
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        debugPrint('tmdb-images request failed: ${resp.statusCode}');
        return null;
      }

      final json =
          jsonDecode(resp.body)
              as Map<
                String,
                dynamic
              >?; // We verwachten dat onze backend een JSON object teruggeeft met een 'posters' veld dat een lijst van poster informatie bevat. Als het antwoord niet het verwachte formaat heeft, loggen we dit en returnen we null.

      if (json == null) return null; // extra null check

      // posters array
      final postersRaw = json['posters'];
      final postersList = _toList(postersRaw).cast<Map<String, dynamic>>();

      // We proberen eerst een poster te vinden die specifiek voor de US markt is (iso_3166_1 == 'US'), omdat deze vaak de meest relevante is. Als we geen US poster vinden, nemen we gewoon de eerste poster in de lijst. We halen vervolgens het file_path veld op van de gekozen poster, en bouwen daarmee de volledige URL naar de afbeelding op TMDb. Deze URL kunnen we dan gebruiken om de poster te tonen in onze app.
      Map<String, dynamic>? chosen;
      for (final p in postersList) {
        final country = (p['iso_3166_1'] ?? '').toString();
        if (country.toUpperCase() == 'US') {
          chosen = p;
          break;
        }
      }
      // Als we geen US poster hebben gevonden, nemen we de eerste poster in de lijst (als die er is)
      chosen ??= postersList.isNotEmpty ? postersList.first : null;

      if (chosen == null) {
        debugPrint('No posters found from tmdb-images endpoint');
        return null;
      }

      final filePath = chosen['file_path']?.toString();
      if (filePath == null || filePath.isEmpty) {
        debugPrint('Poster file_path empty');
        return null;
      }

      // De URL voor TMDb afbeeldingen is meestal in de vorm van "https://image.tmdb.org/t/p/original{file_path}", waarbij {file_path} het pad is dat we van onze backend krijgen. We bouwen deze URL en loggen deze, zodat we kunnen controleren dat we de juiste afbeelding proberen te laden. We returnen deze URL, die vervolgens gebruikt kan worden om de poster te tonen in onze app.
      final url = 'https://image.tmdb.org/t/p/original${filePath}';
      debugPrint('Using TMDb poster URL: $url');
      return url;
    } catch (e, s) {
      debugPrint('Error fetching tmdb poster: $e\n$s');
      return null;
    }
  }

  Future<void> _translateText(String key, String originalText) async {
    // Deze functie wordt gebruikt om tekst te vertalen naar het Nederlands. We gebruiken een backend endpoint dat we hebben gemaakt voor vertalingen. We sturen de originele tekst en de doeltaal (in dit geval 'nl' voor Nederlands) naar onze backend, die vervolgens een vertaling teruggeeft. We hebben ook een loading state per tekstveld, zodat we kunnen aangeven dat er een vertaling bezig is. Zodra we de vertaling ontvangen, slaan we deze op in de _translatedTexts map, zodat we deze kunnen tonen in de UI.
    setState(() => _isTranslating[key] = true);

    try {
      final uri = Uri.parse('https://film-flix-olive.vercel.app/api/movies')
          .replace(
            queryParameters: {
              'type': 'translate',
              'text': originalText,
              'target': 'nl',
            },
          );

      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final translated = data['translation'] ?? data['translatedText'] ?? '';
        setState(() {
          _translatedTexts[key] = translated.toString();
        });
      } else {
        debugPrint('Translation failed: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    } finally {
      setState(() => _isTranslating[key] = false);
    }
  }

  String proxiedUrl(String url) {
    return 'https://film-flix-olive.vercel.app/api/movies'
        '?type=image-proxy'
        '&imageUrl=${Uri.encodeComponent(url)}';
  }

  Widget _posterWithFallback(
    // Deze functie bouwt een widget die de poster van de film toont, met een fallback naar de TMDb poster als de originele poster niet beschikbaar is of niet geladen kan worden. We proberen eerst de originele poster te laden, en als dat mislukt (bijvoorbeeld vanwege een fout in de URL of een probleem met het laden van de afbeelding), gebruiken we een FutureBuilder om asynchroon de TMDb poster op te halen via onze backend. Als ook dat mislukt, tonen we een standaard "broken image" icoon. Dit zorgt
    BuildContext context,
    String? initialPoster,
    Map<String, dynamic> rapid,
  ) {
    if (initialPoster == null || initialPoster.isEmpty) {
      // no initial poster — fetch TMDb immediately
      return FutureBuilder<String?>(
        future: _fetchTmdbPosterFromRapid(
          rapid,
        ), // Als er geen originele poster URL is, gaan we direct naar het ophalen van de TMDb poster via onze backend. We gebruiken een FutureBuilder om deze asynchrone operatie af te handelen, en tonen een loading indicator terwijl we wachten op het resultaat. Zodra we de TMDb poster URL hebben, proberen we deze te laden. Als dat ook mislukt, tonen we een "broken image" icoon.
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(
              height: 220,
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final url = snap.data;
          if (url != null && url.isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                proxiedUrl(url),
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) {
                  debugPrint('TMDb poster load error: $e');
                  return Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  );
                },
              ),
            );
          }
          return Container(
            height: 220,
            color: Colors.grey.shade300,
            child: const Center(child: Icon(Icons.broken_image, size: 48)),
          );
        },
      );
    }

    // We have an initial poster URL. Try to load it; on error fetch TMDb fallback.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        proxiedUrl(initialPoster),
        fit: BoxFit.cover,
        // We proberen eerst de originele poster te laden. Als er een fout optreedt bij het laden van deze afbeelding (bijvoorbeeld vanwege een ongeldige URL of netwerkfout), gebruiken we de errorBuilder om een fallback te implementeren. In de errorBuilder maken we een FutureBuilder die asynchroon de TMDb poster ophaalt via onze backend. Terwijl we wachten op het resultaat, tonen we een loading indicator. Zodra we de TMDb poster URL hebben, proberen we deze te laden. Als dat ook mislukt, tonen we een "broken image" icoon. Op deze manier zorgen we ervoor dat we altijd ons best doen om een poster te tonen, zelfs als de originele bron niet beschikbaar is.
        errorBuilder: (context, error, stackTrace) {
          debugPrint(
            'Primary poster load error: $error — trying TMDb fallback',
          );
          return FutureBuilder<String?>(
            future: _fetchTmdbPosterFromRapid(rapid),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 220,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final url = snap.data;
              if (url != null && url.isNotEmpty) {
                // Als we een geldige TMDb poster URL hebben ontvangen, proberen we deze te laden. We gebruiken ook hier een errorBuilder om eventuele fouten bij het laden van de TMDb poster af te handelen, en tonen een "broken image" icoon als dat gebeurt.
                return Image.network(
                  proxiedUrl(url),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) {
                    debugPrint('TMDb fallback load error: $e');
                    return Container(
                      height: 220,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 48),
                      ),
                    );
                  },
                );
              }
              return Container(
                height: 220,
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super
        .initState(); // In de initState van deze screen zetten we een listener op de Firebase Authentication status, zodat we kunnen reageren op veranderingen in de login status van de gebruiker. We halen ook direct de huidige user op, en als er al een user is ingelogd, laden we hun data (zoals watchlist en seen episodes). Daarnaast starten we het proces om de details van de film te laden, zodat we deze kunnen tonen zodra ze beschikbaar zijn.
    _user = FirebaseAuth.instance.currentUser;

    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() {
        _user = u;
      });
      if (u != null)
        _loadUserData();
      else {
        setState(() {
          // Als de gebruiker uitlogt, resetten we de relevante state variabelen zoals _isInWatchlist en _seenSet, zodat we geen verouderde data tonen als er geen gebruiker is ingelogd.
          _isInWatchlist = false;
          _seenSet.clear();
        });
      }
    });
    if (_user != null) _loadUserData();

    _loadMovie();
  }

  Future<void> _loadMovie() async {
    // Deze functie is verantwoordelijk voor het laden van de details van de film. We gebruiken onze MovieRepository om de volledige details van de film op te halen op basis van de imdbId die we van de widget hebben ontvangen. We verwachten dat deze data zowel een 'rapid' deel bevat (met informatie van RapidAPI) als een 'omdb' deel (met informatie van OMDb). We extraheren relevante informatie zoals de poster URL, titel, overzicht, rating, genres, creators, cast, seizoenen, en streaming opties. We slaan deze informatie op in de state variabelen zodat we deze kunnen tonen in de UI. We hebben ook foutafhandeling om eventuele problemen bij het laden van de film te loggen en weer te geven aan de gebruiker.
    try {
      final movie = await MovieRepository.getFullMovie(widget.imdbId);
      final rapid = movie.rapid as Map<String, dynamic>;
      final omdb = movie.omdb as Map<String, dynamic>?;
      final poster = // We proberen eerst de poster URL te halen uit de RapidAPI data, waarbij we specifiek zoeken naar een verticale poster van 480px breed. Als die er niet is, proberen we een kleinere versie van 300px breed. Als die er ook niet is, vallen we terug op de poster URL die we van OMDb krijgen. Deze volgorde geeft de voorkeur aan de mogelijk hogere kwaliteit posters van RapidAPI, maar zorgt er ook voor dat we altijd een poster hebben als die beschikbaar is via OMDb.
          (rapid['imageSet']?['verticalPoster']?['w480'] ??
                  rapid['imageSet']?['verticalPoster']?['w300'] ??
                  omdb?['Poster'])
              ?.toString();

      setState(() {
        // Zodra we de data hebben opgehaald en de relevante informatie hebben geëxtraheerd, updaten we de state van onze screen. We slaan de volledige rapid en omdb data op in _rapidData en _omdbData voor eventueel later gebruik. We zetten de poster URL, titel, overzicht, rating, genres, creators, cast, seizoenen, en streaming opties in hun respectievelijke state variabelen. We zetten ook _loadingMovie op false om aan te geven dat we klaar zijn met laden, zodat we de UI kunnen bijwerken om de details van de film te tonen.
        _rapidData = rapid;
        _omdbData = omdb;
        _poster = poster;
        _title = (rapid['title'] ?? omdb?['Title'] ?? '').toString();
        _overview = (rapid['overview'] ?? omdb?['Plot'] ?? '').toString();
        _rating = (omdb?['imdbRating'] ?? rapid['rating']?.toString() ?? '-')
            .toString();

        _rated = omdb?['Rated']?.toString();

        final rapidGenres = _toList(rapid['genres'])
            .map(
              // We hebben gemerkt dat de genres in de RapidAPI data soms in verschillende formaten kunnen voorkomen. Soms zijn het gewoon strings, maar soms zijn het ook objecten met een 'name' veld. Om hier robuust mee om te gaan, gebruiken we een map functie die controleert of elk genre item een Map is met een 'name' key. Als dat het geval is, nemen we de waarde van 'name' als het genre; anders nemen we het item zelf als string. We zetten deze genres vervolgens om in een Set om duplicaten te verwijderen, aangezien we later ook genres uit OMDb zullen toevoegen.
              (g) =>
                  (g is Map && g.containsKey('name')
                          ? g['name']
                          : g) // Deze lijn controleert of het genre item een Map is met een 'name' key. Als dat het geval is, gebruiken we de waarde van 'name' als het genre. Als het item geen Map is of geen 'name' key heeft, nemen we het item zelf als string. Dit zorgt ervoor dat we correct omgaan met verschillende mogelijke formaten van de genres in de RapidAPI data.
                      .toString(), // We zetten het resultaat om in een string, zodat we consistent strings hebben in onze genres lijst, ongeacht het oorspronkelijke formaat van de data.
            )
            .toSet(); // We zetten de genres van RapidAPI om in een Set om eventuele duplicaten te verwijderen, aangezien we later ook genres uit OMDb zullen toevoegen. Dit zorgt ervoor dat we een unieke lijst van genres hebben voor de film.

        final omdbGenresRaw = omdb?['Genre']?.toString() ?? '';
        final omdbGenres = omdbGenresRaw
            .split(
              ',',
            ) //De genres van OMDb worden vaak teruggegeven als een enkele string met genres gescheiden door komma's (bijvoorbeeld "Action, Adventure, Sci-Fi"). Om deze te verwerken, splitsen we de string op de komma's om een lijst van individuele genres te krijgen. We trimmen ook eventuele extra spaties rond de genre namen en filteren lege strings eruit. Net als bij de RapidAPI genres zetten we deze ook om in een Set om duplicaten te verwijderen.
            .map(
              (g) => g.trim(),
            ) // We trimmen de genres om eventuele extra spaties te verwijderen die kunnen ontstaan bij het splitsen van de string. Dit zorgt ervoor dat we schone genre namen hebben zonder onbedoelde spaties.
            .where(
              (g) => g.isNotEmpty,
            ) // We filteren lege strings eruit, voor het geval er een genre veld is dat leeg is of alleen uit spaties bestaat. Dit zorgt ervoor dat we geen lege genres in onze lijst hebben.
            .toSet(); // We zetten de genres van OMDb ook om in een Set om eventuele duplicaten te verwijderen, vooral in combinatie met de genres van RapidAPI. Dit zorgt ervoor dat we een unieke lijst van genres hebben voor de film, zelfs als er overlap is tussen de twee bronnen.

        _genres = {
          ...rapidGenres,
          ...omdbGenres,
        }.toList(); // We combineren de genres van RapidAPI en OMDb door ze samen te voegen in een nieuwe Set (om duplicaten te verwijderen) en vervolgens om te zetten in een lijst. Dit geeft ons een gecombineerde lijst van unieke genres voor de film, afkomstig van beide bronnen. We slaan deze lijst op in de _genres state variabele, zodat we deze kunnen tonen in de UI.

        _creators = _toList(
          // We halen de creators op uit de RapidAPI data. Net als bij genres kunnen de creators in verschillende formaten voorkomen, dus we gebruiken de _toList helper om hier robuust mee om te gaan. We zetten vervolgens elk creator item om in een string, zodat we een consistente lijst van strings hebben voor de creators.
          rapid['creators'],
        ).map((c) => c.toString()).toList();
        _cast = _toList(rapid['cast'])
            .map((c) => c.toString())
            .toList(); // We halen de cast op uit de RapidAPI data, en gebruiken de _toList helper om te zorgen dat we altijd een lijst hebben, ongeacht het oorspronkelijke formaat van de data. We zetten elk cast item om in een string, zodat we een consistente lijst van strings hebben voor de cast.
        _seasons = _toList(
          rapid['seasons'],
        ); // We halen de seizoenen op uit de RapidAPI data, en gebruiken de _toList helper om te zorgen dat we altijd een lijst hebben, ongeacht het oorspronkelijke formaat van de data. We laten deze als dynamic omdat we mogelijk extra informatie per seizoen willen tonen, zoals het aantal afleveringen of de release data.
        _streaming = _toList(
          rapid['streamingOptions']?['nl'],
        ); // We halen de streaming opties op uit de RapidAPI data, specifiek voor de Nederlandse markt (aangegeven door 'nl'). We gebruiken de _toList helper om te zorgen dat we altijd een lijst hebben, ongeacht het oorspronkelijke formaat van de data. Deze streaming opties bevatten informatie over waar en hoe de film gestreamd kan worden, zoals welke services het aanbieden, of het inbegrepen is bij een abonnement, of het gekocht of gehuurd kan worden, en eventuele prijzen.
        _loadingMovie = false;
      });
    } catch (e, s) {
      debugPrint('Error loading movie: $e\n$s');
      setState(() {
        _error = e.toString();
        _loadingMovie = false;
      });
    }
  }

  @override
  void dispose() {
    // In de dispose methode van deze screen zorgen we ervoor dat we onze Firebase Authentication listener netjes opruimen door de subscription te cancelen. Dit is belangrijk om geheugenlekken te voorkomen en ervoor te zorgen dat we geen onnodige updates meer ontvangen nadat de screen is gesloten. We roepen ook super.dispose() aan om ervoor te zorgen dat de rest van het opruimproces correct wordt afgehandeld.
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Deze functie is verantwoordelijk voor het laden van de gebruikersspecifieke data, zoals de watchlist en de seen episodes. We halen eerst de huidige gebruiker op via Firebase Authentication, en als er geen gebruiker is ingelogd, returnen we direct. We zetten een loading state om aan te geven dat we bezig zijn met het laden van de gebruikersdata. We proberen vervolgens het document van de gebruiker op te halen uit Firestore, waar we verwachten dat we een 'watchlist' veld hebben dat een lijst van imdbIds bevat, en een 'seenEpisodes' veld dat informatie bevat over welke afleveringen van series de gebruiker heeft gezien. We verwerken deze data en updaten onze state variabelen _isInWatchlist en _seenSet zodat we deze kunnen gebruiken in de UI. We hebben ook foutafhandeling om eventuele problemen bij het laden van de gebruikersdata te loggen. Ten slotte zetten we de loading state weer uit.
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    setState(() {
      // We zetten de loading state aan voordat we beginnen met het laden van de gebruikersdata, zodat we in de UI kunnen aangeven dat er een laadproces gaande is. Dit kan bijvoorbeeld worden gebruikt om een loading indicator te tonen terwijl we wachten op het antwoord van Firestore.
      _loadingUserData = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .get();
      final data =
          doc.data() ??
          {}; // We halen de data van het gebruikersdocument op uit Firestore. We verwachten dat deze data een 'watchlist' veld bevat dat een lijst van imdbIds is, en een 'seenEpisodes' veld dat informatie bevat over welke afleveringen van series de gebruiker heeft gezien. We zetten deze data om in de juiste formaten en updaten onze state variabelen zodat we deze kunnen gebruiken in de UI. We hebben ook uitgebreide debug prints toegevoegd om inzicht te krijgen in de structuur van de data die we ontvangen van Firestore, aangezien dit veld soms in verschillende formaten kan voorkomen afhankelijk van hoe het is opgeslagen.
      debugPrint('--- DEBUG USER DATA FOR ${widget.imdbId} ---');
      debugPrint('Firestore keys: ${data.keys.toList()}');

      final watchlist =
          (data['watchlist']
              is List) // We controleren of het 'watchlist' veld in de data een lijst is. Als dat het geval is, zetten we het om in een List<String>. Als het veld niet aanwezig is of geen lijst is, gebruiken we een lege lijst als fallback. Dit zorgt ervoor dat we altijd een geldige lijst hebben om mee te werken, zelfs als de data in Firestore niet precies is zoals we verwachten.
          ? List<String>.from(data['watchlist'])
          : <String>[];

      // Robuuste check voor seenEpisodes (genest of plat veld)
      final seenMap = data['seenEpisodes'];
      List<dynamic> rawSeen =
          []; // We initialiseren een lege lijst voor de raw seen episodes. We zullen deze vullen op basis van de structuur van de data die we ontvangen van Firestore. Omdat we hebben gemerkt dat het 'seenEpisodes' veld soms in verschillende formaten kan voorkomen (soms als een geneste map, soms als platte keys), hebben we een robuuste aanpak nodig om hier correct mee om te gaan. We proberen eerst platte keys te vinden die overeenkomen met de imdbId van de film/serie, en als die er niet zijn, kijken we of er een geneste structuur is waar we de informatie kunnen vinden.

      // probeer eerst platte keys (zoals 'seenEpisodes.tt0944947' of 'seenEpisodes.TT0944947')
      final flatKey = 'seenEpisodes.${widget.imdbId}';
      final flatKeyLower = 'seenEpisodes.${widget.imdbId.toLowerCase()}';

      if (data.containsKey(flatKey) && data[flatKey] is List) {
        rawSeen = data[flatKey];
      } else if (data.containsKey(flatKeyLower) && data[flatKeyLower] is List) {
        rawSeen = data[flatKeyLower];
      }
      // Als we geen platte keys vinden, kijk dan of 'seenEpisodes' zelf een map is waar de imdbId als key in voorkomt
      else if (seenMap is Map) {
        final entry =
            seenMap[widget.imdbId] ??
            seenMap[widget.imdbId.toLowerCase()] ??
            seenMap[widget.imdbId.toUpperCase()];
        if (entry is List)
          rawSeen = entry;
        else if (entry is Map)
          rawSeen = entry.values.toList();
      }

      final imdbSeenList = rawSeen.map((e) => e.toString().trim()).toList();
      debugPrint('Found seen items: $imdbSeenList');

      setState(() {
        // Nadat we de watchlist en seen episodes hebben verwerkt, updaten we onze state variabelen. We zetten _isInWatchlist op true als de imdbId van de huidige film/serie voorkomt in de watchlist van de gebruiker. We vullen _seenSet met de lijst van gezien afleveringen die we hebben gevonden, zodat we deze kunnen gebruiken om te controleren welke afleveringen als gezien moeten worden gemarkeerd in de UI.
        _isInWatchlist = watchlist.contains(widget.imdbId);
        _seenSet.clear();
        _seenSet.addAll(imdbSeenList);
      });
    } catch (e, s) {
      debugPrint('Error loading user data: $e\n$s');
    } finally {
      setState(() {
        _loadingUserData = false;
      });
    }
  }

  Future<bool> _ensureLoggedInWithPrompt(BuildContext context) async {
    // Deze functie controleert of er een gebruiker is ingelogd, en als dat niet het geval is, toont het een dialog die de gebruiker informeert dat inloggen vereist is om verder te gaan. De dialog geeft de optie om naar het login-scherm te navigeren of om te annuleren. Als de gebruiker ervoor kiest om naar het login-scherm te gaan, navigeren we daar naartoe als een fullscreen dialog. Nadat de gebruiker terugkeert van het login-scherm, controleren we opnieuw of er nu een gebruiker is ingelogd, en laden we indien nodig de gebruikersdata. We returnen true als er een gebruiker is ingelogd (na eventueel inloggen), en false als de gebruiker heeft geannuleerd of als er nog steeds geen gebruiker is ingelogd.
    if (_user != null) return true;

    final result = await showDialog<bool>(
      // We tonen een dialog aan de gebruiker waarin we uitleggen dat inloggen vereist is om deze actie uit te voeren. We geven de gebruiker de optie om naar het login-scherm te navigeren of om te annuleren. We wachten op de keuze van de gebruiker en slaan deze op in de 'result' variabele. Als de gebruiker ervoor kiest om te annuleren, of als er een fout optreedt bij het tonen van de dialog, returnen we false. Als de gebruiker ervoor kiest om naar het login-scherm te gaan, returnen we true, en gaan we verder met het navigeren naar het login-scherm.
      context: context,
      builder: (ctx) {
        //ctx omdat we de context van de dialog builder gebruiken om de Navigator aan te sturen. In deze builder definiëren we de inhoud van de AlertDialog die aan de gebruiker wordt getoond. We geven een duidelijke titel en uitleg over waarom inloggen nodig is, en bieden twee knoppen: "Annuleren" en "Naar login". De "Annuleren" knop sluit de dialog en geeft false terug, terwijl de "Naar login" knop sluit de dialog en geeft true terug, wat aangeeft dat de gebruiker heeft gekozen om naar het login-scherm te gaan.
        return AlertDialog(
          // In deze AlertDialog informeren we de gebruiker dat inloggen vereist is om de gewenste actie uit te voeren. We geven een duidelijke titel en uitleg, en bieden twee knoppen: "Annuleren" om terug te gaan zonder iets te doen, en "Naar login" om door te gaan naar het login-scherm. We gebruiken Navigator.of(ctx).pop() om de keuze van de gebruiker terug te geven aan de caller van showDialog.
          title: const Text('Inloggen vereist'),
          content: const Text(
            'Je moet ingelogd zijn om dit te doen. Wil je naar het login-scherm?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Naar login'),
            ),
          ],
        );
      },
    );

    if (result != true || !mounted)
      return false; // Als de gebruiker heeft geannuleerd of als er een fout is opgetreden bij het tonen van de dialog, returnen we false. We controleren ook of de widget nog steeds gemonteerd is voordat we verder gaan, om te voorkomen dat we proberen te navigeren als de screen al is gesloten.

    // Navigeer naar login als fullscreen dialog
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(returnAfterLogin: true),
        fullscreenDialog: true,
      ),
    );

    if (loggedIn == true && mounted) {
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) await _loadUserData();
      return _user != null;
    }

    return false;
  }

  Future<void> _toggleWatchlist() async {
    //  Deze functie wordt aangeroepen wanneer de gebruiker op de knop klikt om de film aan hun watchlist toe te voegen of ervan te verwijderen. We controleren eerst of er een gebruiker is ingelogd, en als dat niet het geval is, tonen we een prompt om in te loggen. Als de gebruiker ervoor kiest om in te loggen en succesvol inlogt, gaan we verder. We bepalen de nieuwe staat van de watchlist (toevoegen of verwijderen) op basis van de huidige staat. We voeren een optimistische update uit door direct de UI bij te werken naar de nieuwe staat, zodat de app snel reageert op de actie van de gebruiker. We proberen vervolgens deze verandering door te voeren in Firestore door het document van de gebruiker bij te werken: we gebruiken FieldValue.arrayUnion om een imdbId toe te voegen aan de watchlist, of FieldValue.arrayRemove om een imdbId te verwijderen. We hebben foutafhandeling om eventuele problemen bij het bij
    final u = FirebaseAuth.instance.currentUser;
    if (u == null)
      return; // We controleren of er een gebruiker is ingelogd. Als dat niet het geval is, returnen we direct, omdat we geen watchlist kunnen bijwerken zonder een ingelogde gebruiker.

    final newState = !_isInWatchlist;

    // Optimistic update: we updaten de UI direct naar de nieuwe staat, zodat de app snel reageert op de actie van de gebruiker. We zullen deze update terugdraaien als er een fout optreedt bij het bijwerken van Firestore, maar in de meeste gevallen zal dit zorgen voor een snellere en soepelere gebruikerservaring.
    setState(() => _isInWatchlist = newState);

    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      if (newState) {
        // Als de nieuwe staat is dat de film in de watchlist moet worden toegevoegd, gebruiken we FieldValue.arrayUnion om de imdbId toe te voegen aan de 'watchlist' array in het gebruikersdocument in Firestore. We gebruiken SetOptions(merge: true) om ervoor te zorgen dat we alleen het 'watchlist' veld bijwerken en geen andere data in het document overschrijven. Als de nieuwe staat is dat de film uit de watchlist moet worden verwijderd, gebruiken we FieldValue.arrayRemove om de imdbId te verwijderen uit de 'watchlist' array. Ook hier gebruiken we SetOptions(merge: true) om alleen het relevante veld bij te werken.
        await docRef.set({
          'watchlist': FieldValue.arrayUnion([widget.imdbId]),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'watchlist': FieldValue.arrayRemove([widget.imdbId]),
        }, SetOptions(merge: true));
      }
    } catch (e, s) {
      debugPrint('Error toggling watchlist: $e\n$s');
      // rollback UI if firestore fails
      setState(() => _isInWatchlist = !newState);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon watchlist niet bijwerken.')),
      );
    }
  }

  Future<void> _toggleEpisodeSeen(String epKey, bool seen) async {
    // Deze functie wordt aangeroepen wanneer de gebruiker een aflevering markeert als gezien of niet gezien. We controleren eerst of er een gebruiker is ingelogd, en als dat niet het geval is, returnen we direct, omdat we geen seen status kunnen bijwerken zonder een ingelogde gebruiker. We voeren een optimistische update uit door direct de UI bij te werken naar de nieuwe staat van de aflevering (toevoegen aan seen set of verwijderen ervan), zodat de app snel reageert op de actie van de gebruiker. We proberen vervolgens deze verandering door te voeren in Firestore door het document van de gebruiker bij te werken: we gebruiken FieldValue.arrayUnion om een epKey toe te voegen aan de lijst van gezien afleveringen voor deze specifieke serie, of FieldValue.arrayRemove om een epKey te verwijderen. We hebben foutafhandeling om eventuele problemen bij het bijwerken van Firestore te loggen en om de UI terug te draaien naar de vorige staat als er een fout optreedt, zodat we consistent blijven met de daadwerkelijke data in Firestore.
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    // Optimistic update
    setState(() {
      if (seen) {
        _seenSet.add(
          epKey,
        ); // Als de gebruiker de aflevering als gezien markeert, voegen we de epKey toe aan de _seenSet. Deze set bevat alle afleveringen die de gebruiker heeft gemarkeerd als gezien, en we gebruiken deze in de UI om te bepalen welke afleveringen als gezien moeten worden weergegeven.
      } else {
        _seenSet.remove(
          epKey,
        ); // Als de gebruiker de aflevering als niet gezien markeert, verwijderen we de epKey uit de _seenSet. Dit zorgt ervoor dat deze aflevering niet langer als gezien wordt weergegeven in de UI. We zullen deze verandering later doorvoeren in Firestore, maar we updaten de UI direct voor een snellere gebruikerservaring.
      }
    });

    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      if (seen) {
        await docRef.set({
          'seenEpisodes.${widget.imdbId}': FieldValue.arrayUnion([epKey]),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'seenEpisodes.${widget.imdbId}': FieldValue.arrayRemove([epKey]),
        }, SetOptions(merge: true));
      }
    } catch (e, s) {
      debugPrint('Error toggling episode seen: $e\n$s');
      // rollback UI if firestore fails: als er een fout optreedt bij het bijwerken van Firestore, draaien we de UI terug naar de vorige staat door de epKey weer toe te voegen aan de _seenSet als we hem hadden verwijderd, of te verwijderen als we hem hadden toegevoegd. Dit zorgt ervoor dat de UI consistent blijft met de daadwerkelijke data in Firestore, zelfs als er een fout optreedt.
      setState(() {
        if (seen) {
          _seenSet.remove(epKey);
        } else {
          _seenSet.add(epKey);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon afleveringstatus niet bijwerken.')),
      );
    }
  }

  List<Widget> _buildGroupedStreaming(
    List<dynamic> streaming,
    BuildContext context,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in streaming) {
      if (item is! Map) continue;
      final typedItem = item as Map<String, dynamic>;
      final service = typedItem['service'] as Map<String, dynamic>?;
      final name = service?['name']?.toString() ?? 'Service';

      grouped.putIfAbsent(name, () => []);
      grouped[name]!.add(typedItem);
    }

    final List<Widget> widgets = [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    grouped.forEach((serviceName, options) {
      options.sort(
        (a, b) => _typePriority(a['type']) - _typePriority(b['type']),
      );

      final Map<String, Map<String, dynamic>> uniqueOptions = {};
      for (var option in options) {
        final type = option['type']?.toString() ?? 'other';
        uniqueOptions.putIfAbsent(type, () => option);
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildServiceIconAsset(
                    serviceName,
                    context: context,
                    height: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: uniqueOptions.values.map((option) {
                  final link = option['link'] ?? option['service']?['homePage'];
                  final chip = _buildTypeChip(option);

                  return GestureDetector(
                    onTap: () => _openLink(link?.toString()),
                    child: chip,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });

    return widgets;
  }

  Widget _buildSeasonTile(
    BuildContext context,
    dynamic seasonRaw,
    int seasonIndex,
    List seasons,
  ) {
    final season =
        (seasonRaw
            is Map) // We controleren of seasonRaw een Map is, omdat we verwachten dat de seizoenen in de RapidAPI data als maps worden weergegeven. Als seasonRaw inderdaad een Map is, gebruiken we het direct. Als het geen Map is (bijvoorbeeld als het gewoon een string is), maken we een nieuwe Map aan met een 'title' key die de string waarde van seasonRaw bevat. Dit zorgt ervoor dat we altijd een consistente structuur hebben om mee te werken, ongeacht het oorspronkelijke formaat van de data.
        ? seasonRaw
        : {'title': seasonRaw.toString()};
    final seasonTitle = (season['title'] ?? season['itemType'] ?? 'Season')
        .toString();
    final firstYear = season['firstAirYear']?.toString() ?? '';
    final lastYear = season['lastAirYear']?.toString() ?? '';
    final epRaw = season['episodes'];
    final episodes = _toList(epRaw);

    return ExpansionTile(
      title: Text(seasonTitle),
      subtitle: Text('$firstYear${lastYear.isNotEmpty ? ' - $lastYear' : ''}'),
      children: episodes.isEmpty
          ? [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Geen afleveringen gevonden',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]
          : [
              for (var ei = 0; ei < episodes.length; ei++)
                _buildEpisodeRow(context, episodes[ei], seasonIndex, ei),
            ],
    );
  }

  Widget _buildEpisodeRow(
    // Deze functie bouwt een widget die een enkele aflevering binnen een seizoen weergeeft. We nemen de BuildContext, de ruwe data van de aflevering (die in verschillende formaten kan voorkomen), de index van het seizoen en de index van de aflevering als parameters. We extraheren de relevante informatie uit de ruwe data van de aflevering, zoals de titel, het overzicht, streaming opties, thumbnail en een unieke sleutel voor opslag. We controleren ook of deze aflevering als gezien is gemarkeerd door de gebruiker. We bouwen vervolgens een ListTile die deze informatie weergeeft: we tonen de thumbnail (indien beschikbaar), de titel van de aflevering, en een deel van het overzicht met een optie om het volledige overzicht te vertalen. We tonen ook een play knop als er streaming opties beschikbaar zijn, en een checkbox om aan te geven of de aflevering als gezien is gemarkeerd. Wanneer de gebruiker op het overzicht klikt, tonen we een dialog met het volledige overzicht van de aflevering.
    BuildContext context,
    dynamic epRaw,
    int seasonIndex,
    int episodeIndex,
  ) {
    final ep = (epRaw is Map) ? epRaw : {'title': epRaw.toString()};
    final epTitle = (ep['title'] ?? ep['itemType'] ?? 'Episode').toString();
    final epOverview = (ep['overview'] ?? '').toString();

    // stream options for episode
    final epStreamRaw = ep['streamingOptions']?['nl'] ?? ep['streamingOptions'];
    final epStreams = _toList(epStreamRaw);
    if (epStreams.isNotEmpty) {
      // We controleren of er streaming opties beschikbaar zijn voor deze aflevering. We proberen eerst de Nederlandse streaming opties te extraheren (aangegeven door 'nl'), en als die er niet zijn, gebruiken we de algemene 'streamingOptions'. We gebruiken de _toList helper om ervoor te zorgen dat we altijd een lijst hebben, ongeacht het oorspronkelijke formaat van de data. Als er streaming opties beschikbaar zijn, kunnen we deze later gebruiken om een play knop weer te geven waarmee de gebruiker naar de beschikbare streaming services kan navigeren.
      final first = epStreams[0];
      if (first is Map) {}
    }

    // thumbnail
    final epThumb =
        ep['imageSet']?['verticalPoster']?['w160'] ?? ep['image'] ?? null;

    // stable episode key for storage
    final epKey =
        's${seasonIndex}_e${episodeIndex}'; // We genereren een unieke sleutel voor deze aflevering op basis van de index van het seizoen en de index van de aflevering. Deze sleutel gebruiken we later om bij te houden welke afleveringen als gezien zijn gemarkeerd door de gebruiker. Door deze sleutel te gebruiken, kunnen we gemakkelijk controleren of een specifieke aflevering in de _seenSet zit, wat ons vertelt of de gebruiker deze aflevering als gezien heeft gemarkeerd.
    final isSeen = _seenSet.contains(epKey);

    return Column(
      children: [
        ListTile(
          leading: epThumb != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                    6,
                  ), // We gebruiken ClipRRect om de thumbnail van de aflevering weer te geven met afgeronde hoeken. We controleren eerst of er een thumbnail beschikbaar is (epThumb is niet null), en als dat het geval is, tonen we deze in de leading positie van de ListTile. We stellen de breedte en hoogte van de afbeelding in op 84x48 pixels, en we gebruiken BoxFit.cover om ervoor te zorgen dat de afbeelding goed past binnen deze afmetingen. We voegen ook een errorBuilder toe om een fallback icoon weer te geven als er een fout optreedt bij het laden van de afbeelding, zoals wanneer de URL ongeldig is of wanneer er netwerkproblemen zijn.
                  child: Image.network(
                    proxiedUrl(epThumb.toString()),
                    width: 84,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                )
              : null,
          title: Text(
            epTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: epOverview.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translatedTexts[epKey] ?? epOverview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      icon: _isTranslating[epKey] == true
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.translate, size: 16),
                      label: const Text(
                        'Vertalen',
                        style: TextStyle(fontSize: 12),
                      ),
                      onPressed: _isTranslating[epKey] == true
                          ? null
                          : () {
                              _translateText(epKey, epOverview);
                            },
                    ),
                  ],
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // play button (if streams available)
              if (epStreams
                  .isNotEmpty) // We controleren of er streaming opties beschikbaar zijn voor deze aflevering. Als dat het geval is, tonen we een play knop in de trailing positie van de ListTile. Wanneer de gebruiker op deze knop klikt, willen we een modal bottom sheet tonen met de beschikbare streaming opties voor deze aflevering, zodat de gebruiker kan kiezen waar ze deze aflevering willen bekijken. We zullen de streaming opties die we eerder hebben geëxtraheerd gebruiken om deze informatie in de modal te tonen.
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    // dedupe per service+type
                    final Map<String, Map<String, dynamic>> deduped = {};
                    for (var option in epStreams) {
                      if (option is! Map) continue;
                      final typedOption = option as Map<String, dynamic>;
                      final serviceName =
                          typedOption['service']?['name']?.toString() ??
                          'Unknown';
                      final type = typedOption['type']?.toString() ?? 'other';
                      final key = '${serviceName.toLowerCase()}_$type';
                      deduped.putIfAbsent(key, () => typedOption);
                    }
                    final mergedStreams = deduped.values.toList();

                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: mergedStreams.map<Widget>((option) {
                            // We itereren door de gededupede lijst van streaming opties en bouwen een ListTile voor elke optie. We extraheren de naam van de service en de link van de optie, en tonen deze informatie in de ListTile. Wanneer de gebruiker op een ListTile klikt, sluiten we de modal bottom sheet en navigeren we naar de link van die streaming optie, zodat de gebruiker direct naar de juiste pagina kan gaan om deze aflevering te bekijken.
                            final service =
                                option['service']?['name']?.toString() ??
                                'Unknown';
                            final link =
                                option['link'] ??
                                option['service']?['homePage']?.toString();
                            return ListTile(
                              leading: _buildServiceIconAsset(
                                service,
                                context: context,
                                height: 28,
                              ),
                              title: Text(service),
                              subtitle: Text(_formatStreamingType(option)),
                              onTap: () {
                                Navigator.pop(ctx);
                                _openLink(link?.toString());
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),

              // seen checkbox
              Checkbox(
                value: _seenSet.contains(epKey),
                onChanged: (val) async {
                  if (_user == null) {
                    final go = await _ensureLoggedInWithPrompt(context);
                    if (!go) return;
                  }
                  await _toggleEpisodeSeen(epKey, val ?? false);
                  // Na het toggelen van de seen status van de aflevering, willen we ervoor zorgen dat de UI wordt bijgewerkt om de nieuwe status weer te geven. We roepen setState aan om de widget te laten herbouwen, zodat de checkbox en andere relevante delen van de UI worden bijgewerkt op basis van de nieuwe staat van _seenSet. Dit zorgt ervoor dat wanneer een gebruiker een aflevering markeert als gezien of niet gezien, deze verandering direct zichtbaar is in de interface.
                  setState(() {});
                },
              ),
            ],
          ),
          onTap: epOverview.isNotEmpty
              ? () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final maxHeight = MediaQuery.of(ctx).size.height * 0.7;
                      return StatefulBuilder(
                        builder: (ctx, setDialogState) {
                          return AlertDialog(
                            title: Text(epTitle),
                            content: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: maxHeight),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _translatedTexts[epKey] ?? epOverview,
                                      style: const TextStyle(height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      icon: _isTranslating[epKey] == true
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.translate,
                                              size: 16,
                                            ),
                                      label: const Text('Vertalen'),
                                      onPressed: _isTranslating[epKey] == true
                                          ? null
                                          : () async {
                                              await _translateText(
                                                epKey,
                                                epOverview,
                                              );
                                              // Zorg dat de dialog herbouwt
                                              setDialogState(() {});
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Sluiten'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              : null,
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMovie) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final rapid = _rapidData!;
    final poster = _poster;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _posterWithFallback(context, poster, rapid),

            const SizedBox(height: 12),

            // Main Info card
            Card(
              elevation: 3,
              color: isDark ? Colors.grey.shade900 : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _translatedTexts['overview'] ?? _overview ?? '',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          icon: _isTranslating['overview'] == true
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.translate, size: 18),
                          label: const Text('Vertalen'),
                          onPressed: _isTranslating['overview'] == true
                              ? null
                              : () {
                                  if (_overview != null) {
                                    _translateText('overview', _overview!);
                                  }
                                },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 6),
                        Text(
                          _rating ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),

                        const Spacer(),
                        // watchlist button
                        _loadingUserData
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : ElevatedButton.icon(
                                icon: Icon(
                                  _isInWatchlist
                                      ? Icons.bookmark
                                      : Icons.bookmark_add_outlined,
                                ),
                                label: Text(
                                  _isInWatchlist ? 'Verwijder' : 'Opslaan',
                                ),
                                onPressed: () async {
                                  // controleer login
                                  if (_user == null) {
                                    final goToLogin =
                                        await _ensureLoggedInWithPrompt(
                                          context,
                                        );
                                    if (!goToLogin) return;
                                    // gebruiker navigeert naar login -> wachten op auth listener om data te laden
                                    return;
                                  }
                                  await _toggleWatchlist();
                                },
                              ),
                      ],
                    ),
                    if (_rated != null && _rated!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.family_restroom_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Leeftijdsclassificatie: $_rated',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),

                    if (_genres.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres
                            .map(
                              (g) => Chip(
                                label: Text(g),
                                backgroundColor: isDark
                                    ? Colors.blue.shade900
                                    : Colors.blue.shade50,
                                labelStyle: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),

                    // Creators
                    if (_creators.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Producers / Creators',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children: _creators.map((c) {
                              final searchUrl =
                                  'https://www.imdb.com/find?q=${Uri.encodeComponent(c)}&s=nm';
                              return GestureDetector(
                                onTap: () => _openLink(searchUrl),
                                child: Chip(
                                  label: Text(c),
                                  backgroundColor: isDark
                                      ? Colors.green.shade900
                                      : Colors.green.shade50,
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),

                    // Cast
                    if (_cast.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Actors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _cast.take(8).map((c) {
                              final searchUrl =
                                  'https://www.imdb.com/find?q=${Uri.encodeComponent(c)}&s=nm';
                              return GestureDetector(
                                onTap: () => _openLink(searchUrl),
                                child: Chip(
                                  label: Text(c),
                                  backgroundColor: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade200,
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Seizoenen: ${rapid['seasonCount'] ?? '-'}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'Afleveringen: ${rapid['episodeCount'] ?? '-'}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Streaming card
            if (_streaming.isNotEmpty)
              Card(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streaming',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ..._buildGroupedStreaming(_streaming, context),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Seasons & Episodes expansion
            if (_seasons.isNotEmpty)
              Card(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                child: ExpansionTile(
                  title: Text(
                    'Seizoenen & Afleveringen (${_seasons.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  children: [
                    for (var si = 0; si < _seasons.length; si++)
                      _buildSeasonTile(context, _seasons[si], si, _seasons),
                  ],
                ),
              ),

            if (_seasons.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Geen seizoenen gevonden',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

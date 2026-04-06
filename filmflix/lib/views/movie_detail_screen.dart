import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeert de custom top bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Importeert de background widget
import 'dart:async'; // Importeert async/Future functionaliteiten
import 'dart:convert'; // Importeert JSON encoding/decoding functies
import 'dart:typed_data'; // Importeert typed data zoals Uint8List
import 'package:flutter/services.dart'
    show rootBundle; // Importeert rootBundle voor asset bestanden

import 'package:cloud_firestore/cloud_firestore.dart'; // Importeert Firestore database
import 'package:cinetrackr/views/loginscreen.dart'; // Importeert login scherm
import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeert localisatie/taalbestanden
import 'package:firebase_auth/firebase_auth.dart'; // Importeert Firebase authenticatie
import 'package:flutter/foundation.dart'; // Importeert Flutter foundation utilities
import 'package:flutter/material.dart'; // Importeert Material Design widgets
import 'package:marquee/marquee.dart'; // Importeert scrolling marquee effect
import 'package:url_launcher/url_launcher.dart'; // Importeert URL launcher
import 'package:cinetrackr/widgets/youtube_player.dart'; // Importeert YouTube player widget
import 'package:cinetrackr/services/movie_repository.dart'; // Importeert movie data repository
import 'package:cinetrackr/services/movie_api.dart'; // Importeert movie API service
import 'package:http/http.dart'
    as http; // Importeert HTTP client voor API requests

class MovieDetailScreen extends StatefulWidget {
  // Definieert stateful widget voor filmdetail scherm
  final String imdbId; // IMDb identificatie nummer van de film
  const MovieDetailScreen({
    super.key,
    required this.imdbId,
  }); // Constructor met required imdbId parameter

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState(); // Maakt state instance voor widget
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // Definieert state class voor filmdetail scherm
  String? _xAppApiKey; // String variabele voor API key
  final Map<String, Uint8List> _imageCache =
      {}; // Cache voor gedownloade afbeeldingen
  String? _rating; // Film rating waarde
  List<String> _genres = []; // Lijst met genre strings
  List<String> _creators = []; // Lijst met creator/producer namen
  List<String> _cast = []; // Lijst met actor namen
  List<dynamic> _seasons = []; // Lijst met seizoen data
  List<dynamic> _streaming = []; // Lijst met streaming service opties
  bool _loadingMovie = true; // Status voor het laden van film data
  String? _error; // Fout message wenn laden mislukt
  String? _rated; // Ouderlijkse waarschuwing/rating (PG, 12+, etc)

  String _formatRating(String? rating) {
    // Functie om rating format proper op te maken
    if (rating == null || rating.isEmpty || rating == '-')
      return rating ?? ''; // Return rating ongewijzigd als null/leeg/'-'
    final loc = AppLocalizations.of(context)!; // Haalt localisatie context op
    String cleanRating = rating.replaceAll(
      ',',
      '.',
    ); // Vervangt comma's door punten
    if (cleanRating.endsWith('.')) {
      // Check of rating eindigt met punt
      cleanRating = cleanRating.substring(
        0,
        cleanRating.length - 1,
      ); // Verwijdert eindpunt
    }
    final doubleRating = double.tryParse(
      cleanRating,
    ); // Parseert string naar double
    if (doubleRating != null) {
      // Check of parsing succesvol was
      if (doubleRating == 0) return '-'; // Return '-' voor 0 rating
      if (doubleRating > 10 && doubleRating <= 100) {
        // Check of rating op schaal 100 is
        return '${(doubleRating / 10).toStringAsFixed(1)}/10 ${loc.stars}'; // Converteert naar /10 schaal
      } else if (doubleRating <= 10) {
        // Check of rating al op /10 schaal is
        return '${doubleRating.toStringAsFixed(1)}/10 ${loc.stars}'; // Formatteert rating met /10
      }
    }
    return rating; // Return originele rating als parsing mislukt
  }

  Future<void> _loadVideos() async {
    // Async functie om video/trailer data op te halen
    try {
      // Start try block voor error handling
      setState(() => _loadingTrailer = true); // Zet loading status aan
      final tmdbIdRaw =
          _rapidData?['tmdbId']?.toString() ??
          ''; // Haalt TMDb ID op uit rapid data
      if (tmdbIdRaw.isEmpty) {
        // Check of TMDb ID leeg is
        setState(() => _loadingTrailer = false); // Zet loading status uit
        return; // Exit functie
      }
      final parts = tmdbIdRaw.split(
        '/',
      ); // Split TMDb ID op slash (movie/123 of tv/456)
      final id = parts.isNotEmpty
          ? parts.last
          : tmdbIdRaw; // Haalt laatst deel van path (nummer)
      final isMovie =
          _isResponseMovie(_omdbData?['Type']?.toString()) ||
          _isResponseMovie(_rapidData?['itemType']?.toString()) ||
          _isResponseMovie(_rapidData?['type']?.toString()) ||
          _isResponseMovie(_rapidData?['showType']?.toString()) ||
          _isResponseMovie(
            _rapidData?['titleType']?.toString(),
          ); // Bepaalt of dit een film of serie is
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          .replace(
            queryParameters: isMovie
                ? {
                    'type': 'tmdbmovievideos',
                    'movie_id': id,
                    'language': 'en-US',
                  }
                : {'type': 'tmdbserievideos', 'tv_id': id, 'language': 'en-US'},
          ); // Bouwt API URL met juiste parameters
      await _ensureEnvLoaded(); // Laadt environment variables (API key)
      final headers = <String, String>{}; // Initialiseert lege headers map
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] =
            _xAppApiKey!; // Voegt API key toe aan headers
      final resp = await http.get(
        uri,
        headers: headers,
      ); // Stuurt HTTP GET request
      if (resp.statusCode != 200) {
        // Check of response code niet OK is
        setState(() => _loadingTrailer = false); // Zet loading status uit
        return; // Exit functie
      }
      final jsonData =
          jsonDecode(resp.body)
              as Map<String, dynamic>?; // Decodeert JSON response
      if (jsonData == null) {
        // Check of JSON null is
        setState(() => _loadingTrailer = false); // Zet loading status uit
        return; // Exit functie
      }
      final results = (jsonData['results'] is List)
          ? jsonData['results'] as List
          : []; // Haalt results array op of leeg array
      final List<Map<String, dynamic>> youtubeVideos =
          []; // Initialiseert YouTube videos lijst
      for (final r in results) {
        // Loop door elke result
        final m = Map<String, dynamic>.from(
          r as Map,
        ); // Converteert result naar map
        final site = (m['site'] ?? '')
            .toString()
            .toLowerCase(); // Haalt site op (lowercase)
        if (site == 'youtube') {
          // Check of site YouTube is
          youtubeVideos.add(m); // Voegt aan YouTube videos lijst
        }
      }
      youtubeVideos.sort((a, b) {
        // Sorteert YouTube videos
        final aType = (a['type'] ?? '')
            .toString()
            .toLowerCase(); // Haalt type van a op
        final bType = (b['type'] ?? '')
            .toString()
            .toLowerCase(); // Haalt type van b op
        if (aType == 'trailer' && bType != 'trailer')
          return -1; // Trailers eerst
        if (aType != 'trailer' && bType == 'trailer')
          return 1; // Andere types na trailers
        return 0; // Behoud originele volgorde
      });
      if (youtubeVideos.isNotEmpty) {
        // Check of YouTube videos beschikbaar zijn
        final rawKey = youtubeVideos[0]['key']
            ?.toString(); // Haalt video key op
        final normKey =
            _normalizeYoutubeId(rawKey) ?? rawKey; // Normaliseert YouTube ID
        debugPrint(
          'Selected trailer raw key: $rawKey, normalized: $normKey, site: ${youtubeVideos[0]['site']}',
        ); // Debug output voor trailer selectie
        setState(() {
          // Start state update
          _allVideos = youtubeVideos; // Zet alle videos
          _currentVideoIndex = 0; // Reset video index naar 0
          _trailerKey = normKey; // Zet genormaliseerde video key
          _trailerSite = youtubeVideos[0]['site']?.toString(); // Zet video site
        }); // Einde state update
      } // Einde if youtubeVideos not empty
    } catch (e) {
      // Catch any errors
      debugPrint('Error loading videos: $e'); // Debug print error
    } finally {
      // Always execute
      setState(() => _loadingTrailer = false); // Zet loading status uit
    } // Einde try-catch-finally
  } // Einde _loadVideos functie

  Map<String, String> _translatedTexts = {}; // Map voor vertaalde teksten
  Map<String, bool> _isTranslating = {}; // Map voor translation status per key
  User? _user; // Huidige ingelogde gebruiker
  StreamSubscription<User?>? _authSub; // Subscription op auth state changes
  bool _isInWatchlist = false; // Status of film in watchlist zit
  final Set<String> _seenSet = {}; // Set van geziene aflevering keys
  bool _loadingUserData = false; // Status voor het laden van user data
  Map<String, dynamic>? _rapidData; // RapidAPI response data
  Map<String, dynamic>? _omdbData; // OMDb API response data
  String? _poster; // Poster URL
  String? _title; // Film titel
  String? _overview; // Film overzicht/beschrijving
  List<Map<String, dynamic>> _allVideos = []; // Lijst met alle video data
  int _currentVideoIndex = 0; // Huidendige video index
  String? _trailerKey; // YouTube video ID
  String? _trailerSite; // Video site (YouTube)
  bool _loadingTrailer = false; // Status voor trailer laden
  static const Map<String, String> _serviceAssetMap = {
    // Map van service namen naar asset bestandsnamen
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
  }; // Einde service asset map

  String _formatStreamingType(
    BuildContext context,
    Map<String, dynamic> option,
  ) {
    // Functie om streaming type te formatteren
    final type = option['type']?.toString(); // Haalt streaming type op
    final loc = AppLocalizations.of(context)!; // Haalt localisatie context op
    switch (type) {
      // Switch op streaming type
      case 'subscription': // Als subscription
        return loc.included_with_subscription; // Returneer subscription label
      case 'buy': // Als koop optie
        final price = option['price']?['formatted']; // Haalt prijs op
        return price != null
            ? loc.buy_with_price(price.toString())
            : loc.buy; // Returneer buy label met/zonder prijs
      case 'rent': // Als huur optie
        final price = option['price']?['formatted']; // Haalt prijs op
        return price != null
            ? loc.rent_with_price(price.toString())
            : loc.rent; // Returneer rent label met/zonder prijs
      case 'addon': // Als add-on optie
        final price = option['price']?['formatted']; // Haalt prijs op
        return price != null
            ? loc.addon_with_price(price.toString())
            : loc.addon; // Returneer addon label met/zonder prijs
      default: // Voor alle andere types
        return type ?? ''; // Returneer type of lege string
    } // Einde switch
  } // Einde _formatStreamingType functie

  int _typePriority(String? type) {
    // Functie om prioriteit van streaming type te bepalen
    switch (type) {
      // Switch op streaming type
      case 'subscription': // Als subscription
        return 0; // Hoogste prioriteit
      case 'rent': // Als huur
        return 1; // Middelste prioriteit
      case 'buy': // Als koop
        return 2; // Lage prioriteit
      default: // Voor alle andere types
        return 3; // Laagste prioriteit
    } // Einde switch
  } // Einde _typePriority functie

  bool _isResponseMovie(String? type) {
    // Functie om te checken of type een film is
    final t = type?.toString().toLowerCase() ?? ''; // Zet type naar lowercase
    if (t.isEmpty) return false; // Return false als leeg
    return t == 'movie' ||
        t == 'film' ||
        t.contains('film') ||
        t.contains('movie') ||
        t.contains('feature'); // Check of text movie/film bevat
  } // Einde _isResponseMovie functie

  String _detectMediaType() {
    // Functie om media type (film/serie) te detecteren
    final candidates = [
      _rapidData?['itemType'],
      _rapidData?['type'],
      _rapidData?['showType'],
      _rapidData?['titleType'],
      _omdbData?['Type'],
    ]; // Verzamelt mogelijke type velden
    var sawSeries = false; // Boolean voor serie detectie
    for (final c in candidates) {
      // Loop door candidates
      if (c == null) continue; // Skip null values
      final s = c.toString().toLowerCase(); // Zet naar lowercase
      if (s.contains('movie') || s.contains('film') || s.contains('feature'))
        return 'movie'; // Return 'movie' als film type
      if (s.contains('series') || s.contains('tv'))
        sawSeries = true; // Set sawSeries flag
    } // Einde loop
    if (sawSeries) return 'series'; // Return 'series' als serie gevonden
    return 'unknown'; // Return 'unknown' als geen match
  } // Einde _detectMediaType functie

  Widget _buildTypeChip(BuildContext context, Map<String, dynamic> option) {
    // Functie om streaming type chip te bouwen
    final type = option['type']?.toString(); // Haalt streaming type op
    final price = option['price']?['formatted']; // Haalt prijs op
    Color bg; // Variabele voor background kleur
    String label; // Variabele voor chip label
    final loc = AppLocalizations.of(context)!; // Haalt localisatie context op
    switch (type) {
      // Switch op streaming type
      case 'subscription': // Als subscription
        bg = Colors.green.shade100; // Groene achtergrond
        label = loc.included_with_subscription; // Label voor subscription
        break; // Einde case
      case 'rent': // Als huur
        bg = Colors.blue.shade100; // Blauwe achtergrond
        label = price != null
            ? loc.rent_with_price(price.toString())
            : loc.rent; // Label voor huur met/zonder prijs
        break; // Einde case
      case 'buy': // Als koop
        bg = Colors.orange.shade100; // Oranje achtergrond
        label = price != null
            ? loc.buy_with_price(price.toString())
            : loc.buy; // Label voor koop met/zonder prijs
        break; // Einde case
      case 'addon': // Als add-on
        bg = Colors.grey.shade100; // Grijze achtergrond
        label = price != null
            ? loc.addon_with_price(price.toString())
            : loc.addon; // Label voor addon met/zonder prijs
        break; // Einde case
      default: // Voor alle andere types
        bg = Colors.grey.shade200; // Grijze achtergrond
        label = type ?? ''; // Label is type of leeg
    } // Einde switch
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Check of dark mode actief is
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: isDark ? Colors.black : Colors.black),
      ),
      backgroundColor: bg,
    ); // Return Chip widget
  } // Einde _buildTypeChip functie

  Future<void> _openLink(String? url) async {
    // Async functie om link te openen
    if (url == null) return; // Return als url null is
    final uri = Uri.tryParse(url); // Parse URL naar Uri
    if (uri == null) return; // Return als parsing mislukt
    if (await canLaunchUrl(uri)) {
      // Check of URL kan worden geopend
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ); // Open URL in externe app
    } else {
      // Anders
      debugPrint('Cannot launch url: $url'); // Print debug message
    } // Einde if-else
  } // Einde _openLink functie

  List<dynamic> _toList(dynamic maybeListOrMap) {
    // Functie om lijst of map om te zetten naar lijst
    if (maybeListOrMap == null) return []; // Return lege lijst als null
    if (maybeListOrMap is List)
      return maybeListOrMap; // Return direct als al lijst
    if (maybeListOrMap is Map) {
      return maybeListOrMap.entries.map((e) => e.value).toList();
    } // Zet map values om naar lijst
    return []; // Return lege lijst voor andere types
  } // Einde _toList functie

  String? _normalizeYoutubeId(String? raw) {
    // Functie om YouTube ID te normaliseren
    if (raw == null) return null; // Return null als input null
    final r = raw.trim(); // Verwijdert whitespace
    final idPattern = RegExp(
      r'^[a-zA-Z0-9_-]{11,}$',
    ); // Regex pattern voor YouTube ID
    if (idPattern.hasMatch(r) && !r.contains('http') && !r.contains('/')) {
      return r;
    } // Return ID als al geformatteerd
    try {
      // Start try block
      final uri = Uri.tryParse(r); // Parse als URL
      if (uri != null) {
        // Check of URI parsed is
        final v = uri.queryParameters['v']; // Haalt 'v' parameter op
        if (v != null && v.isNotEmpty) return v; // Return 'v' parameter
        final host = uri.host.toLowerCase(); // Haalt host op (lowercase)
        if (host.contains('youtu.be')) {
          // Check of youtu.be domain
          final segs = uri.pathSegments; // Haalt path segments op
          if (segs.isNotEmpty) return segs.last; // Return laatst segment
        } // Einde youtu.be check
        final embedIndex = uri.pathSegments.indexWhere(
          (s) => s == 'embed',
        ); // Zoekt 'embed' in path
        if (embedIndex >= 0 && uri.pathSegments.length > embedIndex + 1)
          return uri.pathSegments[embedIndex + 1]; // Return ID na 'embed'
      } // Einde uri null check
    } catch (_) {} // Catch en ignore errors
    final vidMatch = RegExp(
      r'(?:v=|youtu\.be/|embed/)([A-Za-z0-9_-]{6,})',
    ).firstMatch(r); // Regex match voor YouTube ID
    if (vidMatch != null) return vidMatch.group(1); // Return matched ID
    return r; // Return origineel als fallback
  } // Einde _normalizeYoutubeId functie

  Widget _buildServiceIconAsset(
    String? serviceName, {
    double height = 28,
    required BuildContext context,
  }) {
    // Functie om service icon te bouwen
    if (serviceName == null)
      return const Icon(Icons.tv); // Return TV icoon als serviceName null
    final key = _serviceAssetMap.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == serviceName.toLowerCase(),
          orElse: () => const MapEntry('', ''),
        )
        .value; // Zoekt service in map
    if (key.isEmpty)
      return const Icon(Icons.tv); // Return TV icoon als niet gevonden
    final isDark =
        Theme.of(context).brightness == Brightness.dark; // Check of dark mode
    final folder = isDark
        ? 'dark'
        : 'light'; // Selecteert folder op basis van theme
    final path = 'assets/logos/$folder/$key.png'; // Bouwt asset path
    return Image.asset(path, height: height); // Return afbeelding asset
  } // Einde _buildServiceIconAsset functie

  Future<String?> _fetchTmdbPosterFromRapid(Map<String, dynamic> rapid) async {
    // Async functie om TMDb poster te fetchen
    try {
      // Start try block
      final tmdbIdRaw = rapid['tmdbId']?.toString(); // Haalt tmdbId op
      if (tmdbIdRaw == null || tmdbIdRaw.isEmpty) {
        // Check of tmdbId leeg is
        debugPrint('No tmdbId present in rapid data'); // Debug message
        return null; // Return null
      } // Einde tmdbId check
      final parts = tmdbIdRaw.split('/'); // Split op slash
      final movieId = parts.length > 1
          ? parts.last
          : tmdbIdRaw; // Haalt nummer deel
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          .replace(
            queryParameters: {'type': 'tmdb-images', 'movie_id': movieId},
          ); // Bouwt API URL
      debugPrint('Fetching TMDb images from backend: $uri'); // Debug message
      await _ensureEnvLoaded(); // Laadt environment variables
      final headers = <String, String>{}; // Initialiseert headers
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!; // Voegt API key toe
      final resp = await http.get(
        uri,
        headers: headers,
      ); // Stuurt HTTP GET request
      if (resp.statusCode != 200) {
        // Check of response OK
        debugPrint(
          'tmdb-images request failed: ${resp.statusCode}',
        ); // Debug message
        return null; // Return null
      } // Einde statusCode check
      final json =
          jsonDecode(resp.body) as Map<String, dynamic>?; // Decodeert JSON
      if (json == null) return null; // Return null als json null
      final postersRaw = json['posters']; // Haalt posters array op
      final postersList = _toList(
        postersRaw,
      ).cast<Map<String, dynamic>>(); // Zet naar list van maps
      Map<String, dynamic>? chosen; // Variabele voor gekozen poster
      for (final p in postersList) {
        // Loop door posters
        final country = (p['iso_3166_1'] ?? '').toString(); // Haalt land op
        if (country.toUpperCase() == 'US') {
          // Check of US poster
          chosen = p; // Zet als gekozen
          break; // Break loop
        } // Einde land check
      } // Einde poster loop
      chosen ??= postersList.isNotEmpty
          ? postersList.first
          : null; // Fallback naar eerste poster
      if (chosen == null) {
        // Check of poster gekozen
        debugPrint(
          'No posters found from tmdb-images endpoint',
        ); // Debug message
        return null; // Return null
      } // Einde chosen check
      final filePath = chosen['file_path']?.toString(); // Haalt file path op
      if (filePath == null || filePath.isEmpty) {
        // Check of filePath leeg
        debugPrint('Poster file_path empty'); // Debug message
        return null; // Return null
      } // Einde filePath check
      final url =
          'https://image.tmdb.org/t/p/original${filePath}'; // Bouwt TMDb URL
      debugPrint('Using TMDb poster URL: $url'); // Debug message
      return url; // Return URL
    } catch (e, s) {
      // Catch errors
      debugPrint('Error fetching tmdb poster: $e\n$s'); // Debug message
      return null; // Return null
    } // Einde try-catch
  } // Einde _fetchTmdbPosterFromRapid functie

  Future<void> _translateText(String key, String originalText) async {
    // Deze functie vertaalt tekst naar Nederlands via een backend endpoint.
    setState(() => _isTranslating[key] = true);
    // Zet de loading state voor deze tekst op true.

    try {
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          // Bouwt de basis URL voor de API.
          .replace(
            queryParameters: {
              'type': 'translate',
              // Zet het request type op 'translate'.
              'text': originalText,
              // Voegt de originele tekst toe als parameter.
              'target': 'nl',
              // Stelt Nederlands in als doeltaal.
            },
          );

      await _ensureEnvLoaded();
      // Laadt de API key uit de environment variabelen.
      final headers = <String, String>{};
      // Initialiseert een lege headers map.
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // Voegt de API key toe aan de headers als deze beschikbaar is.
      final resp = await http.get(uri, headers: headers);
      // Stuurt een GET request naar de API.
      if (resp.statusCode == 200) {
        // Controleert of het antwoord succesvol was.
        final data = jsonDecode(resp.body);
        // Decodeert het JSON antwoord.
        final translated = data['translation'] ?? data['translatedText'] ?? '';
        // Haalt de vertaalde tekst op uit het antwoord.
        setState(() {
          _translatedTexts[key] = translated.toString();
          // Slaat de vertaalde tekst op in de cache.
        });
      } else {
        debugPrint('Translation failed: ${resp.statusCode}');
        // Print fout als het request niet succesvol was.
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      // Print fout als er een exception optreedt.
    } finally {
      setState(() => _isTranslating[key] = false);
      // Zet de loading state altijd op false na afloop.
    }
  }

  String proxiedUrl(String url) {
    // Converteert een URL naar een proxy URL via de backend.
    return 'https://film-flix-olive.vercel.app/apiv2/movies'
        '?type=image-proxy'
        // Geeft aan dat dit een image proxy request is.
        '&imageUrl=${Uri.encodeComponent(url)}';
    // Voegt de originele afbeelding URL toe, geëncodeerd.
  }

  Future<void> _ensureEnvLoaded() async {
    // Deze functie laadt de environment variabelen uit een bestand.
    if (_xAppApiKey != null) return;
    // Returnt direct als de API key al geladen is.
    try {
      final content = await rootBundle.loadString('assets/env/.env');
      // Laadt het .env bestand uit de assets.
      final lines = const LineSplitter().convert(content);
      // Splitst de content in aparte regels.
      for (final line in lines) {
        // Loop door elke regel in het bestand.
        final trimmed = line.trim();
        // Verwijdert whitespace van de regel.
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        // Slaat lege regels en comments over.
        final idx = trimmed.indexOf('=');
        // Zoekt het gelijkteken (=) in de regel.
        if (idx <= 0) continue;
        // Slaat regels zonder = over.
        final key = trimmed.substring(0, idx).trim();
        // Extraheert het deel vóór het = teken.
        final value = trimmed.substring(idx + 1).trim();
        // Extraheert het deel na het = teken.
        if (key == 'X_APP_API_KEY') {
          // Zoekt naar de X_APP_API_KEY regel.
          _xAppApiKey = value;
          // Slaat de waarde op in de instance variabele.
          break;
          // Stopt het laden zodra de API key is gevonden.
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to load .env: $e');
      // Print debugging info als het laden van het bestand mislukt.
    }
  }

  Future<Uint8List?> _fetchProxiedImageBytes(String originalUrl) async {
    // Deze functie haalt afbeeldingen op via de proxy en cacht ze.
    if (_imageCache.containsKey(originalUrl)) return _imageCache[originalUrl];
    // Returnt de afbeelding direct als deze al in cache zit.
    await _ensureEnvLoaded();
    // Zorg dat de API key geladen is.
    try {
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          // Bouwt de basis URL voor de API.
          .replace(
            queryParameters: {'type': 'image-proxy', 'imageUrl': originalUrl},
            // Voegt parameters toe voor afbeelding proxy.
          );
      final headers = <String, String>{};
      // Initialiseert een lege headers map.
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) {
        headers['x-app-api-key'] = _xAppApiKey!;
        // Voegt de API key toe als deze beschikbaar is.
      }
      final resp = await http.get(uri, headers: headers);
      // Stuurt een GET request naar de proxy.
      if (resp.statusCode == 200) {
        // Controleert of het antwoord succesvol was.
        _imageCache[originalUrl] = resp.bodyBytes;
        // Cacht de afbeelding bytes.
        return resp.bodyBytes;
        // Returnt de afbeelding bytes.
      }
    } catch (e) {
      debugPrint('Error fetching proxied image: $e');
      // Print fout als het ophalen van de afbeelding mislukt.
    }
    return null;
    // Returnt null als het ophalen niet succesvol was.
  }

  Widget _imageFromProxied(
    // Deze functie bouwt een widget die een afbeelding via proxy laadt.
    String originalUrl, {
    BoxFit fit = BoxFit.cover,
    // Standaard fit type voor de afbeelding.
    double? width,
    // Optionele breedte van de afbeelding.
    double? height,
    // Optionele hoogte van de afbeelding.
  }) {
    return FutureBuilder<Uint8List?>(
      // Bouwt de widget asynchroon op basis van de afbeelding bytes.
      future: _fetchProxiedImageBytes(originalUrl),
      // Haalt de afbeelding bytes op via de proxy.
      builder: (ctx, snap) {
        // Bouwt de widget op basis van de Future status.
        if (snap.connectionState == ConnectionState.waiting) {
          // Checkt of de Future nog bezig is.
          return Container(
            width: width,
            // Zet de breedte van de container.
            height: height,
            // Zet de hoogte van de container.
            color: Colors.grey.shade200,
            // Zet de achtergrondkleur.
            child: const Center(child: CircularProgressIndicator()),
            // Toont een laadspinner in het midden.
          );
        }
        final bytes = snap.data;
        // Haalt de afbeelding bytes op.
        if (bytes != null && bytes.isNotEmpty) {
          // Checkt of de bytes beschikbaar zijn.
          return Image.memory(bytes, fit: fit, width: width, height: height);
          // Toont de afbeelding uit de bytes.
        }
        return Container(
          width: width,
          // Zet de breedte van de fallback container.
          height: height,
          // Zet de hoogte van de fallback container.
          color: Colors.grey.shade300,
          // Zet een grijze achtergrondkleur.
          child: const Center(child: Icon(Icons.broken_image, size: 48)),
          // Toont een kapot afbeeldings icoon.
        );
      },
    );
  }

  Widget _posterWithFallback(
    // Deze functie bouwt een poster widget met fallback opties.
    BuildContext context,
    // De build context voor theming.
    String? initialPoster,
    // De initiële poster URL.
    Map<String, dynamic> rapid,
    // De RapidAPI data voor fallback posters.
  ) {
    const double posterHeight = 600.0;
    // Zet de hoogte van de poster op 600 pixels.

    if (initialPoster == null || initialPoster.isEmpty) {
      // Checkt of er geen initiële poster is opgegeven.
      return FutureBuilder<String?>(
        // Bouwt de widget asynchroon op basis van TMDb poster.
        future: _fetchTmdbPosterFromRapid(rapid),
        // Haalt TMDb poster op.
        builder: (ctx, snap) {
          // Bouwt de widget op basis van de Future status.
          if (snap.connectionState == ConnectionState.waiting) {
            // Checkt of de Future nog bezig is.
            return Container(
              height: posterHeight,
              // Zet de hoogte.
              width: double.infinity,
              // Zet de volle breedte.
              color: Colors.grey.shade200,
              // Zet een grijze achtergrondkleur.
              child: const Center(child: CircularProgressIndicator()),
              // Toont een laadspinner.
            );
          }
          final url = snap.data;
          // Haalt de poster URL op.
          if (url != null && url.isNotEmpty) {
            // Checkt of de URL beschikbaar is.
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // Rondt de hoeken af.
              child: _imageFromProxied(
                url,
                // Laadt de afbeelding via proxy.
                fit: BoxFit.cover,
                // Vulde volledige ruimte.
                height: posterHeight,
                // Zet de hoogte.
                width: double.infinity,
                // Zet de volle breedte.
              ),
            );
          }
          return Container(
            height: posterHeight,
            // Zet de hoogte.
            width: double.infinity,
            // Zet de volle breedte.
            color: Colors.grey.shade300,
            // Zet een donkergrijze achtergrondkleur.
            child: const Center(child: Icon(Icons.broken_image, size: 48)),
            // Toont een kapot afbeeldings icoon.
          );
        },
      );
    }

    // We have an initial poster URL. Try to load it; on error fetch TMDb fallback.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      // Rondt de hoeken af.
      child: FutureBuilder<Uint8List?>(
        // Bouwt de widget asynchroon op basis van poster bytes.
        future: _fetchProxiedImageBytes(initialPoster),
        // Haalt de initiële poster bytes op.
        builder: (ctx, snap) {
          // Bouwt de widget op basis van de Future status.
          if (snap.connectionState == ConnectionState.waiting) {
            // Checkt of de Future nog bezig is.
            return Container(
              height: posterHeight,
              // Zet de hoogte.
              width: double.infinity,
              // Zet de volle breedte.
              color: Colors.grey.shade200,
              // Zet een lichte grijze achtergrondkleur.
              child: const Center(child: CircularProgressIndicator()),
              // Toont een laadspinner.
            );
          }
          final bytes = snap.data;
          // Haalt de afbeelding bytes op.
          if (bytes != null && bytes.isNotEmpty) {
            // Checkt of de bytes beschikbaar zijn.
            return Image.memory(
              bytes,
              // Toont de afbeelding uit de bytes.
              fit: BoxFit.cover,
              // Vulde volledige ruimte.
              height: posterHeight,
              // Zet de hoogte.
              width: double.infinity,
              // Zet de volle breedte.
            );
          }

          // fallback to TMDb
          return FutureBuilder<String?>(
            // Bouwt fallback widget asynchroon op basis van TMDb poster.
            future: _fetchTmdbPosterFromRapid(rapid),
            // Haalt TMDb poster op als fallback.
            builder: (ctx2, snap2) {
              // Bouwt de widget op basis van de Future status.
              if (snap2.connectionState == ConnectionState.waiting) {
                // Checkt of de Future nog bezig is.
                return Container(
                  height: posterHeight,
                  // Zet de hoogte.
                  width: double.infinity,
                  // Zet de volle breedte.
                  color: Colors.grey.shade200,
                  // Zet een lichte grijze achtergrondkleur.
                  child: const Center(child: CircularProgressIndicator()),
                  // Toont een laadspinner.
                );
              }
              final url2 = snap2.data;
              // Haalt de TMDb poster URL op.
              if (url2 != null && url2.isNotEmpty) {
                // Checkt of de URL beschikbaar is.
                return _imageFromProxied(
                  url2,
                  // Laadt de afbeelding via proxy.
                  fit: BoxFit.cover,
                  // Vulde volledige ruimte.
                  height: posterHeight,
                  // Zet de hoogte.
                  width: double.infinity,
                  // Zet de volle breedte.
                );
              }
              return Container(
                height: posterHeight,
                // Zet de hoogte.
                width: double.infinity,
                // Zet de volle breedte.
                color: Colors.grey.shade300,
                // Zet een donkergrijze achtergrondkleur.
                child: const Center(child: Icon(Icons.broken_image, size: 48)),
                // Toont een kapot afbeeldings icoon.
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    // Deze methode initialiseert de state van de screen als deze wordt aangemaakt.
    super.initState();
    // Roept de parent initState aan.
    _user = FirebaseAuth.instance.currentUser;
    // Haalt de huidige ingelogde gebruiker op.

    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      // Luistert naar veranderingen in de auth status.
      setState(() {
        _user = u;
        // Updatet de user wanneer deze verandert.
      });
      if (u != null)
        _loadUserData();
      // Laadt user data als iemand inlogt.
      else {
        setState(() {
          // Zet hier ook setState als opmerking voor artikel
          _isInWatchlist = false;
          // Reset watchlist status bij uitloggen.
          _seenSet.clear();
          // Wist alle gezien afleveringen bij uitloggen.
        });
      }
    });
    if (_user != null) _loadUserData();
    // Laadt user data als er al iemand ingelogd is.

    _loadMovie();
    // Laadt de film details.
  }

  Future<void> _loadMovie() async {
    // Deze functie laadt de film details van meerdere API's.
    try {
      setState(() {
        _loadingMovie = true;
        // Zet loading state op true.
        _error = null;
        // Resetst de error message.
      });

      final omdbFuture = MovieApi.omdbGet(imdbId: widget.imdbId, plot: 'full');
      // Haalt film data op van OMDb API.
      final showFuture = MovieRepository.getRapidDetailsShow(widget.imdbId);
      // Haalt show data op van RapidAPI (parallel).
      final episodeFuture = MovieRepository.getRapidDetailsEpisode(
        widget.imdbId,
      );
      // Haalt episode data op van RapidAPI (parallel).

      // Zodra één van de Rapid futures als eerste binnen is, gebruiken we die om
      // direct iets te tonen.
      final firstRapid = await Future.any([showFuture, episodeFuture]);
      // Wacht tot de eerste Rapid response aankomt.
      final omdb = await omdbFuture;
      // Wacht tot de OMDb response aankomt.

      void applyRapidAndOmdb(
        Map<String, dynamic> rapid,
        Map<String, dynamic>? omdbData,
      ) {
        // Dit is een helper functie om data van beide API's toe te passen.
        final poster =
            (rapid['imageSet']?['verticalPoster']?['w480'] ??
                    rapid['imageSet']?['verticalPoster']?['w300'] ??
                    omdbData?['Poster'])
                ?.toString();
        // Haalt de beste beschikbare poster URL op.

        final rapidGenres = _toList(rapid['genres'])
            .map(
              (g) => (g is Map && g.containsKey('name') ? g['name'] : g)
                  .toString(),
            )
            .toSet();
        // Extraheert genres uit RapidAPI data.

        final omdbGenresRaw = omdbData?['Genre']?.toString() ?? '';
        // Haalt genres op uit OMDb data.
        final omdbGenres = omdbGenresRaw
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toSet();
        // Splitst en filtert OMDb genres.

        setState(() {
          _rapidData = rapid;
          // Slaat RapidAPI data op.
          _omdbData = omdbData;
          // Slaat OMDb data op.
          _poster = poster;
          // Slaat poster URL op.
          _title = (rapid['title'] ?? omdbData?['Title'] ?? '').toString();
          // Zet de film titel.
          _overview = (rapid['overview'] ?? omdbData?['Plot'] ?? '').toString();
          // Zet de film beschrijving.
          _rating =
              (omdbData?['imdbRating'] ?? rapid['rating']?.toString() ?? '-')
                  .toString();
          // Zet de film rating.
          _rated = omdbData?['Rated']?.toString();
          // Zet de ouderlijke waarschuwing.

          _genres = {...rapidGenres, ...omdbGenres}.toList();
          // Combineert genres van beide API's.

          _creators = _toList(
            rapid['creators'],
          ).map((c) => c.toString()).toList();
          // Extraheert creators/producers.
          _cast = _toList(rapid['cast']).map((c) => c.toString()).toList();
          // Extraheert cast/acteurs.
          _seasons = _toList(rapid['seasons']);
          // Extraheert seizoen data.
          _streaming = _toList(rapid['streamingOptions']?['nl']);
          // Extraheert Nederlandse streaming opties.

          // Voor films: we tonen zoekopties naar bioscopen (Biosagenda en Kinepolis)
          // We voegen geen generieke 'Bioscoop' service meer toe aan _streaming;
          // de UI voegt aparte chips toe in _buildGroupedStreaming op basis van _title.

          _loadingMovie = false;
          // Zet loading state op false.
        });

        // Debug: toon waar we 'movie' van hebben gedetecteerd
        try {
          final omdbType = omdbData?['Type']?.toString();
          // Haalt type uit OMDb data.
          final rapidTypes = [
            rapid['itemType'],
            rapid['type'],
            rapid['showType'],
            rapid['titleType'],
          ].where((e) => e != null).map((e) => e.toString()).toList();
          // Haalt mogelijke types uit RapidAPI data.
          debugPrint('Detected types - OMDb: $omdbType  Rapid: $rapidTypes');
          // Print voor debugging.
        } catch (e) {
          debugPrint('Error printing detected types: $e');
          // Print error als debug print mislukt.
        }
      }

      // apply first rapid result immediately
      applyRapidAndOmdb(
        firstRapid as Map<String, dynamic>,
        omdb as Map<String, dynamic>?,
      );
      // Past de eerste Rapid response direct toe.

      // load trailers (movie or tv) async
      _loadVideos().catchError((e) => debugPrint('Videos load error: $e'));
      // Laadt trailers asynchroon.

      // Wanneer de andere Rapid-response arriveert, merge/update de UI met aanvullende info.
      showFuture
          .then((showRapid) {
            if (firstRapid != showRapid) {
              applyRapidAndOmdb(
                showRapid as Map<String, dynamic>,
                omdb as Map<String, dynamic>?,
              );
              // Past de second Rapid response toe als deze anders is.
            }
          })
          .catchError((e) => debugPrint('Show fetch error: $e'));
      // Haalt show data op als deze aankomt.

      episodeFuture
          .then((episodeRapid) {
            if (firstRapid != episodeRapid) {
              applyRapidAndOmdb(
                episodeRapid as Map<String, dynamic>,
                omdb as Map<String, dynamic>?,
              );
              // Past de second Rapid response toe als deze anders is.
            }
          })
          .catchError((e) => debugPrint('Episode fetch error: $e'));
      // Haalt episode data op als deze aankomt.
    } catch (e, s) {
      debugPrint('Error loading movie: $e\n$s');
      // Print error als het laden mislukt.
      setState(() {
        _error = e.toString();
        // Sla de error op.
        _loadingMovie = false;
        // Zet loading state op false.
      });
    }
  }

  @override
  void dispose() {
    // Deze methode ruimt resources op wanneer de screen wordt gesloten.
    _authSub?.cancel();
    // Zegt de auth listener op.
    super.dispose();
    // Roept de parent dispose aan.
  }

  Future<void> _loadUserData() async {
    // Deze functie laadt gebruikersspecifieke data zoals watchlist en gezien afleveringen.
    final u = FirebaseAuth.instance.currentUser;
    // Haalt de huidige gebruiker op.
    if (u == null) return;
    // Returnt als er geen gebruiker is ingelogd.
    setState(() {
      // Zet hier setState als opmerking
      _loadingUserData = true;
      // Zet loading state op true.
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .get();
      // Haalt het gebruikersdocument op uit Firestore.
      final data = doc.data() ?? {};
      // Haalt de data uit het document, of een lege map.
      debugPrint('--- DEBUG USER DATA FOR ${widget.imdbId} ---');
      // Print debugging info.
      debugPrint('Firestore keys: ${data.keys.toList()}');
      // Print alle sleutels in de data.

      final watchlist =
          (data['watchlist']
              is List) // We controleren of het 'watchlist' veld in de data een lijst is.
          ? List<String>.from(data['watchlist'])
          // Zet watchlist om naar List<String> als dat een lijst is.
          : <String>[];
      // Gebruik een lege lijst als fallback.

      // Robuuste check voor seenEpisodes (genest of plat veld)
      final seenMap = data['seenEpisodes'];
      // Haalt de seenEpisodes map op.
      List<dynamic> rawSeen = [];
      // Initialiseert de lege seen episodes lijst.

      // probeer eerst platte keys (zoals 'seenEpisodes.tt0944947' of 'seenEpisodes.TT0944947')
      final flatKey = 'seenEpisodes.${widget.imdbId}';
      // Bouwt de platte sleutel met standaard casing.
      final flatKeyLower = 'seenEpisodes.${widget.imdbId.toLowerCase()}';
      // Bouwt de platte sleutel met lowercase casing.

      if (data.containsKey(flatKey) && data[flatKey] is List) {
        rawSeen = data[flatKey];
        // Gebruikt platte sleutel met standaard casing.
      } else if (data.containsKey(flatKeyLower) && data[flatKeyLower] is List) {
        rawSeen = data[flatKeyLower];
        // Gebruikt platte sleutel met lowercase casing.
      }
      // Als we geen platte keys vinden, kijk dan of 'seenEpisodes' zelf een map is waar de imdbId als key in voorkomt
      else if (seenMap is Map) {
        final entry =
            seenMap[widget.imdbId] ??
            seenMap[widget.imdbId.toLowerCase()] ??
            seenMap[widget.imdbId.toUpperCase()];
        // Zoekt de imdbId in verschillende casings.
        if (entry is List)
          rawSeen = entry;
        // Gebruikt de entry als deze een lijst is.
        else if (entry is Map)
          rawSeen = entry.values.toList();
        // Converteert map values naar lijst.
      }

      final imdbSeenList = rawSeen.map((e) => e.toString().trim()).toList();
      // Converteert alle items naar strings en verwijdert whitespace.
      debugPrint('Found seen items: $imdbSeenList');
      // Print de gevonden seen items.

      // check seenFilm.<imdbId> as nested map or dotted key
      bool isSeenFilm = false;
      // Initialiseert de seen film boolean.
      try {
        if (data.containsKey('seenFilm') && data['seenFilm'] is Map) {
          // Checkt of seenFilm een geneste map is.
          final sf = data['seenFilm'] as Map;
          // Cast seenFilm naar Map.
          if (sf.containsKey(widget.imdbId)) {
            // Checkt of de imdbId in de map zit.
            isSeenFilm = sf[widget.imdbId] == true;
            // Zet isSeenFilm op basis van de waarde.
          }
        }
        // fallback: dotted key
        if (!isSeenFilm && data.containsKey('seenFilm.${widget.imdbId}')) {
          // Checkt als fallback voor platte sleutel.
          isSeenFilm = data['seenFilm.${widget.imdbId}'] == true;
          // Zet isSeenFilm op basis van de platte sleutel.
        }
      } catch (e) {
        debugPrint('Error reading seenFilm flag: $e');
        // Print error als het uitlezen mislukt.
      }

      setState(() {
        // Zet hier setState als opmerking
        _isInWatchlist = watchlist.contains(widget.imdbId);
        // Controleert of de imdbId in de watchlist zit.
        _seenSet.clear();
        // Wist alle eerder geladen seen items.
        _seenSet.addAll(imdbSeenList);
        // Voegt alle nieuwe seen items toe.
        // Zorg dat de 'movie'-sleutel op filmoniveau de seenFilm-flag weerspiegelt
        // zodat de 'Gezien'-checkbox de juiste status toont, ongeacht hoe de
        // data is opgeslagen (seenFilm map vs seenEpisodes lijst).
        if (isSeenFilm)
          _seenSet.add('movie');
        // Voegt 'movie' toe als de film als gezien is gemarkeerd.
        else
          _seenSet.remove('movie');
        // Verwijdert 'movie' als de film niet als gezien is gemarkeerd.
      });
    } catch (e, s) {
      debugPrint('Error loading user data: $e\n$s');
      // Print error als het laden van user data mislukt.
    } finally {
      setState(() {
        _loadingUserData = false;
        // Zet loading state altijd op false.
      });
    }
  }

  Future<bool> _ensureLoggedInWithPrompt(BuildContext context) async {
    // Functie om te controleren of gebruiker ingelogd is, anders prompt tonen
    if (_user != null) return true; // Return true als gebruiker al ingelogd is

    final result = await showDialog<bool>(
      // Toon dialoog met login prompt
      context: context,
      builder: (ctx) {
        return AlertDialog(
          // Bouw AlertDialog widget
          title: Text(
            AppLocalizations.of(context)!.login_required_title,
          ), // Toon dialog titel
          content: Text(
            AppLocalizations.of(context)!.login_required_message,
          ), // Toon dialog bericht
          actions: [
            // Definieer knoppen in dialog
            TextButton(
              // Maak cancel knop
              onPressed: () =>
                  Navigator.of(ctx).pop(false), // Close dialog en return false
              child: Text(
                AppLocalizations.of(context)!.cancel,
              ), // Toon cancel tekst
            ),
            TextButton(
              // Maak login knop
              onPressed: () =>
                  Navigator.of(ctx).pop(true), // Close dialog en return true
              child: Text(
                AppLocalizations.of(context)!.goto_login,
              ), // Toon login tekst
            ),
          ],
        );
      },
    );

    if (result != true || !mounted)
      return false; // Return false als dialog geannuleerd of widget unmounted

    final loggedIn = await Navigator.of(context).push<bool>(
      // Push LoginScreen en wacht op resultaat
      MaterialPageRoute(
        // Maak navigatie route
        builder: (_) => const LoginScreen(
          returnAfterLogin: true,
        ), // Bouw LoginScreen widget
        fullscreenDialog: true, // Toon als fullscreen dialog
      ),
    );

    if (loggedIn == true && mounted) {
      // Check of inloggen succesvol en widget nog mounted
      _user = FirebaseAuth.instance.currentUser; // Update huidige gebruiker
      if (_user != null) await _loadUserData(); // Laad user data als ingelogd
      return _user != null; // Return of gebruiker succesvol ingelogd is
    }

    return false; // Return false als inloggen mislukt
  }

  Future<void> _toggleWatchlist() async {
    // Functie om film aan/van watchlist toe te voegen
    final u = FirebaseAuth.instance.currentUser; // Haal huidige gebruiker op
    if (u == null) return; // Return als geen gebruiker ingelogd

    final newState = !_isInWatchlist; // Bepaal nieuwe watchlist staat (toggle)

    setState(
      () => _isInWatchlist = newState,
    ); // Update UI optimistisch naar nieuwe staat

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid); // Referentie naar user document
    try {
      if (newState) {
        // Als toevoegen aan watchlist
        final meta = {
          // Bouw metadata object met film info
          'title': _title ?? '',
          'overview': _overview ?? '',
          'mediaType': _detectMediaType(),
          'genres': _genres,
          'savedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set({
          // Update Firestore document
          'watchlist': FieldValue.arrayUnion([
            widget.imdbId,
          ]), // Voeg imdbId aan watchlist array toe
          'watchlist_meta.${widget.imdbId}':
              meta, // Sla metadata op voor sneller laden
        }, SetOptions(merge: true)); // Merge met bestaande data
      } else {
        // Als verwijderen van watchlist
        await docRef.set({
          // Update Firestore document
          'watchlist': FieldValue.arrayRemove([
            widget.imdbId,
          ]), // Verwijder imdbId uit watchlist
          'watchlist_meta.${widget.imdbId}':
              FieldValue.delete(), // Verwijder metadata
        }, SetOptions(merge: true)); // Merge met bestaande data
      }
    } catch (e, s) {
      // Catch fouten
      debugPrint('Error toggling watchlist: $e\n$s'); // Print error
      setState(
        () => _isInWatchlist = !newState,
      ); // Zet UI terug naar vorige staat
      ScaffoldMessenger.of(context).showSnackBar(
        // Toon error snackbar
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.watchlist_update_failed,
          ), // Toon foutbericht
        ),
      );
    }
  }

  Future<void> _toggleEpisodeSeen(String epKey, bool seen) async {
    // Functie om aflevering als gezien te markeren
    final u = FirebaseAuth.instance.currentUser; // Haal huidige gebruiker op
    if (u == null) return; // Return als geen gebruiker ingelogd

    setState(() {
      // Start state update
      if (seen) {
        // Als aflevering gezien
        _seenSet.add(epKey); // Voeg aflevering toe aan seen set
      } else {
        // Als aflevering niet gezien
        _seenSet.remove(epKey); // Verwijder aflevering uit seen set
      }
    }); // Einde state update

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid); // Referentie naar user document
    try {
      if (seen) {
        // Als aflevering markeren als gezien
        final meta = {
          // Bouw metadata object
          'title': _title ?? '',
          'overview': _overview ?? '',
          'mediaType': _detectMediaType(),
          'genres': _genres,
          'savedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set({
          // Update Firestore document
          'seenEpisodes.${widget.imdbId}': FieldValue.arrayUnion([
            epKey,
          ]), // Voeg episode key toe
          'watchlist_meta.${widget.imdbId}': meta, // Sla metadata op
        }, SetOptions(merge: true)); // Merge met bestaande data
      } else {
        // Als aflevering markeren als niet gezien
        await docRef.set({
          // Update Firestore document
          'seenEpisodes.${widget.imdbId}': FieldValue.arrayRemove([
            epKey,
          ]), // Verwijder episode key
        }, SetOptions(merge: true)); // Merge met bestaande data
      }
    } catch (e, s) {
      // Catch fouten
      debugPrint('Error toggling episode seen: $e\n$s'); // Print error
      setState(() {
        // Start state update
        if (seen) {
          // Als we gezien hadden toegevoegd
          _seenSet.remove(epKey); // Verwijder terug
        } else {
          // Als we gezien hadden verwijderd
          _seenSet.add(epKey); // Voeg terug toe
        }
      }); // Einde state update
      ScaffoldMessenger.of(context).showSnackBar(
        // Toon error snackbar
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.episode_status_update_failed, // Toon foutbericht
          ),
        ),
      );
    }
  }

  Future<void> _toggleMovieSeen(bool seen) async {
    // Functie om film als gezien te markeren
    final u = FirebaseAuth.instance.currentUser; // Haal huidige gebruiker op
    if (u == null) return; // Return als geen gebruiker ingelogd

    const epKey = 'movie'; // Definieer aflevering key als 'movie' voor films

    setState(() {
      // Start state update
      if (seen) {
        // Als film gezien
        _seenSet.add(epKey); // Voeg 'movie' toe aan seen set
      } else {
        // Als film niet gezien
        _seenSet.remove(epKey); // Verwijder 'movie' uit seen set
      }
    }); // Einde state update

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(u.uid); // Referentie naar user document
    try {
      if (seen) {
        // Als film markeren als gezien
        final meta = {
          // Bouw metadata object
          'title': _title ?? '',
          'overview': _overview ?? '',
          'mediaType': _detectMediaType(),
          'genres': _genres,
          'savedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set({
          // Update Firestore document
          'seenEpisodes.${widget.imdbId}': FieldValue.arrayUnion([
            epKey,
          ]), // Voeg 'movie' key toe
          'watchlist_meta.${widget.imdbId}': meta, // Sla metadata op
        }, SetOptions(merge: true)); // Merge met bestaande data
      } else {
        // Als film markeren als niet gezien
        await docRef.set({
          // Update Firestore document
          'seenEpisodes.${widget.imdbId}':
              FieldValue.delete(), // Verwijder hele field
        }, SetOptions(merge: true)); // Merge met bestaande data
      }
    } catch (e, s) {
      // Catch fouten
      debugPrint('Error toggling movie seen: $e\n$s'); // Print error
      setState(() {
        // Start state update
        if (seen) // Als we gezien hadden toegevoegd
          _seenSet.remove(epKey); // Verwijder terug
        else // Als we gezien hadden verwijderd
          _seenSet.add(epKey); // Voeg terug toe
      }); // Einde state update
      ScaffoldMessenger.of(context).showSnackBar(
        // Toon error snackbar
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.movie_seen_update_failed,
          ), // Toon foutbericht
        ),
      );
    }
  }

  List<Widget> _buildGroupedStreaming(
    List<dynamic> streaming,
    BuildContext context,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped =
        {}; // Maakt een map aan die streaming services groepeert met hun opties.

    for (final item in streaming) {
      // Loop door elk streaming item in de lijst.
      if (item is! Map) continue; // Sla items over die geen Map zijn.
      final typedItem =
          item as Map<String, dynamic>; // Cast het item naar een Map.
      final service =
          typedItem['service']
              as Map<String, dynamic>?; // Haalt de service map op.
      final name =
          service?['name']?.toString() ??
          'Service'; // Haalt de servicenaam op, of gebruikt 'Service' als fallback.

      grouped.putIfAbsent(
        name,
        () => [],
      ); // Voegt de servicenaam toe als key als deze nog niet bestaat.
      grouped[name]!.add(
        typedItem,
      ); // Voegt het item toe aan de lijst van die service.
    }

    final rapidTypeCandidates = [
      // Maakt een lijst met mogelijke type velden uit de RapidAPI data.
      _rapidData?['itemType'],
      _rapidData?['type'],
      _rapidData?['showType'],
      _rapidData?['titleType'],
    ];
    final bool
    isMovieResponse = // Bepaalt of het een film is op basis van type velden.
        _isResponseMovie(_omdbData?['Type']?.toString()) ||
        rapidTypeCandidates.any((t) => _isResponseMovie(t?.toString()));

    if (isMovieResponse) {
      // Als het een film is, voeg bioscoop links toe.
      final l10n = AppLocalizations.of(context);
      final biosLink = // Bouwt de Biosagenda zoeklink met de filmtitel.
          'https://www.biosagenda.nl/zoeken?q=${Uri.encodeComponent(_title ?? '')}';
      final kinepolisLink = // Bouwt de Kinepolis zoeklink met de filmtitel.
          'https://kinepolis.nl/search/movies?search=${Uri.encodeComponent(_title ?? '')}';
      grouped.putIfAbsent(
        // Voegt 'Bioscoop' groep toe met beide links.
        'Bioscoop',
        () => [
          {
            'type': 'biosagenda',
            'link': biosLink,
            'label': l10n?.label_biosagenda ?? 'Biosagenda',
          },
          {
            'type': 'kinepolis',
            'link': kinepolisLink,
            'label': l10n?.label_kinepolis ?? 'Kinepolis',
          },
        ],
      );
    }

    final List<Widget> widgets =
        []; // Initialiseert de lege lijst voor widgets.
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Bepaalt of dark mode actief is.

    grouped.forEach((serviceName, options) {
      // Loop door elke service en haar opties.
      options.sort(
        // Sorteert de opties op type prioriteit.
        (a, b) => _typePriority(a['type']) - _typePriority(b['type']),
      );

      final Map<String, Map<String, dynamic>> uniqueOptions =
          {}; // Map voor unieke opties per type.
      for (var option in options) {
        // Loop door elke optie.
        final type =
            option['type']?.toString() ??
            'other'; // Haalt het type op, of gebruikt 'other'.

        if (serviceName ==
                'Bioscoop' && // Als het een bioscoop is en geen link heeft, sla over.
            (option['link'] == null || option['link'].toString().isEmpty)) {
          continue;
        }

        uniqueOptions.putIfAbsent(
          type,
          () => option,
        ); // Voegt optie toe als deze type nog niet bestaat.
      }

      if (uniqueOptions.isEmpty) return; // Sla services over zonder opties.

      widgets.add(
        // Voegt widget toe voor deze service.
        Padding(
          // Voegt padding toe rond de service widget.
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            // Maakt een verticale kolom voor service info.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // Maakt een rij voor service logo en naam.
                children: [
                  _buildServiceIconAsset(
                    // Toont het service logo.
                    serviceName,
                    context: context,
                    height: 26,
                  ),
                  const SizedBox(
                    width: 8,
                  ), // Voegt ruimte tussen logo en naam toe.

                  Text(
                    // Toont de servicenaam.
                    serviceName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ), // Voegt ruimte tussen naam en opties toe.
              Wrap(
                // Maakt eenWrapper voor de optie chips.
                spacing: 6,
                runSpacing: 6,
                children: uniqueOptions.values.map((option) {
                  // Loop door elke unieke optie.
                  final link =
                      option['link'] ??
                      option['service']?['homePage']; // Haalt de link op.

                  final chip =
                      (serviceName ==
                          'Bioscoop') // Bepaalt chip type (bioscoop of streaming).
                      ? Chip(
                          label: Text(
                            option['label']?.toString() ??
                                'Bioscoop', // Toont bioscoop naam.
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                        )
                      : _buildTypeChip(
                          context,
                          option,
                        ); // Bouwt streaming type chip.

                  return GestureDetector(
                    // Maakt de chip aanklikbaar.
                    onTap: () async {
                      // Wanneer chip wordt geklikt.
                      final url = link?.toString(); // Zet link om naar string.
                      if (serviceName ==
                              'Bioscoop' && // Als biosagenda, toon waarschuwing.
                          option['type']?.toString() == 'biosagenda') {
                        final proceed = await showDialog<bool>(
                          // Toon bevestigingsdialog.
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(
                                context,
                              )!.warning_title, // Toon titel.
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              AppLocalizations.of(
                                // Toon waarschuwingsbericht.
                                context,
                              )!.warning_bioscoop_content,
                            ),
                            actions: [
                              TextButton(
                                // Cancel knop.
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                              ElevatedButton(
                                // Doorgaan knop.
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                  AppLocalizations.of(context)!.continue_label,
                                ),
                              ),
                            ],
                          ),
                        );
                        if (proceed == true &&
                            url != null) // Als bevestigd en URL beschikbaar.
                          await _openLink(url); // Open de link.
                      } else {
                        // Voor andere services.
                        if (url != null)
                          await _openLink(url); // Open de link direct.
                      }
                    },
                    child: chip, // Toon de chip widget.
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    });

    return widgets; // Return de gebouwde widgets lijst.
  }

  Widget _buildSeasonTile(
    // Functie om een seizoen en zijn afleveringen weer te geven.
    BuildContext context,
    dynamic seasonRaw,
    int seasonIndex,
    List seasons,
  ) {
    final season = // Zorg dat season altijd een Map is.
    (seasonRaw is Map)
        ? seasonRaw
        : {'title': seasonRaw.toString()};
    final seasonTitle =
        (season['title'] ??
                season['itemType'] ??
                'Season') // Haalt seizoen titel op.
            .toString();
    final firstYear =
        season['firstAirYear']?.toString() ??
        ''; // Haalt eerste uitzendingsjaar op.
    final lastYear =
        season['lastAirYear']?.toString() ??
        ''; // Haalt laatst uitzendingsjaar op.
    final epRaw = season['episodes']; // Haalt afleveringsdata op.
    final episodes = _toList(epRaw); // Converteert naar een lijst.

    return ExpansionTile(
      // Bouwt expandable tile voor het seizoen.
      title: Text(seasonTitle), // Toon seizoen titel.
      subtitle: Text(
        '$firstYear${lastYear.isNotEmpty ? ' - $lastYear' : ''}',
      ), // Toon jaren.
      children:
          episodes
              .isEmpty // Als geen afleveringen.
          ? [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Geen afleveringen gevonden', // Toon geen afleveringen bericht.
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ]
          : [
              // Anders loop door afleveringen.
              for (var ei = 0; ei < episodes.length; ei++)
                _buildEpisodeRow(context, episodes[ei], seasonIndex, ei),
            ],
    );
  }

  Widget _buildEpisodeRow(
    // Functie om een aflevering rij weer te geven.
    BuildContext context,
    dynamic epRaw,
    int seasonIndex,
    int episodeIndex,
  ) {
    final ep = (epRaw is Map)
        ? epRaw
        : {'title': epRaw.toString()}; // Zorg dat ep altijd een Map is.
    final epTitle = (ep['title'] ?? ep['itemType'] ?? 'Episode')
        .toString(); // Haalt aflevering titel op.
    final epOverview = (ep['overview'] ?? '').toString(); // Haalt overzicht op.

    final epStreamRaw =
        ep['streamingOptions']?['nl'] ??
        ep['streamingOptions']; // Haalt streaming opties op.
    final epStreams = _toList(epStreamRaw); // Converteert naar lijst.
    if (epStreams.isNotEmpty) {
      // Als streaming opties beschikbaar.
      final first = epStreams[0]; // Haalt eerste optie op.
      if (first is Map) {} // Controleer of het een Map is.
    }

    final epThumb = // Haalt afleverings thumbnail op.
        ep['imageSet']?['verticalPoster']?['w160'] ?? ep['image'] ?? null;

    final epKey = // Maakt unieke sleutel voor opslag.
        's${seasonIndex}_e${episodeIndex}';
    _seenSet.contains(epKey); // Controleer of aflevering gezien is.

    return Column(
      children: [
        ListTile(
          // Bouwt ListTile voor aflevering.
          leading:
              epThumb !=
                  null // Als thumbnail beschikbaar.
              ? ClipRRect(
                  // Maak afbeelding met ronde hoeken.
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    // Zet vaste grootte voor thumbnail.
                    width: 84,
                    height: 48,
                    child: _imageFromProxied(
                      // Laadt afbeelding via proxy.
                      epThumb.toString(),
                      fit: BoxFit.cover,
                      width: 84,
                      height: 48,
                    ),
                  ),
                )
              : null,
          title: Text(
            // Toon aflevering titel.
            epTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle:
              epOverview
                  .isNotEmpty // Als overzicht beschikbaar.
              ? Column(
                  // Toon overzicht met vertaal knop.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // Toon overzicht (vertaald of origineel).
                      _translatedTexts[epKey] ?? epOverview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      // Toon vertaal knop.
                      icon:
                          _isTranslating[epKey] ==
                              true // Toon spinner als bezig.
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.translate,
                              size: 16,
                            ), // Toon vertaal icoon.
                      label: Text(
                        AppLocalizations.of(context)!.translate,
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed:
                          _isTranslating[epKey] ==
                              true // Disable als bezig.
                          ? null
                          : () {
                              // Vertaal overzicht.
                              _translateText(epKey, epOverview);
                            },
                    ),
                  ],
                )
              : null,
          trailing: Row(
            // Toon knoppen aan rechterkant.
            mainAxisSize: MainAxisSize.min,
            children: [
              if (epStreams.isNotEmpty) // Als streaming opties beschikbaar.
                IconButton(
                  // Toon play knop.
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    // Open streaming modal.
                    final Map<String, Map<String, dynamic>> deduped =
                        {}; // Dedupeer streaming opties.
                    for (var option in epStreams) {
                      // Loop door opties.
                      if (option is! Map) continue; // Sla niet-maps over.
                      final typedOption =
                          option as Map<String, dynamic>; // Cast naar Map.
                      final serviceName = // Haalt service naam op.
                          typedOption['service']?['name']?.toString() ??
                          'Unknown';
                      final type =
                          typedOption['type']?.toString() ??
                          'other'; // Haalt type op.
                      final key =
                          '${serviceName.toLowerCase()}_$type'; // Maakt unieke key.
                      deduped.putIfAbsent(
                        key,
                        () => typedOption,
                      ); // Voegt toe als niet bestaat.
                    }
                    final mergedStreams = deduped.values
                        .toList(); // Zet naar lijst.

                    showModalBottomSheet(
                      // Toon modal met streaming opties.
                      context: context,
                      builder: (ctx) {
                        return Column(
                          // Bouwt kolom met opties.
                          mainAxisSize: MainAxisSize.min,
                          children: mergedStreams.map<Widget>((option) {
                            // Loop door opties.
                            final service = // Haalt service naam op.
                                option['service']?['name']?.toString() ??
                                'Unknown';
                            final link = // Haalt link op.
                                option['link'] ??
                                option['service']?['homePage']?.toString();
                            return ListTile(
                              // Toon option in ListTile.
                              leading: _buildServiceIconAsset(
                                // Toon service logo.
                                service,
                                context: context,
                                height: 28,
                              ),
                              title: Text(service), // Toon service naam.
                              subtitle: Text(
                                // Toon streaming type.
                                _formatStreamingType(context, option),
                              ),
                              onTap: () {
                                // Wanneer geklikt.
                                Navigator.pop(ctx); // Sluit modal.
                                _openLink(link?.toString()); // Open link.
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),

              Checkbox(
                // Toon checkbox voor gezien.
                value: _seenSet.contains(epKey), // Check of in seen set.
                onChanged: (val) async {
                  // Wanneer checkbox verandert.
                  if (_user == null) {
                    // Als niet ingelogd.
                    final go = await _ensureLoggedInWithPrompt(
                      context,
                    ); // Toon login prompt.
                    if (!go) return; // Annuleer als niet ingelogd.
                  }

                  final newVal = val ?? false; // Bepaal nieuwe waarde.

                  if (newVal) {
                    // Als markeren als gezien.
                    final unseenPrev =
                        <int>[]; // Lijst met onbekeken eerdere afleveringen.
                    for (var p = 0; p < episodeIndex; p++) {
                      // Loop door eerdere afleveringen.
                      final prevKey =
                          's${seasonIndex}_e${p}'; // Maak key voor vorige aflevering.
                      if (!_seenSet.contains(prevKey))
                        unseenPrev.add(p); // Voeg onbekeken toe.
                    }

                    if (unseenPrev.isNotEmpty) {
                      // Als onbekeken afleveringen.
                      final confirm = await showDialog<bool>(
                        // Toon bevestigingsdialog.
                        context: context,
                        builder: (dctx) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!.mark_previous_episodes_title, // Toon titel.
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.mark_previous_episodes_message(
                              // Toon bericht.
                              epTitle,
                              unseenPrev.length,
                              seasonIndex + 1,
                            ),
                          ),
                          actions: [
                            TextButton(
                              // Nee knop.
                              onPressed: () => Navigator.of(dctx).pop(false),
                              child: Text(AppLocalizations.of(context)!.no),
                            ),
                            TextButton(
                              // Ja knop.
                              onPressed: () => Navigator.of(dctx).pop(true),
                              child: Text(AppLocalizations.of(context)!.yes),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        // Als ja geklikt.
                        for (final p in unseenPrev) {
                          // Loop door onbekeken afleveringen.
                          await _toggleEpisodeSeen(
                            // Markeer als gezien.
                            's${seasonIndex}_e${p}',
                            true,
                          );
                        }
                        await _toggleEpisodeSeen(
                          epKey,
                          true,
                        ); // Markeer huidige als gezien.
                        ScaffoldMessenger.of(context).showSnackBar(
                          // Toon snackbar.
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.episodes_marked_seen(
                                unseenPrev.length + 1,
                              ), // Toon aantal.
                            ),
                          ),
                        );
                        setState(() {}); // Rebuild.
                        return;
                      }
                    }
                  }

                  await _toggleEpisodeSeen(
                    epKey,
                    newVal,
                  ); // Toggle aflevering gezien.
                  setState(() {}); // Rebuild.
                },
              ),
            ],
          ),
          onTap:
              epOverview
                  .isNotEmpty // Als overzicht bestaat.
              ? () {
                  // Toon dialog met volledige overzicht.
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final maxHeight =
                          MediaQuery.of(ctx).size.height *
                          0.7; // Bepaal max hoogte.
                      return StatefulBuilder(
                        // Bouwt stateful dialog.
                        builder: (ctx, setDialogState) {
                          return AlertDialog(
                            title: Text(epTitle), // Toon titel.
                            content: ConstrainedBox(
                              // Zet max hoogte.
                              constraints: BoxConstraints(maxHeight: maxHeight),
                              child: SingleChildScrollView(
                                // Maak scrollbaar.
                                child: Column(
                                  // Kolom met inhoud.
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // Toon volledige overzicht.
                                      _translatedTexts[epKey] ?? epOverview,
                                      style: const TextStyle(height: 1.4),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton.icon(
                                      // Vertaal knop.
                                      icon:
                                          _isTranslating[epKey] ==
                                              true // Toon spinner als bezig.
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons
                                                  .translate, // Toon vertaal icoon.
                                              size: 16,
                                            ),
                                      label: Text(
                                        AppLocalizations.of(context)!.translate,
                                      ),
                                      onPressed:
                                          _isTranslating[epKey] ==
                                              true // Disable als bezig.
                                          ? null
                                          : () async {
                                              // Vertaal overzicht.
                                              await _translateText(
                                                epKey,
                                                epOverview,
                                              );
                                              setDialogState(
                                                () {},
                                              ); // Rebuild dialog.
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                // Sluit knop.
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                ),
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
        const Divider(height: 1), // Toon scheidingslijn.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bouwt de UI van het scherm.
    final loc = AppLocalizations.of(context)!; // Haalt taalinstellingen op.
    if (_loadingMovie) {
      // Checkt of film nog wordt geladen.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ); // Toon laadspinner.
    }
    if (_error != null) {
      // Checkt of er een fout is opgetreden.
      final loc = AppLocalizations.of(context)!; // Haalt taalinstellingen op.
      return Scaffold(
        // Bouwt error scherm.
        body: Center(
          child: Text(loc.fetch_error_message(_error ?? '')),
        ), // Toon foutbericht.
      );
    }
    final isMovie = // Bepaalt of dit een film is.
        _isResponseMovie(_omdbData?['Type']?.toString()) ||
        _isResponseMovie(_rapidData?['itemType']?.toString()) ||
        _isResponseMovie(_rapidData?['type']?.toString()) ||
        _isResponseMovie(_rapidData?['showType']?.toString()) ||
        _isResponseMovie(_rapidData?['titleType']?.toString());

    final rapid = _rapidData!; // Haalt RapidAPI data op.
    final poster = _poster; // Haalt poster URL op.
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Checkt of dark mode actief is.

    return AppBackground(
      // Bouwt achtergrond widget.
      child: Scaffold(
        // Bouwt main scaffold.
        backgroundColor: Colors.transparent, // Maakt background transparant.
        appBar: PreferredSize(
          // Bouwt custom top bar.
          preferredSize: const Size.fromHeight(56), // Zet hoogte van top bar.
          child: AppTopBar(
            // Toon custom top bar.
            title: loc.details, // Zet titel.
            backgroundColor:
                Colors.transparent, // Maakt achtergrond transparant.
          ),
        ),
        body: SingleChildScrollView(
          // Maakt content scrollbaar.
          padding: const EdgeInsets.all(12), // Voegt padding toe rond content.
          child: Column(
            // Bouwt verticale kolom.
            crossAxisAlignment:
                CrossAxisAlignment.start, // Lijnt items links uit.
            children: [
              _posterWithFallback(
                context,
                poster,
                rapid,
              ), // Toon poster met fallback.
              // Trailer (YouTube) - show in-app player when available
              if (_loadingTrailer) // Checkt of trailer nog wordt geladen.
                const Padding(
                  // Voegt padding toe.
                  padding: EdgeInsets.only(top: 8.0), // Zet padding.
                  child: Center(
                    // Centreert inhoud.
                    child: SizedBox(
                      // Zet vaste grootte.
                      width: 24, // Zet breedte.
                      height: 24, // Zet hoogte.
                      child: CircularProgressIndicator(), // Toon laadspinner.
                    ),
                  ),
                )
              else if (_trailerKey != null &&
                  _trailerKey!
                      .isNotEmpty) // Checkt of trailer key beschikbaar is.
                Padding(
                  // Voegt padding toe.
                  padding: const EdgeInsets.only(top: 8.0), // Zet padding.
                  child: Column(
                    // Bouwt verticale kolom.
                    children: [
                      YouTubePlayerWidget(
                        // Toon YouTube player.
                        key: ValueKey(_trailerKey), // Zet unieke key.
                        videoId: _trailerKey!, // Zet video ID.
                      ),
                      if (_allVideos.length >
                          1) // Checkt of meer video's beschikbaar zijn.
                        Padding(
                          // Voegt padding toe.
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ), // Zet padding.
                          child: Row(
                            // Bouwt horizontale rij.
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Centreert items.
                            children: [
                              IconButton(
                                // Bouwt vorige knop.
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                ), // Zet pijl icoon.
                                onPressed:
                                    _currentVideoIndex >
                                        0 // Checkt of niet aan begin.
                                    ? () {
                                        // Actie voor vorige video.
                                        final rawKey = // Haalt raw video key op.
                                            _allVideos[_currentVideoIndex -
                                                    1]['key']
                                                ?.toString();
                                        final normKey = // Normaliseert YouTube ID.
                                            _normalizeYoutubeId(rawKey) ??
                                            rawKey;
                                        debugPrint(
                                          // Print debug info.
                                          'Switched trailer (prev) raw: $rawKey, normalized: $normKey, site: ${_allVideos[_currentVideoIndex - 1]['site']}',
                                        );
                                        setState(() {
                                          // Update state.
                                          _currentVideoIndex--; // Lagere video index.
                                          _trailerKey =
                                              normKey; // Zet nieuwe video key.
                                          _trailerSite = // Zet video site.
                                          _allVideos[_currentVideoIndex]['site']
                                              ?.toString();
                                        });
                                      }
                                    : null, // Disable als aan begin.
                              ),
                              Expanded(
                                // Maakt beschrijving expandable.
                                child: SizedBox(
                                  // Zet vaste hoogte.
                                  height: 24, // Zet hoogte.
                                  child: Marquee(
                                    // Bouwt scrollende tekst.
                                    text: // Zet scroll tekst.
                                        '${_currentVideoIndex + 1} / ${_allVideos.length}: ${_allVideos[_currentVideoIndex]['name'] ?? ''}',
                                    style: const TextStyle(
                                      // Zet tekst stijl.
                                      fontSize: 12, // Zet font grootte.
                                      fontWeight:
                                          FontWeight.bold, // Maakt tekst vet.
                                    ),
                                    scrollAxis:
                                        Axis.horizontal, // Scroll horizontaal.
                                    crossAxisAlignment: // Verticale uitlijning.
                                        CrossAxisAlignment.center,
                                    blankSpace: 50.0, // Zet ruimte na tekst.
                                    velocity: 40.0, // Zet scroll snelheid.
                                    pauseAfterRound: const Duration(
                                      seconds: 2,
                                    ), // Pauze na scroll.
                                    accelerationDuration: const Duration(
                                      // Versnellings duur.
                                      seconds: 1,
                                    ),
                                    accelerationCurve:
                                        Curves.linear, // Lineaire versnelling.
                                    decelerationDuration: const Duration(
                                      // Vertradings duur.
                                      milliseconds: 500,
                                    ),
                                    decelerationCurve:
                                        Curves.easeOut, // Ease out vertraging.
                                  ),
                                ),
                              ),
                              IconButton(
                                // Bouwt volgende knop.
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                ), // Zet pijl icoon.
                                onPressed: // Zet actie.
                                    _currentVideoIndex <
                                        _allVideos.length -
                                            1 // Checkt of niet aan eind.
                                    ? () {
                                        // Actie voor volgende video.
                                        final rawKey = // Haalt raw video key op.
                                            _allVideos[_currentVideoIndex +
                                                    1]['key']
                                                ?.toString();
                                        final normKey = // Normaliseert YouTube ID.
                                            _normalizeYoutubeId(rawKey) ??
                                            rawKey;
                                        debugPrint(
                                          // Print debug info.
                                          'Switched trailer (next) raw: $rawKey, normalized: $normKey, site: ${_allVideos[_currentVideoIndex + 1]['site']}',
                                        );
                                        setState(() {
                                          // Update state.
                                          _currentVideoIndex++; // Hogere video index.
                                          _trailerKey =
                                              normKey; // Zet nieuwe video key.
                                          _trailerSite = // Zet video site.
                                          _allVideos[_currentVideoIndex]['site']
                                              ?.toString();
                                        });
                                      }
                                    : null, // Disable als aan eind.
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12), // Voegt verticale ruimte toe.
              // Main Info card
              Card(
                // Bouwt info kaart.
                elevation: 3, // Zet schaduw hoogte.
                color: isDark
                    ? Colors.grey.shade900
                    : Colors.white, // Zet themagebaseerde kleur.
                child: Padding(
                  // Voegt padding toe.
                  padding: const EdgeInsets.all(16), // Zet padding.
                  child: Column(
                    // Bouwt verticale kolom.
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Lijnt items links uit.
                    children: [
                      Text(
                        // Toon filmtitel.
                        _title ?? '', // Zet titel tekst.
                        style: TextStyle(
                          // Zet tekst stijl.
                          fontSize: 22, // Zet font grootte.
                          fontWeight: FontWeight.bold, // Maakt tekst vet.
                          color: isDark
                              ? Colors.white
                              : Colors.black, // Zet themagebaseerde kleur.
                        ),
                      ),
                      const SizedBox(height: 8), // Voegt verticale ruimte toe.
                      Column(
                        // Bouwt kolom voor overzicht en vertaal knop.
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Lijnt items links uit.
                        children: [
                          Text(
                            // Toon filmoverzicht.
                            _translatedTexts['overview'] ??
                                _overview ??
                                '', // Zet overzicht tekst (vertaald of origineel).
                            style: TextStyle(
                              // Zet tekst stijl.
                              color:
                                  isDark // Zet themagebaseerde kleur.
                                  ? Colors.grey.shade300
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ), // Voegt verticale ruimte toe.
                          TextButton.icon(
                            // Bouwt vertaal knop.
                            icon:
                                _isTranslating['overview'] ==
                                    true // Checkt of bezig met vertalen.
                                ? const SizedBox(
                                    // Toont spinner.
                                    width: 16, // Zet breedte.
                                    height: 16, // Zet hoogte.
                                    child: CircularProgressIndicator(
                                      // Bouwt spinner.
                                      strokeWidth: 2, // Zet lijndikte.
                                    ),
                                  )
                                : const Icon(
                                    Icons.translate,
                                    size: 18,
                                  ), // Toon vertaal icoon.
                            label: Text(loc.translate), // Zet knop label.
                            onPressed:
                                _isTranslating['overview'] ==
                                    true // Checkt of bezig.
                                ? null // Disable als bezig.
                                : () {
                                    // Actie voor vertalen.
                                    if (_overview != null) {
                                      // Checkt of overzicht beschikbaar.
                                      _translateText(
                                        'overview',
                                        _overview!,
                                      ); // Vertaal overzicht.
                                    }
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12), // Voegt verticale ruimte toe.
                      Row(
                        // Bouwt rij voor rating en knoppen.
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ), // Toon ster icoon.
                          const SizedBox(
                            width: 6,
                          ), // Voegt horizontale ruimte toe.
                          Text(
                            // Toon filmrating.
                            _formatRating(_rating), // Zet geformateerde rating.
                            style: TextStyle(
                              // Zet tekst stijl.
                              color: isDark
                                  ? Colors.white
                                  : Colors.black, // Zet themagebaseerde kleur.
                            ),
                          ),

                          const Spacer(), // Voegt flexibele ruimte toe.
                          // watchlist button + movie 'Gezien' checkbox underneath
                          _loadingUserData // Checkt of user data wordt geladen.
                              ? const SizedBox(
                                  // Toont spinner.
                                  width: 24, // Zet breedte.
                                  height: 24, // Zet hoogte.
                                  child: CircularProgressIndicator(
                                    // Bouwt spinner.
                                    strokeWidth: 2, // Zet lijndikte.
                                  ),
                                )
                              : Column(
                                  // Bouwt kolom voor knoppen.
                                  crossAxisAlignment: CrossAxisAlignment
                                      .end, // Lijnt items rechts uit.
                                  children: [
                                    OutlinedButton.icon(
                                      // Bouwt watchlist knop.
                                      style: OutlinedButton.styleFrom(
                                        // Zet knop stijl.
                                        side: const BorderSide(
                                          // Zet grens.
                                          color:
                                              Colors.white, // Zet grens kleur.
                                          width: 1, // Zet grens breedte.
                                        ),
                                        foregroundColor:
                                            isDark // Zet tekst kleur.
                                            ? Colors.white
                                            : Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          // Zet padding.
                                          horizontal:
                                              12, // Zet horizontale padding.
                                          vertical: 8, // Zet verticale padding.
                                        ),
                                        shape: RoundedRectangleBorder(
                                          // Zet vorm.
                                          borderRadius: BorderRadius.circular(
                                            // Maak hoeken rond.
                                            6,
                                          ),
                                        ),
                                        backgroundColor: Colors
                                            .transparent, // Maakt achtergrond transparant.
                                      ),
                                      icon: Icon(
                                        // Zet knop icoon.
                                        _isInWatchlist // Checkt of in watchlist.
                                            ? Icons
                                                  .bookmark // Toon volle bladwijzer.
                                            : Icons
                                                  .bookmark_add_outlined, // Toon lege bladwijzer.
                                        size: 20, // Zet icoon grootte.
                                      ),
                                      label: Text(
                                        // Zet knop label.
                                        _isInWatchlist
                                            ? loc.remove
                                            : loc.save, // Zet label tekst.
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ), // Zet tekst grootte.
                                      ),
                                      onPressed: () async {
                                        // Actie voor knop klik.
                                        if (_user == null) {
                                          // Checkt of niet ingelogd.
                                          final goToLogin = // Toon login prompt.
                                          await _ensureLoggedInWithPrompt(
                                            context,
                                          );
                                          if (!goToLogin)
                                            return; // Return als niet ingelogd.
                                          return;
                                        }
                                        await _toggleWatchlist(); // Toggle watchlist.
                                      },
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ), // Voegt verticale ruimte toe.
                                    if (isMovie) // Checkt of film is.
                                      Row(
                                        // Bouwt rij voor gezien checkbox.
                                        mainAxisSize: MainAxisSize
                                            .min, // Zet minimale grootte.
                                        children: [
                                          Checkbox(
                                            // Bouwt gezien checkbox.
                                            value: _seenSet.contains(
                                              'movie',
                                            ), // Checkt of gezien.
                                            onChanged: (val) async {
                                              // Actie voor checkbox change.
                                              if (_user == null) {
                                                // Checkt of niet ingelogd.
                                                final go = // Toon login prompt.
                                                await _ensureLoggedInWithPrompt(
                                                  context,
                                                );
                                                if (!go)
                                                  return; // Return als niet ingelogd.
                                              }
                                              await _toggleMovieSeen(
                                                // Toggle film gezien.
                                                val ?? false,
                                              );
                                              setState(() {}); // Rebuild UI.
                                            },
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ), // Voegt horizontale ruimte toe.
                                          Text(
                                            // Toon gezien label.
                                            loc.seen, // Zet label tekst.
                                            style: TextStyle(
                                              // Zet tekst stijl.
                                              color:
                                                  isDark // Zet themagebaseerde kleur.
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                        ],
                      ),
                      if (_rated != null &&
                          _rated!
                              .isNotEmpty) // Checkt of leeftijdsrating beschikbaar.
                        Padding(
                          // Voegt padding toe.
                          padding: const EdgeInsets.only(
                            top: 8,
                          ), // Zet padding.
                          child: Row(
                            // Bouwt rij voor rating info.
                            children: [
                              const Icon(
                                // Toon familie icoon.
                                Icons.family_restroom_rounded,
                                size: 18, // Zet icoon grootte.
                              ),
                              const SizedBox(
                                width: 6,
                              ), // Voegt horizontale ruimte toe.
                              Text(
                                // Toon leeftijdsrating.
                                loc.age_rating(
                                  _rated ?? '',
                                ), // Zet rating tekst.
                                style: TextStyle(
                                  // Zet tekst stijl.
                                  color:
                                      isDark // Zet themagebaseerde kleur.
                                      ? Colors.grey.shade300
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12), // Voegt verticale ruimte toe.

                      if (_genres.isNotEmpty) // Checkt of genres beschikbaar.
                        Wrap(
                          // Bouwt flex rij voor genres.
                          spacing: 8, // Zet horizontale ruimte tussen items.
                          runSpacing: 8, // Zet verticale ruimte tussen rijen.
                          children:
                              _genres // Loop door genres.
                                  .map(
                                    (g) => Chip(
                                      // Bouwt genre chip.
                                      label: Text(g), // Zet chip label.
                                      backgroundColor:
                                          isDark // Zet themagebaseerde kleur.
                                          ? Colors.blue.shade900
                                          : Colors.blue.shade50,
                                      labelStyle: TextStyle(
                                        // Zet label stijl.
                                        color:
                                            isDark // Zet themagebaseerde kleur.
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      const SizedBox(height: 8), // Voegt verticale ruimte toe.
                      // Creators
                      if (_creators
                          .isNotEmpty) // Checkt of creators beschikbaar.
                        Column(
                          // Bouwt kolom voor creators.
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Lijnt items links uit.
                          children: [
                            Padding(
                              // Voegt padding toe.
                              padding: const EdgeInsets.only(
                                bottom: 4,
                              ), // Zet padding.
                              child: Text(
                                // Toon creators label.
                                loc.producers_creators, // Zet label tekst.
                                style: TextStyle(
                                  // Zet tekst stijl.
                                  fontWeight:
                                      FontWeight.bold, // Maakt tekst vet.
                                  fontSize: 14, // Zet font grootte.
                                  color: isDark
                                      ? Colors.white
                                      : Colors
                                            .black, // Zet themagebaseerde kleur.
                                ),
                              ),
                            ),
                            Wrap(
                              // Bouwt flex rij voor creators.
                              spacing:
                                  8, // Zet horizontale ruimte tussen items.
                              children: _creators.map((c) {
                                // Loop door creators.
                                final searchUrl = // Bouwt IMDB zoeklink.
                                    'https://www.imdb.com/find?q=${Uri.encodeComponent(c)}&s=nm';
                                return GestureDetector(
                                  // Maakt chip aanklikbaar.
                                  onTap: () =>
                                      _openLink(searchUrl), // Open IMDB link.
                                  child: Chip(
                                    // Bouwt creator chip.
                                    label: Text(c), // Zet chip label.
                                    backgroundColor:
                                        isDark // Zet themagebaseerde kleur.
                                        ? Colors.green.shade900
                                        : Colors.green.shade50,
                                    labelStyle: TextStyle(
                                      // Zet label stijl.
                                      color:
                                          isDark // Zet themagebaseerde kleur.
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8), // Voegt verticale ruimte toe.
                      // Cast
                      if (_cast.isNotEmpty) // Checkt of cast beschikbaar.
                        Column(
                          // Bouwt kolom voor cast.
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Lijnt items links uit.
                          children: [
                            Padding(
                              // Voegt padding toe.
                              padding: const EdgeInsets.only(
                                bottom: 4,
                              ), // Zet padding.
                              child: Text(
                                // Toon cast label.
                                loc.actors, // Zet label tekst.
                                style: TextStyle(
                                  // Zet tekst stijl.
                                  fontWeight:
                                      FontWeight.bold, // Maakt tekst vet.
                                  fontSize: 14, // Zet font grootte.
                                  color: isDark
                                      ? Colors.white
                                      : Colors
                                            .black, // Zet themagebaseerde kleur.
                                ),
                              ),
                            ),
                            Wrap(
                              // Bouwt flex rij voor cast.
                              spacing:
                                  8, // Zet horizontale ruimte tussen items.
                              runSpacing:
                                  8, // Zet verticale ruimte tussen rijen.
                              children: _cast.take(8).map((c) {
                                // Loop door cast (max 8).
                                final searchUrl = // Bouwt IMDB zoeklink.
                                    'https://www.imdb.com/find?q=${Uri.encodeComponent(c)}&s=nm';
                                return GestureDetector(
                                  // Maakt chip aanklikbaar.
                                  onTap: () =>
                                      _openLink(searchUrl), // Open IMDB link.
                                  child: Chip(
                                    // Bouwt actor chip.
                                    label: Text(c), // Zet chip label.
                                    backgroundColor:
                                        isDark // Zet themagebaseerde kleur.
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade200,
                                    labelStyle: TextStyle(
                                      // Zet label stijl.
                                      color:
                                          isDark // Zet themagebaseerde kleur.
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12), // Voegt verticale ruimte toe.
                      Text(
                        // Toon aantal seizoenen.
                        loc.seasons(
                          rapid['seasonCount'] ?? '-',
                        ), // Zet seizoen label.
                        style: TextStyle(
                          // Zet tekst stijl.
                          color: isDark
                              ? Colors.white
                              : Colors.black, // Zet themagebaseerde kleur.
                        ),
                      ),
                      Text(
                        // Toon aantal afleveringen.
                        loc.episodes(
                          rapid['episodeCount'] ?? '-',
                        ), // Zet aflever label.
                        style: TextStyle(
                          // Zet tekst stijl.
                          color: isDark
                              ? Colors.white
                              : Colors.black, // Zet themagebaseerde kleur.
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12), // Voegt verticale ruimte toe.
              // Streaming card — show also for movies even when _streaming is empty
              if (_streaming.isNotEmpty ||
                  isMovie) // Checkt of streaming beschikbaar of film.
                Card(
                  // Bouwt streaming kaart.
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.white, // Zet themagebaseerde kleur.
                  child: Padding(
                    // Voegt padding toe.
                    padding: const EdgeInsets.all(12), // Zet padding.
                    child: Column(
                      // Bouwt verticale kolom.
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Lijnt items links uit.
                      children: [
                        Text(
                          // Toon streaming titel.
                          'Streaming', // Zet titel.
                          style: TextStyle(
                            // Zet tekst stijl.
                            fontWeight: FontWeight.bold, // Maakt tekst vet.
                            color: isDark
                                ? Colors.white
                                : Colors.black, // Zet themagebaseerde kleur.
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Voegt verticale ruimte toe.

                        ..._buildGroupedStreaming(
                          _streaming,
                          context,
                        ), // Bouwt streaming diensten.
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12), // Voegt verticale ruimte toe.
              // Seasons & Episodes expansion
              if (_seasons.isNotEmpty) // Checkt of seizoenen beschikbaar.
                Card(
                  // Bouwt seizoen kaart.
                  color: isDark
                      ? Colors.grey.shade900
                      : Colors.white, // Zet themagebaseerde kleur.
                  child: ExpansionTile(
                    // Bouwt expandable tile.
                    title: Text(
                      // Zet titel.
                      AppLocalizations.of(
                        // Haalt localisatie op.
                        context,
                      )!.seasons_episodes_title(
                        _seasons.length.toString(),
                      ), // Zet seizoen titel.
                      style: TextStyle(
                        // Zet tekst stijl.
                        fontWeight: FontWeight.bold, // Maakt tekst vet.
                        color: isDark
                            ? Colors.white
                            : Colors.black, // Zet themagebaseerde kleur.
                      ),
                    ),
                    children: [
                      // Bouwt kinderen voor tile.
                      for (
                        var si = 0;
                        si < _seasons.length;
                        si++
                      ) // Loop door seizoenen.
                        _buildSeasonTile(
                          context,
                          _seasons[si],
                          si,
                          _seasons,
                        ), // Bouwt seizoen tile.
                    ],
                  ),
                ),

              if (_seasons.isEmpty &&
                  !isMovie) // Checkt of geen seizoenen en geen film.
                Padding(
                  // Voegt padding toe.
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // Zet padding.
                  child: Center(
                    // Centreert inhoud.
                    child: Text(
                      // Toon melding.
                      AppLocalizations.of(
                        context,
                      )!.no_seasons_found, // Zet melding tekst.
                      style: TextStyle(
                        // Zet tekst stijl.
                        color:
                            isDark // Zet themagebaseerde kleur.
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

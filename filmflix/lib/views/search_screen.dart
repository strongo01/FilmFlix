import 'dart:convert'; // Voor JSON encode/decode

import 'package:cinetrackr/models/movie_models.dart'; // Modeldefinities voor films
import 'package:cinetrackr/services/movie_api.dart'; // Lage-niveau API-aanroepen
import 'package:cinetrackr/services/movie_repository.dart'; // Repository-laag voor zoekopdrachten
import 'package:cinetrackr/views/movie_detail_screen.dart'; // Movie detail scherm referentie
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cinetrackr/l10n/app_localizations.dart'; // Lokalisatie strings
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Aangepaste app bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Achtergrond wrapper widget
import 'dart:typed_data'; // Type voor raw bytes (images)
import 'dart:async';
import 'package:flutter/services.dart'
    show rootBundle; // Asset bundle reader (voor .env)
import 'package:http/http.dart' as http; // HTTP client voor netwerkverzoeken
import 'dart:math' as math; // Wiskundefuncties (max etc.)

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  }); // super.key betekent dat we de key parameter doorgeven aan de constructor van de parent class (StatefulWidget). Dit is belangrijk voor het correct functioneren van de widget in de widget tree van Flutter, vooral als we later willen optimaliseren of bepaalde widgets willen identificeren. Door super.key te gebruiken, zorgen we ervoor dat de SearchScreen widget correct kan worden herbouwd en beheerd door Flutter's widget systeem.

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller =
      TextEditingController(); // Controller voor het zoekveld, houdt tekst en cursor bij
  List<MovieSearchItem> results = []; // Huidige zoekresultaten
  bool loading = false; // Of er een zoek- of filteractie loopt
  String? _nextCursor; // Cursor voor paginering
  bool _hasMore = false; // Of er meer resultaten beschikbaar zijn
  Map<String, dynamic>? _lastFilterParams; // Laatste gebruikte filterparameters
  List<MovieSearchItem> topRated = []; // Lijst met top-rated items
  List<MovieSearchItem> popular = []; // Lijst met populaire items
  bool loadingTopRated = false; // Laden indicator voor top-rated
  bool loadingPopular = false; // Laden indicator voor populair
  String? _xAppApiKey; // Optionele API key header
  final Map<String, Uint8List> _imageCache = {}; // Cache voor afbeeldingen

  Future<void> search() async {
    final query = controller.text.trim(); // Haal en trim de zoekterm

    // Als zoekveld leeg is, geen API call en scherm leeg
    if (query.isEmpty) {
      // Bij lege zoekterm: reset resultaten en stop
      setState(() {
        results = [];
        loading = false;
        _hasMore = false;
        _nextCursor = null;
        _lastFilterParams = null;
      });
      return;
    }

    setState(() {
      // Zet loading state en reset paginatie
      loading = true;
      _hasMore = false;
      _nextCursor = null;
      _lastFilterParams = null;
    });
    try {
      results = await MovieRepository.search(
        query,
      ); // Voer repository-zoekopdracht uit en sla resultaten op
    } catch (e) {
      debugPrint('Error searching movies: $e'); // Log fouten
      results = []; // Reset resultaten bij fout
    } finally {
      setState(() => loading = false); // Schakel loading uit
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {}); // Herbouw UI wanneer zoekveld verandert
    });
    _fetchTopRated(); // Laad top-rated items bij init
    _fetchPopular(); // Laad populaire items bij init
  }

  // Beschikbare genres voor filter (alleen ID's). Namen worden bij runtime gelokaliseerd.
  static const List<String> _availableGenreIds = [
    // Beschikbare genre-IDs voor filters
    'action',
    'adventure',
    'animation',
    'comedy',
    'crime',
    'documentary',
    'drama',
    'family',
    'fantasy',
    'history',
    'horror',
    'music',
    'mystery',
    'news',
    'reality',
    'romance',
    'scifi',
    'talk',
    'thriller',
    'war',
    'western',
  ];

  Map<String, String> _localizedGenres(BuildContext ctx) {
    final loc = AppLocalizations.of(ctx)!;
    return {
      'action': loc.genre_action,
      'adventure': loc.genre_adventure,
      'animation': loc.genre_animation,
      'comedy': loc.genre_comedy,
      'crime': loc.genre_crime,
      'documentary': loc.genre_documentary,
      'drama': loc.genre_drama,
      'family': loc.genre_family,
      'fantasy': loc.genre_fantasy,
      'history': loc.genre_history,
      'horror': loc.genre_horror,
      'music': loc.genre_music,
      'mystery': loc.genre_mystery,
      'news': loc.genre_news,
      'reality': loc.genre_reality,
      'romance': loc.genre_romance,
      'scifi': loc.genre_scifi,
      'talk': loc.genre_talk,
      'thriller': loc.genre_thriller,
      'war': loc.genre_war,
      'western': loc.genre_western,
    }; // Kaart van genre-id naar gelokaliseerde naam
  }

  Future<void> _openFilterModal(BuildContext context) async {
    // local filter state
    String country = 'nl';
    // Landcode standaard 'nl'
    String seriesGranularity = 'show';
    // Granularity voor series
    String outputLanguage = 'en';
    // Gewenste uitvoertaal
    String showType = '';
    // Leeg betekent alle type
    int? ratingMin;
    // Minimum rating filter
    int? ratingMax;
    // Maximum rating filter
    String catalogs = '';
    // Optionele catalogs parameter
    final Set<String> selectedGenres = {};
    // Geselecteerde genres als set
    String genresRelation =
        'and'; // Changed from 'any' as it's more predictable
    // Relation tussen genres (and/any)
    String keyword = '';
    // Keyword filter
    String showOriginalLanguage = '';
    // Filter op originele taal
    int? yearMin;
    // Minimum jaar
    int? yearMax;
    // Maximum jaar

    // Controllers to preserve text during modal lifecycle
    final keywordCtrl = TextEditingController(
      text: keyword,
    ); // Controller voor keyword veld
    final yearMinCtrl = TextEditingController(text: yearMin?.toString() ?? '');
    final yearMaxCtrl = TextEditingController(text: yearMax?.toString() ?? '');
    final ratingMinCtrl = TextEditingController(
      text: ratingMin?.toString() ?? '',
    );
    final ratingMaxCtrl = TextEditingController(
      text: ratingMax?.toString() ?? '',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      // Open het filter-bottomsheet
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Gebruik een DraggableScrollableSheet zodat het bottomsheet niet
        // volledig naar boven uitklapt. De innerlijke SingleChildScrollView
        // gebruikt de meegeleverde scrollController zodat de inhoud kan
        // scrollen terwijl initiële/maximale hoogte beperkt blijft.
        return DraggableScrollableSheet(
          // Maak draggable sheet voor filters
          initialChildSize: 0.72,
          minChildSize: 0.4,
          // Beperk de maximale uitvouwing zodat de sheet niet tot de bovenkant reikt
          maxChildSize: 0.85,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return StatefulBuilder(
              // StatefulBuilder voor lokale modal state updates
              builder: (ctx, setModalState) {
                return Container(
                  padding: EdgeInsets.only(
                    // houd rekening met keyboard-insets en systeemonderpadding (navigatiebalk)
                    bottom:
                        MediaQuery.of(ctx).viewInsets.bottom +
                        MediaQuery.of(ctx).viewPadding.bottom +
                        20, // Houd rekening met keyboard en systeem padding
                    left: 16,
                    right: 16,
                    top: 20,
                  ),
                  child: SingleChildScrollView(
                    controller:
                        scrollController, // Zorg dat interne scroll de sheet scrollt
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // Titel van filter modal
                              AppLocalizations.of(ctx)!.filter_refine_title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            IconButton(
                              // Sluitknop voor de modal
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 10),

                        Text(
                          AppLocalizations.of(ctx)!.filter_type_label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          // Keuze voor type (alles / films / series)
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                // Chip voor "alle" types
                                label: Center(
                                  child: Text(
                                    AppLocalizations.of(ctx)!.filter_all,
                                  ),
                                ),
                                selected: showType == '',
                                selectedColor: Colors.lightBlueAccent
                                    .withOpacity(0.2),
                                onSelected: (v) =>
                                    setModalState(() => showType = ''),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    AppLocalizations.of(ctx)!.filter_movies,
                                  ),
                                ),
                                selected: showType == 'movie',
                                selectedColor: Colors.lightBlueAccent
                                    .withOpacity(0.2),
                                onSelected: (v) =>
                                    setModalState(() => showType = 'movie'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    AppLocalizations.of(ctx)!.filter_series,
                                  ),
                                ),
                                selected: showType == 'series',
                                selectedColor: Colors.lightBlueAccent
                                    .withOpacity(0.2),
                                onSelected: (v) =>
                                    setModalState(() => showType = 'series'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(ctx)!.filter_keyword_label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        TextField(
                          // Keyword invoer voor fijnfilter
                          controller: keywordCtrl,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              ctx,
                            )!.filter_keyword_hint,
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (v) => keyword =
                              v, // Houd keyword bij in lokale variabele
                        ),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(ctx)!.filter_genres_label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          // FilterChips voor genres
                          spacing: 8,
                          runSpacing: 0,
                          children: _availableGenreIds.map((id) {
                            final names = _localizedGenres(ctx);
                            final sel = selectedGenres.contains(id);
                            final label = names[id] ?? id;
                            return FilterChip(
                              label: Text(
                                label,
                                style: const TextStyle(fontSize: 13),
                              ),
                              selected: sel,
                              selectedColor: Colors.blueAccent.withOpacity(0.2),
                              onSelected: (v) => setModalState(
                                () => v
                                    ? selectedGenres.add(id)
                                    : selectedGenres.remove(id),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      ctx,
                                    )!.filter_year_from_label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  TextField(
                                    // Min jaar invoer en parsing
                                    controller: yearMinCtrl,
                                    decoration: const InputDecoration(
                                      hintText: '1900',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => yearMin = int.tryParse(v),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      ctx,
                                    )!.filter_year_to_label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  TextField(
                                    // Max jaar invoer en parsing
                                    controller: yearMaxCtrl,
                                    decoration: const InputDecoration(
                                      hintText: '2026',
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (v) => yearMax = int.tryParse(v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Text(
                          AppLocalizations.of(ctx)!.filter_min_rating_label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Slider(
                          // Slider voor minimum rating
                          value: (ratingMin ?? 0).toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 10,
                          label: (ratingMin ?? 0).toString(),
                          onChanged: (v) =>
                              setModalState(() => ratingMin = v.toInt()),
                        ),

                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (mounted)
                                this.setState(
                                  () => loading = true,
                                ); // Toon laden indicator
                              final genresParam = selectedGenres.isEmpty
                                  ? null
                                  : selectedGenres.join(
                                      ',',
                                    ); // Zet genres naar comma-string indien aanwezig

                              final filterParams = {
                                // Bouw filterparametermap
                                'country': country,
                                'series_granularity': 'show',
                                'output_language': 'en',
                                'show_type': showType.isEmpty ? null : showType,
                                'rating_min': ratingMin ?? 0,
                                'rating_max': ratingMax ?? 100,
                                'catalogs': catalogs.isEmpty ? null : catalogs,
                                'genres': genresParam,
                                'genres_relation': genresRelation,
                                'keyword': keyword.isEmpty ? null : keyword,
                                'show_original_language':
                                    showOriginalLanguage.isEmpty
                                    ? null
                                    : showOriginalLanguage,
                                'year_min': yearMin,
                                'year_max': yearMax,
                                'order_by': 'rating',
                                'order_direction': 'desc',
                              };

                              Map<String, dynamic>? resp;
                              try {
                                resp = await MovieApi.filterAdvanced(
                                  // Roep de filter API aan met de parameters
                                  country: country,
                                  seriesGranularity: 'show',
                                  outputLanguage: 'en',
                                  showType: showType.isEmpty ? null : showType,
                                  ratingMin: ratingMin ?? 0,
                                  ratingMax: ratingMax ?? 100,
                                  catalogs: catalogs.isEmpty ? null : catalogs,
                                  genres: genresParam,
                                  genresRelation: genresRelation,
                                  keyword: keyword.isEmpty ? null : keyword,
                                  showOriginalLanguage:
                                      showOriginalLanguage.isEmpty
                                      ? null
                                      : showOriginalLanguage,
                                  yearMin: yearMin,
                                  yearMax: yearMax,
                                  orderBy: 'rating',
                                  orderDirection: 'desc',
                                );
                              } catch (e) {
                                debugPrint(
                                  'Filter error: $e',
                                ); // Log eventuele fouten
                              }

                              if (mounted) {
                                final resultsList =
                                    resp?['shows'] ??
                                    resp?['results'] ??
                                    []; // Haal resultaten uit response
                                final List<dynamic> items = resultsList is List
                                    ? resultsList
                                    : [];

                                this.setState(() {
                                  results = items
                                      .map(
                                        (e) => MovieSearchItem.fromJson(
                                          Map<String, dynamic>.from(e as Map),
                                        ),
                                      )
                                      .toList(); // Map raw JSON naar modellen
                                  _hasMore =
                                      resp != null &&
                                      resp['hasMore'] ==
                                          true; // Update paginatie flags
                                  _nextCursor = resp?['nextCursor']
                                      ?.toString(); // Bewaar cursor
                                  _lastFilterParams =
                                      filterParams; // Bewaar gebruikte filters
                                  loading = false; // Zet loading uit
                                });
                                Navigator.pop(ctx); // Sluit modal
                              }
                            },
                            child: Text(
                              AppLocalizations.of(ctx)!.apply_filters,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          // Cancel knop onderaan modal
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              AppLocalizations.of(ctx)!.cancel,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _loadMore() async {
    if (_nextCursor == null || _lastFilterParams == null)
      return; // Stop wanneer geen cursor of geen filters

    debugPrint('--- Loading More ---');
    debugPrint('Cursor used: $_nextCursor');
    debugPrint('Params: $_lastFilterParams');

    setState(() => loading = true); // Toon laden indicator

    try {
      final resp = await MovieApi.filterAdvanced(
        // Vraag volgende pagina op met opgeslagen params
        country: _lastFilterParams!['country'],
        seriesGranularity: _lastFilterParams!['series_granularity'],
        outputLanguage: _lastFilterParams!['output_language'],
        showType: _lastFilterParams!['show_type'],
        ratingMin: _lastFilterParams!['rating_min'],
        ratingMax: _lastFilterParams!['rating_max'],
        catalogs: _lastFilterParams!['catalogs'],
        genres: _lastFilterParams!['genres'],
        genresRelation:
            _lastFilterParams!['genres_relation'], // Corrected key from genresRelation
        keyword: _lastFilterParams!['keyword'],
        showOriginalLanguage:
            _lastFilterParams!['show_original_language'], // Corrected key mapping
        yearMin: _lastFilterParams!['year_min'], // Corrected key mapping
        yearMax: _lastFilterParams!['year_max'], // Corrected key mapping
        orderBy: _lastFilterParams!['order_by'], // Corrected key mapping
        orderDirection:
            _lastFilterParams!['order_direction'], // Corrected key mapping
        cursor: _nextCursor,
      );

      final resultsList =
          resp['shows'] ?? resp['results'] ?? resp['result'] ?? [];
      final List<dynamic> items = resultsList is List ? resultsList : [];

      setState(() {
        // Voeg nieuwe items toe en update paginatie state
        results.addAll(
          items.map(
            (e) =>
                MovieSearchItem.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
        _hasMore = resp != null && resp['hasMore'] == true;
        _nextCursor = resp?['nextCursor']?.toString();
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading more results: $e');
      setState(() => loading = false);
    }
  }

  Future<void> _fetchTopRated({int page = 1}) async {
    loadingTopRated = true;
    // zet laadstatus voor topRated aan
    setState(() {});
    final uriMovie = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'top_rated', 'page': page.toString()});
    // bouw URI voor top rated films

    final uriTv = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
        .replace(
          queryParameters: {'type': 'tv_top_rated', 'page': page.toString()},
        );
    // bouw URI voor top rated tv-series
    try {
      await _ensureEnvLoaded();
      // laad API key uit .env indien nodig
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg API key toe aan headers als aanwezig
      // vraag zowel top-rated films als tv-series parallel op; tolereren dat één faalt
      final futures = await Future.wait<List<dynamic>>([
        (() async {
          try {
            final r = await http.get(uriMovie, headers: headers);
            if (r.statusCode != 200) return <dynamic>[];
            final j = jsonDecode(r.body) as Map<String, dynamic>?;
            return (j?['results'] as List<dynamic>?) ?? <dynamic>[];
          } catch (_) {
            return <dynamic>[];
          }
        })(),
        (() async {
          try {
            final r = await http.get(uriTv, headers: headers);
            if (r.statusCode != 200) return <dynamic>[];
            final j = jsonDecode(r.body) as Map<String, dynamic>?;
            return (j?['results'] as List<dynamic>?) ?? <dynamic>[];
          } catch (_) {
            return <dynamic>[];
          }
        })(),
      ]);

      final List<dynamic> moviesPart = futures.isNotEmpty
          ? futures[0]
          : <dynamic>[];
      final List<dynamic> tvPart = futures.length > 1
          ? futures[1]
          : <dynamic>[];
      final int maxLen = math.max(moviesPart.length, tvPart.length);
      final rawCombined = <dynamic>[];
      for (int i = 0; i < maxLen; i++) {
        if (i < moviesPart.length) rawCombined.add(moviesPart[i]);
        if (i < tvPart.length) rawCombined.add(tvPart[i]);
      }

      // dedupe by id + type (movie vs tv) to avoid collisions
      // maak unieke key per id+type om duplicaten te verwijderen
      final Map<String, dynamic> unique = {};
      for (final e in rawCombined) {
        final Map m = e as Map;
        final id = (m['id']?.toString() ?? '');
        final typeHint = m.containsKey('first_air_date') ? 'tv' : 'movie';
        final key = '$id|$typeHint';
        if (!unique.containsKey(key)) unique[key] = m;
      }

      final items = unique.values.toList();
      topRated = items.map((e) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
        final id = m['id']?.toString() ?? '';
        final title = m['title'] ?? m['name'] ?? '';
        final posterPath = m['poster_path'] as String?;
        final poster = posterPath != null
            ? 'https://image.tmdb.org/t/p/w500$posterPath'
            : null;
        // stel poster-URL samen als poster_path aanwezig is
        final year = ((m['release_date'] ?? m['first_air_date']) ?? '')
            .toString()
            .split('-')
            .firstWhere((_) => true, orElse: () => '');
        // haal jaar uit release_date of first_air_date
        return MovieSearchItem(
          id: 'tmdb:$id',
          title: title.toString(),
          year: int.tryParse(year) ?? null,
          poster: poster,
          raw: m,
          tmdbId: id,
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed fetchTopRated: $e');
    } finally {
      loadingTopRated = false;
      // reset laadstatus en update UI
      setState(() {});
    }
  }

  Future<void> _fetchPopular({int page = 1}) async {
    loadingPopular = true;
    // zet laadstatus voor populaire items aan
    setState(() {});
    final uriMovie = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'popular', 'page': page.toString()});
    // bouw URI voor populaire films

    final uriTv = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tv_popular', 'page': page.toString()});
    // bouw URI voor populaire tv-series
    try {
      await _ensureEnvLoaded();
      // zorg dat .env geladen is
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg API key toe aan headers indien aanwezig
      // fetch both movie and tv popular endpoints in parallel
      final futures = await Future.wait<List<dynamic>>([
        (() async {
          try {
            final r = await http.get(uriMovie, headers: headers);
            if (r.statusCode != 200) return <dynamic>[];
            final j = jsonDecode(r.body) as Map<String, dynamic>?;
            return (j?['results'] as List<dynamic>?) ?? <dynamic>[];
          } catch (_) {
            return <dynamic>[];
          }
        })(),
        (() async {
          try {
            final r = await http.get(uriTv, headers: headers);
            if (r.statusCode != 200) return <dynamic>[];
            final j = jsonDecode(r.body) as Map<String, dynamic>?;
            return (j?['results'] as List<dynamic>?) ?? <dynamic>[];
          } catch (_) {
            return <dynamic>[];
          }
        })(),
      ]);

      final List<dynamic> moviesPart = futures.isNotEmpty
          ? futures[0]
          : <dynamic>[];
      final List<dynamic> tvPart = futures.length > 1
          ? futures[1]
          : <dynamic>[];
      final int maxLen = math.max(moviesPart.length, tvPart.length);
      final rawCombined = <dynamic>[];
      for (int i = 0; i < maxLen; i++) {
        if (i < moviesPart.length) rawCombined.add(moviesPart[i]);
        if (i < tvPart.length) rawCombined.add(tvPart[i]);
      }

      final Map<String, dynamic> unique = {};
      for (final e in rawCombined) {
        final Map m = e as Map;
        final id = (m['id']?.toString() ?? '');
        final typeHint = m.containsKey('first_air_date') ? 'tv' : 'movie';
        final key = '$id|$typeHint';
        if (!unique.containsKey(key)) unique[key] = m;
      }

      final items = unique.values.toList();
      popular = items.map((e) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(e as Map);
        final id = m['id']?.toString() ?? '';
        final title = m['title'] ?? m['name'] ?? '';
        final posterPath = m['poster_path'] as String?;
        final poster = posterPath != null
            ? 'https://image.tmdb.org/t/p/w500$posterPath'
            : null;
        // stel poster-URL samen voor populaire items
        final year = ((m['release_date'] ?? m['first_air_date']) ?? '')
            .toString()
            .split('-')
            .firstWhere((_) => true, orElse: () => '');
        // haal jaar uit datumvelden
        return MovieSearchItem(
          id: 'tmdb:$id',
          title: title.toString(),
          year: int.tryParse(year) ?? null,
          poster: poster,
          raw: m,
          tmdbId: id,
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed fetchPopular: $e');
    } finally {
      loadingPopular = false;
      // reset laadstatus en update UI
      setState(() {});
    }
  }

  Future<void> _openTmdbMovieDetail(String movieId) async {
    if (movieId.isEmpty) return;
    // stop als er geen movieId is
    final uri = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tmdbmovieinfo', 'movie_id': movieId});
    // bouw URI om TMDb movie info op te halen via backend
    try {
      await _ensureEnvLoaded();
      // zorg voor env/API key
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg API key header toe indien aanwezig
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.tmdb_movie_fetch_failed,
            ),
          ),
        );
        return;
      }
      // decodeer respons en controleer op imdb id
      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      final imdbId = jsonData?['imdb_id']?.toString();
      if (imdbId != null && imdbId.isNotEmpty) {
        final imdbNonNull = imdbId!;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(imdbId: imdbNonNull),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.no_imdb_for_movie),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed openTmdbMovieDetail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.tmdb_movie_fetch_error),
        ),
      );
    }
  }

  Future<void> _openTmdbDetailFromItem(MovieSearchItem item) async {
    final tmdbId = item.tmdbId ?? '';
    if (tmdbId.isEmpty) return;
    // haal tmdb id uit item en stop als leeg

    final isTv =
        (item.raw['first_air_date'] != null) ||
        (item.raw['media_type'] == 'tv');
    // bepaal of item een tv-serie lijkt te zijn

    final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
        .replace(
          queryParameters: isTv
              ? {'type': 'tmdbserieinfo', 'tv_id': tmdbId}
              : {'type': 'tmdbmovieinfo', 'movie_id': tmdbId},
        );
    // bouw juiste URI afhankelijk van type (movie of serie)

    try {
      await _ensureEnvLoaded();
      // laad env/API key
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg API key header toe indien aanwezig
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTv
                  ? AppLocalizations.of(context)!.tmdb_series_fetch_failed
                  : AppLocalizations.of(context)!.tmdb_movie_fetch_failed,
            ),
          ),
        );
        return;
      }

      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;

      // try to find an IMDb ID (movie: imdb_id, tv: external_ids.imdb_id)
      String? imdbId;
      if (isTv) {
        imdbId = jsonData?['external_ids']?['imdb_id']?.toString();
      } else {
        imdbId = jsonData?['imdb_id']?.toString();
      }

      if (imdbId != null && imdbId.isNotEmpty) {
        // Controleer of er een IMDb ID is en navigeer naar detailpagina
        final imdbNonNull = imdbId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailScreen(imdbId: imdbNonNull),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isTv
                  ? AppLocalizations.of(context)!.no_imdb_for_series
                  : AppLocalizations.of(context)!.no_imdb_for_movie,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Failed openTmdbDetail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTv
                ? AppLocalizations.of(context)!.tmdb_series_fetch_error
                : AppLocalizations.of(context)!.tmdb_movie_fetch_error,
          ),
        ),
      );
    }
  }

  /// Haalt TMDb poster op via backend fallback
  Future<String?> _fetchTmdbPoster(String? tmdbIdRaw) async {
    if (tmdbIdRaw == null) return null;
    // stop bij null id
    final parts = tmdbIdRaw.split('/');
    final movieId = parts.length > 1 ? parts.last : tmdbIdRaw;
    // extraheer echte id uit pad indien nodig

    final uri = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tmdb-images', 'movie_id': movieId});
    // vraag TMDb images via backend

    try {
      await _ensureEnvLoaded();
      // zorg dat API key geladen is
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg header toe als beschikbaar
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) return null;

      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      if (jsonData == null) return null;

      final postersRaw = jsonData['posters'];
      final posters = (postersRaw is List)
          ? postersRaw.cast<Map<String, dynamic>>()
          : [];

      Map<String, dynamic>? chosen;
      for (final p in posters) {
        if ((p['iso_3166_1'] ?? '').toString().toUpperCase() == 'US') {
          chosen = p;
          break;
        }
      }
      chosen ??= posters.isNotEmpty ? posters.first : null;

      if (chosen == null) return null;

      final filePath = chosen['file_path']?.toString();
      if (filePath == null) return null;

      return 'https://image.tmdb.org/t/p/original$filePath'; // Originele TMDb poster-URL (originele resolutie)
    } catch (e) {
      debugPrint('Error fetching TMDb poster: $e');
      return null;
    }
  }

  String proxiedUrl(String url) {
    return 'https://film-flix-olive.vercel.app/apiv2/movies'
        '?type=image-proxy'
        '&imageUrl=${Uri.encodeComponent(url)}';
    // retourneer proxied image endpoint voor gegeven URL
  }

  Future<void> _ensureEnvLoaded() async {
    if (_xAppApiKey != null) return;
    // sla op als env al geladen is
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
      if (kDebugMode) debugPrint('Failed to load .env: $e');
    }
  }

  Future<Uint8List?> _fetchProxiedImageBytes(String originalUrl) async {
    if (_imageCache.containsKey(originalUrl)) return _imageCache[originalUrl];
    // return cached bytes als aanwezig
    await _ensureEnvLoaded();
    try {
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          .replace(
            queryParameters: {'type': 'image-proxy', 'imageUrl': originalUrl},
          );
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty)
        headers['x-app-api-key'] = _xAppApiKey!;
      // voeg API key header toe voor proxied image request
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200) {
        _imageCache[originalUrl] = resp.bodyBytes;
        return resp.bodyBytes;
      }
    } catch (e) {
      debugPrint('Error fetching proxied image: $e');
    }
    return null;
  }

  Widget _imageFromProxied(String originalUrl, {BoxFit fit = BoxFit.cover}) {
    return FutureBuilder<Uint8List?>(
      future: _fetchProxiedImageBytes(originalUrl),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(color: Colors.grey[300]);
        }
        final bytes = snap.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: fit);
        }
        return Container(color: Colors.grey[300]);
      },
    );
  }

  Widget _posterWithFallback(MovieSearchItem movie) {
    if (movie.poster == null || movie.poster!.isEmpty) {
      // Geen originele poster, direct TMDb fallback
      return FutureBuilder<String?>(
        future: _fetchTmdbPoster(movie.tmdbId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(color: Colors.grey[300]);
          }
          final url = snap.data;
          if (url != null && url.isNotEmpty) {
            return _imageFromProxied(url, fit: BoxFit.cover);
          }
          return Container(color: Colors.grey[300]);
        },
      );
    }

    // Er is een originele poster
    // gebruik originele poster via proxy
    return _imageFromProxied(movie.poster ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // detecteer thema (donker/licht)

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppTopBar(title: AppLocalizations.of(context)!.navSearch),
      ),
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: controller,
                  // controller voor zoekinput
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                    search();
                  },
                  // voer zoekactie uit bij submit
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.search_hint,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    prefixIcon: controller.text.isNotEmpty || results.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            tooltip: AppLocalizations.of(
                              context,
                            )!.clear_tooltip,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                controller.clear();
                                results = [];
                                loading = false;
                                _hasMore = false;
                                _nextCursor = null;
                                _lastFilterParams = null;
                              });
                            },
                          )
                        : null,
                    // prefix: wis knop die zoekveld en resultaten reset
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          tooltip: AppLocalizations.of(context)!.filter_tooltip,
                          onPressed: () => _openFilterModal(context),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            search();
                          },
                        ),
                      ],
                    ),
                    // suffix: filter en zoekknoppen
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                  ),
                ),
              ),
              if (loading && results.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.text.trim().isNotEmpty || results.isNotEmpty)
                Expanded(
                  child: ListView(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: results.length, // Aantal zoekresultaten
                        itemBuilder: (_, index) {
                          final movie = results[index];

                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MovieDetailScreen(imdbId: movie.id),
                              ),
                            ),
                            // open MovieDetailScreen bij tik op item
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _posterWithFallback(movie),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  movie.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (_hasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _loadMore,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[800],
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.load_more_results,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                    ],
                  ),
                )
              else
                // toon twee tabbladen: Best Rated en Populair
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            Tab(text: AppLocalizations.of(context)!.best_rated),
                            Tab(text: AppLocalizations.of(context)!.popular),
                          ],
                          labelColor: isDark ? Colors.white : Colors.black87,
                          indicatorColor: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              // Best Rated
                              loadingTopRated
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(12),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 0.6,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      itemCount: topRated
                                          .length, // Aantal top-rated items
                                      itemBuilder: (_, index) {
                                        final movie = topRated[index];
                                        return GestureDetector(
                                          onTap: () =>
                                              _openTmdbDetailFromItem(movie),
                                          // open TMDb detail (movie of serie) bij tik
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: _posterWithFallback(
                                                    movie,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                movie.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                              // Populair
                              loadingPopular
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(12),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 0.6,
                                            crossAxisSpacing: 8,
                                            mainAxisSpacing: 8,
                                          ),
                                      // grid-configuratie: 3 kolommen, vaste aspect-ratio en spacing
                                      itemCount: popular
                                          .length, // Aantal populaire items
                                      // bepaal aantal grid-items uit de 'popular' lijst
                                      itemBuilder: (_, index) {
                                        final movie = popular[index];
                                        return GestureDetector(
                                          onTap: () =>
                                              _openTmdbDetailFromItem(movie),
                                          // open TMDb detail vanuit populair overzicht
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: _posterWithFallback(
                                                    movie,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                movie.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

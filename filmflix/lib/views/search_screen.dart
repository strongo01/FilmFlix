import 'dart:convert';

import 'package:cinetrackr/models/movie_models.dart';
import 'package:cinetrackr/services/movie_api.dart';
import 'package:cinetrackr/services/movie_repository.dart';
import 'package:cinetrackr/views/movie_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  }); // super.key betekent dat we de key parameter doorgeven aan de constructor van de parent class (StatefulWidget). Dit is belangrijk voor het correct functioneren van de widget in de widget tree van Flutter, vooral als we later willen optimaliseren of bepaalde widgets willen identificeren. Door super.key te gebruiken, zorgen we ervoor dat de SearchScreen widget correct kan worden herbouwd en beheerd door Flutter's widget systeem.

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  List<MovieSearchItem> results = [];
  bool loading = false;
  String? _nextCursor;
  bool _hasMore = false;
  Map<String, dynamic>? _lastFilterParams;
  List<MovieSearchItem> topRated = [];
  List<MovieSearchItem> popular = [];
  bool loadingTopRated = false;
  bool loadingPopular = false;
  String? _xAppApiKey;
  final Map<String, Uint8List> _imageCache = {};

  Future<void> search() async {
    final query = controller.text.trim();

    // Als zoekveld leeg is, geen API call en scherm leeg
    if (query.isEmpty) {
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
      loading = true;
      _hasMore = false;
      _nextCursor = null;
      _lastFilterParams = null;
    });
    try {
      results = await MovieRepository.search(
        query,
      ); // we roepen de search functie van MovieRepository aan, die op zijn beurt de search functie van MovieApi aanroept. Deze functie voert een API call uit naar de backend met de zoekopdracht, en ontvangt een lijst van zoekresultaten in de vorm van MovieSearchItem objecten. We slaan deze resultaten op in de state van de widget, zodat we ze kunnen weergeven in de UI. Als er een fout optreedt tijdens het zoeken, vangen we deze op en loggen we een foutmelding, en zorgen we ervoor dat de resultatenlijst leeg blijft.
    } catch (e) {
      debugPrint('Error searching movies: $e');
      results = [];
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
    _fetchTopRated();
    _fetchPopular();
  }

  // Available genres for filter
  static const List<Map<String, String>> _availableGenres = [
    {"id": "action", "name": "Action"},
    {"id": "adventure", "name": "Adventure"},
    {"id": "animation", "name": "Animation"},
    {"id": "comedy", "name": "Comedy"},
    {"id": "crime", "name": "Crime"},
    {"id": "documentary", "name": "Documentary"},
    {"id": "drama", "name": "Drama"},
    {"id": "family", "name": "Family"},
    {"id": "fantasy", "name": "Fantasy"},
    {"id": "history", "name": "History"},
    {"id": "horror", "name": "Horror"},
    {"id": "music", "name": "Music"},
    {"id": "mystery", "name": "Mystery"},
    {"id": "news", "name": "News"},
    {"id": "reality", "name": "Reality"},
    {"id": "romance", "name": "Romance"},
    {"id": "scifi", "name": "Science Fiction"},
    {"id": "talk", "name": "Talk Show"},
    {"id": "thriller", "name": "Thriller"},
    {"id": "war", "name": "War"},
    {"id": "western", "name": "Western"},
  ];

  Future<void> _openFilterModal(BuildContext context) async {
    // local filter state
    String country = 'nl';
    String seriesGranularity = 'show';
    String outputLanguage = 'en';
    String showType = '';
    int? ratingMin;
    int? ratingMax;
    String catalogs = '';
    final Set<String> selectedGenres = {};
    String genresRelation = 'and'; // Changed from 'any' as it's more predictable
    String keyword = '';
    String showOriginalLanguage = '';
    int? yearMin;
    int? yearMax;

    // Controllers to preserve text during modal lifecycle
    final keywordCtrl = TextEditingController(text: keyword);
    final yearMinCtrl = TextEditingController(text: yearMin?.toString() ?? '');
    final yearMaxCtrl = TextEditingController(text: yearMax?.toString() ?? '');
    final ratingMinCtrl = TextEditingController(text: ratingMin?.toString() ?? '');
    final ratingMaxCtrl = TextEditingController(text: ratingMax?.toString() ?? '');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filters verfijnen',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    Text(
                      'TYPE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Alles')),
                            selected: showType == '',
                            onSelected: (v) => setModalState(() => showType = ''),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Films')),
                            selected: showType == 'movie',
                            onSelected: (v) => setModalState(() => showType = 'movie'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Series')),
                            selected: showType == 'series',
                            onSelected: (v) => setModalState(() => showType = 'series'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    Text(
                      'ZOEKWOORD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.1,
                      ),
                    ),
                    TextField(
                      controller: keywordCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Bijv. Batman, Marvel...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (v) => keyword = v,
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'GENRES',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 0,
                      children: _availableGenres.map((g) {
                        final id = g['id']!;
                        final sel = selectedGenres.contains(id);
                        return FilterChip(
                          label: Text(g['name']!, style: const TextStyle(fontSize: 13)),
                          selected: sel,
                          selectedColor: Colors.blueAccent.withOpacity(0.2),
                          onSelected: (v) => setModalState(
                            () => v ? selectedGenres.add(id) : selectedGenres.remove(id),
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
                                'JAAR (VAN)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              TextField(
                                controller: yearMinCtrl,
                                decoration: const InputDecoration(hintText: '1900'),
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
                                'JAAR (TOT)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              TextField(
                                controller: yearMaxCtrl,
                                decoration: const InputDecoration(hintText: '2026'),
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
                      'MINIMALE RATING (0-100)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Slider(
                      value: (ratingMin ?? 0).toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: (ratingMin ?? 0).toString(),
                      onChanged: (v) => setModalState(() => ratingMin = v.toInt()),
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
                          if (mounted) this.setState(() => loading = true);
                          final genresParam = selectedGenres.isEmpty
                              ? null
                              : selectedGenres.join(',');

                          final filterParams = {
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
                            'show_original_language': showOriginalLanguage.isEmpty ? null : showOriginalLanguage,
                            'year_min': yearMin,
                            'year_max': yearMax,
                            'order_by': 'rating',
                            'order_direction': 'desc',
                          };

                          Map<String, dynamic>? resp;
                          try {
                            resp = await MovieApi.filterAdvanced(
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
                              showOriginalLanguage: showOriginalLanguage.isEmpty ? null : showOriginalLanguage,
                              yearMin: yearMin,
                              yearMax: yearMax,
                              orderBy: 'rating',
                              orderDirection: 'desc',
                            );
                          } catch (e) {
                            debugPrint('Filter error: $e');
                          }

                          if (mounted) {
                            final resultsList = resp?['shows'] ?? resp?['results'] ?? [];
                            final List<dynamic> items = resultsList is List ? resultsList : [];
                            
                            this.setState(() {
                              results = items.map((e) => MovieSearchItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
                              _hasMore = resp != null && resp['hasMore'] == true;
                              _nextCursor = resp?['nextCursor']?.toString();
                              _lastFilterParams = filterParams;
                              loading = false;
                            });
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Filters Toepassen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Annuleren',
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
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
  }

  Future<void> _loadMore() async {
    if (_nextCursor == null || _lastFilterParams == null) return;

    debugPrint('--- Loading More ---');
    debugPrint('Cursor used: $_nextCursor');
    debugPrint('Params: $_lastFilterParams');

    setState(() => loading = true);

    try {
      final resp = await MovieApi.filterAdvanced(
        country: _lastFilterParams!['country'],
        seriesGranularity: _lastFilterParams!['series_granularity'],
        outputLanguage: _lastFilterParams!['output_language'],
        showType: _lastFilterParams!['show_type'],
        ratingMin: _lastFilterParams!['rating_min'],
        ratingMax: _lastFilterParams!['rating_max'],
        catalogs: _lastFilterParams!['catalogs'],
        genres: _lastFilterParams!['genres'],
        genresRelation: _lastFilterParams!['genres_relation'], // Corrected key from genresRelation
        keyword: _lastFilterParams!['keyword'],
        showOriginalLanguage: _lastFilterParams!['show_original_language'], // Corrected key mapping
        yearMin: _lastFilterParams!['year_min'], // Corrected key mapping
        yearMax: _lastFilterParams!['year_max'], // Corrected key mapping
        orderBy: _lastFilterParams!['order_by'], // Corrected key mapping
        orderDirection: _lastFilterParams!['order_direction'], // Corrected key mapping
        cursor: _nextCursor,
      );

      final resultsList =
          resp['shows'] ?? resp['results'] ?? resp['result'] ?? [];
      final List<dynamic> items = resultsList is List ? resultsList : [];

      setState(() {
        results.addAll(
          items.map(
            (e) => MovieSearchItem.fromJson(Map<String, dynamic>.from(e as Map)),
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
    setState(() {});
    final uriMovie = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'top_rated', 'page': page.toString()});

    final uriTv = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tv_top_rated', 'page': page.toString()});
    try {
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      // request both movie and tv top-rated in parallel, tolerate one failing
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

      final List<dynamic> moviesPart = futures.isNotEmpty ? futures[0] : <dynamic>[];
      final List<dynamic> tvPart = futures.length > 1 ? futures[1] : <dynamic>[];
      final int maxLen = math.max(moviesPart.length, tvPart.length);
      final rawCombined = <dynamic>[];
      for (int i = 0; i < maxLen; i++) {
        if (i < moviesPart.length) rawCombined.add(moviesPart[i]);
        if (i < tvPart.length) rawCombined.add(tvPart[i]);
      }

      // dedupe by id + type (movie vs tv) to avoid collisions
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
        final year = ((m['release_date'] ?? m['first_air_date']) ?? '')
            .toString()
            .split('-')
            .firstWhere((_) => true, orElse: () => '');
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
      setState(() {});
    }
  }

  Future<void> _fetchPopular({int page = 1}) async {
    loadingPopular = true;
    setState(() {});
    final uriMovie = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'popular', 'page': page.toString()});

    final uriTv = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tv_popular', 'page': page.toString()});
    try {
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
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

      final List<dynamic> moviesPart = futures.isNotEmpty ? futures[0] : <dynamic>[];
      final List<dynamic> tvPart = futures.length > 1 ? futures[1] : <dynamic>[];
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
        final year = ((m['release_date'] ?? m['first_air_date']) ?? '')
            .toString()
            .split('-')
            .firstWhere((_) => true, orElse: () => '');
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
      setState(() {});
    }
  }

  Future<void> _openTmdbMovieDetail(String movieId) async {
    if (movieId.isEmpty) return;
    final uri = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tmdbmovieinfo', 'movie_id': movieId});
    try {
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kon filmdetails niet ophalen')),
        );
        return;
      }
      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      final imdbId = jsonData?['imdb_id']?.toString();
      if (imdbId != null && imdbId.isNotEmpty) {
        final imdbNonNull = imdbId!;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: imdbNonNull)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen IMDb ID gevonden voor deze film')),
        );
      }
    } catch (e) {
      debugPrint('Failed openTmdbMovieDetail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fout bij ophalen filmdetails')),
      );
    }
  }

  Future<void> _openTmdbDetailFromItem(MovieSearchItem item) async {
    final tmdbId = item.tmdbId ?? '';
    if (tmdbId.isEmpty) return;

    final isTv = (item.raw['first_air_date'] != null) || (item.raw['media_type'] == 'tv');

    final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies').replace(queryParameters: isTv
        ? {'type': 'tmdbserieinfo', 'tv_id': tmdbId}
        : {'type': 'tmdbmovieinfo', 'movie_id': tmdbId});

    try {
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isTv ? 'Kon seriedetails niet ophalen' : 'Kon filmdetails niet ophalen')),
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
        final imdbNonNull = imdbId;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: imdbNonNull)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isTv ? 'Geen IMDb ID gevonden voor deze serie' : 'Geen IMDb ID gevonden voor deze film')),
        );
      }
    } catch (e) {
      debugPrint('Failed openTmdbDetail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isTv ? 'Fout bij ophalen seriedetails' : 'Fout bij ophalen filmdetails')),
      );
    }
  }

  /// Haalt TMDb poster op via backend fallback
  Future<String?> _fetchTmdbPoster(String? tmdbIdRaw) async {
    if (tmdbIdRaw == null) return null;
    final parts = tmdbIdRaw.split('/');
    final movieId = parts.length > 1 ? parts.last : tmdbIdRaw;

    final uri = Uri.parse(
      'https://film-flix-olive.vercel.app/apiv2/movies',
    ).replace(queryParameters: {'type': 'tmdb-images', 'movie_id': movieId});

    try {
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
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

      return 'https://image.tmdb.org/t/p/original$filePath';
    } catch (e) {
      debugPrint('Error fetching TMDb poster: $e');
      return null;
    }
  }

  String proxiedUrl(String url) {
    return 'https://film-flix-olive.vercel.app/apiv2/movies'
        '?type=image-proxy'
        '&imageUrl=${Uri.encodeComponent(url)}';
  }

  Future<void> _ensureEnvLoaded() async {
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
      if (kDebugMode) debugPrint('Failed to load .env: $e');
    }
  }

  Future<Uint8List?> _fetchProxiedImageBytes(String originalUrl) async {
    if (_imageCache.containsKey(originalUrl)) return _imageCache[originalUrl];
    await _ensureEnvLoaded();
    try {
      final uri = Uri.parse('https://film-flix-olive.vercel.app/apiv2/movies')
          .replace(queryParameters: {
        'type': 'image-proxy',
        'imageUrl': originalUrl,
      });
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
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
    return _imageFromProxied(movie.poster ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        title: Text(
          "Search",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Zoek serie/film...",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                prefixIcon: controller.text.isNotEmpty || results.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      tooltip: 'Wissen',
                      onPressed: () {
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
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      tooltip: 'Filter',
                      onPressed: () => _openFilterModal(context),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      onPressed: search,
                    ),
                  ],
                ),
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
            const Expanded(child: Center(child: CircularProgressIndicator()))
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
                    itemCount: results.length,
                    itemBuilder: (_, index) {
                      final movie = results[index];

                      return GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  imdbId: movie.id,
                                ),
                              ),
                            ),
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
                                color: isDark ? Colors.white : Colors.black87,
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
                            child: const Text(
                              'Laad meer resultaten',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                    ),
                ],
              ),
            )
          else
            // show two tabs: Best Rated and Populair
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Best Rated'),
                        Tab(text: 'Populair'),
                      ],
                      labelColor: isDark ? Colors.white : Colors.black87,
                      indicatorColor: isDark ? Colors.white : Colors.black87,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Best Rated
                          loadingTopRated
                              ? const Center(child: CircularProgressIndicator())
                              : GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.6,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: topRated.length,
                                  itemBuilder: (_, index) {
                                    final movie = topRated[index];
                                    return GestureDetector(
                                      onTap: () => _openTmdbDetailFromItem(movie),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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

                          // Populair
                          loadingPopular
                              ? const Center(child: CircularProgressIndicator())
                              : GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 0.6,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                      ),
                                  itemCount: popular.length,
                                  itemBuilder: (_, index) {
                                    final movie = popular[index];
                                    return GestureDetector(
                                      onTap: () => _openTmdbDetailFromItem(movie),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

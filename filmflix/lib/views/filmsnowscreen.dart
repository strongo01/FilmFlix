import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cinetrackr/views/movie_detail_screen.dart';

class FilmNowItem {
  final String tmdbId;
  final String title;
  final String? poster;
  final String? backdrop;
  String? imdbId;

  FilmNowItem({
    required this.tmdbId,
    required this.title,
    this.poster,
    this.backdrop,
    this.imdbId,
  });
}

class FilmNowScreen extends StatefulWidget {
  const FilmNowScreen({super.key});

  @override
  State<FilmNowScreen> createState() => _FilmNowScreenState();
}

class _FilmNowScreenState extends State<FilmNowScreen> {
  final String baseApi = 'https://film-flix-olive.vercel.app/apiv2/movies';
  String? _xAppApiKey;
  final Map<String, Uint8List> _imageCache = {};
  List<FilmNowItem> films = [];
  bool loading = true;
  bool error = false;
  int currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    _loadNowPlaying();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadNowPlaying() async {
    setState(() {
      loading = true;
      error = false;
    });

    try {
      final uri = Uri.parse(baseApi).replace(
        queryParameters: {
          'type': 'actualfilms',
          'page': '1',
          'language': 'nl-NL',
          'region': 'NL',
        },
      );
      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200)
        throw Exception('Upstream status ${resp.statusCode}');

      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      if (jsonData == null) throw Exception('Invalid JSON');

      final results = (jsonData['results'] as List<dynamic>?) ?? [];
      final temp = <FilmNowItem>[];

      for (final r in results) {
        try {
          final map = r as Map<String, dynamic>;
          final tmdbId = (map['id'] ?? '').toString();
          final title = (map['title'] ?? map['original_title'] ?? '')
              .toString();

          String? poster;
          String? backdrop;

          final posterPath = map['poster_path'] as String?;
          final backdropPath = map['backdrop_path'] as String?;

          if (posterPath != null && posterPath.isNotEmpty) {
            poster = 'https://image.tmdb.org/t/p/w500$posterPath';
          }

          if (backdropPath != null && backdropPath.isNotEmpty) {
            backdrop = 'https://image.tmdb.org/t/p/original$backdropPath';
          }

          if (tmdbId.isNotEmpty && title.isNotEmpty) {
            temp.add(
              FilmNowItem(
                tmdbId: tmdbId,
                title: title,
                poster: poster,
                backdrop: backdrop,
              ),
            );
          }
        } catch (_) {
          // skip malformed entry
        }
      }

      // Voor elk TMDB item: haal imdb_id op via jouw backend (tmdbmovieinfo)
      final futures = temp.map((item) => _fetchImdbIdFor(item));
      await Future.wait(futures);

      setState(() {
        films = temp;
        loading = false;
      });
    } catch (e, st) {
      debugPrint('Error loading now playing: $e\n$st');
      setState(() {
        loading = false;
        error = true;
      });
    }
  }

  Widget _backdropWidget(FilmNowItem item) {
    final backdrop = item.backdrop;

    if (backdrop == null || backdrop.isEmpty) {
      return _posterWidget(item); // fallback naar poster
    }

    return _proxiedImage(backdrop, fit: BoxFit.cover);
  }

  Future<void> _fetchImdbIdFor(FilmNowItem item) async {
    try {
      final uri = Uri.parse(baseApi).replace(
        queryParameters: {
          'type': 'tmdbmovieinfo',
          'movie_id': item.tmdbId,
          'language': 'en-US',
        },
      );

      await _ensureEnvLoaded();
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) return;

      final jsonData = jsonDecode(resp.body) as Map<String, dynamic>?;
      if (jsonData == null) return;

      final imdbIdRaw = jsonData['imdb_id'] as String?;
      if (imdbIdRaw != null && imdbIdRaw.isNotEmpty) {
        item.imdbId = imdbIdRaw;
      }
    } catch (e) {
      debugPrint('Error fetching imdb for ${item.tmdbId}: $e');
    }
  }

  String proxiedUrl(String url) {
    return '$baseApi?type=image-proxy&imageUrl=${Uri.encodeComponent(url)}';
  }

  Widget _proxiedImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    return FutureBuilder<Uint8List?>(
      future: _fetchProxiedImageBytes(imageUrl),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(color: Colors.grey[300]);
        }
        final bytes = snap.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            fit: fit,
            gaplessPlayback: true,
          );
        }
        return Container(color: Colors.grey[300]);
      },
    );
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

  Future<Uint8List?> _fetchProxiedImageBytes(String url) async {
    if (_imageCache.containsKey(url)) return _imageCache[url];
    await _ensureEnvLoaded();
    try {
      final uri = Uri.parse(baseApi).replace(queryParameters: {
        'type': 'image-proxy',
        'imageUrl': url,
      });
      final headers = <String, String>{};
      if (_xAppApiKey != null && _xAppApiKey!.isNotEmpty) headers['x-app-api-key'] = _xAppApiKey!;
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200) {
        _imageCache[url] = resp.bodyBytes;
        return resp.bodyBytes;
      }
    } catch (e) {
      debugPrint('Error fetching proxied image: $e');
    }
    return null;
  }

  /// Fallback: als poster missing of mislukte proxy -> probeer TMDb images endpoint
  Future<String?> _fetchTmdbPoster(String tmdbId) async {
    try {
      final uri = Uri.parse(
        baseApi,
      ).replace(queryParameters: {'type': 'tmdb-images', 'movie_id': tmdbId});
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
      debugPrint('Error fetching tmdb poster: $e');
      return null;
    }
  }

  Widget _posterWidget(FilmNowItem item) {
    final poster = item.poster;

    if (poster == null || poster.isEmpty) {
      // direct TMDb fallback
      return FutureBuilder<String?>(
        future: _fetchTmdbPoster(item.tmdbId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Container(color: Colors.grey[300]);
          }
          final url = snap.data;
          if (url != null && url.isNotEmpty) {
            return _proxiedImage(url, fit: BoxFit.cover);
          }
          return Container(color: Colors.grey[300]);
        },
      );
    }

    // There is a poster URL -> try proxy (via header-using fetch)
    return _proxiedImage(poster, fit: BoxFit.cover);
  }

  void _openDetails(FilmNowItem item) {
    if (item.imdbId != null && item.imdbId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(imdbId: item.imdbId!),
        ),
      );
    } else {
      // fallback: show message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('IMDb ID niet beschikbaar voor deze film'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Carrousel
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = screenWidth * 1.2; // Was 9 / 16, nu groter

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Actuele films',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        elevation: 0.5,
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Kon actuele films niet laden.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadNowPlaying,
                      child: const Text('Opnieuw proberen'),
                    ),
                  ],
                ),
              )
            : films.isEmpty
            ? const Center(child: Text('Geen films gevonden'))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    SizedBox(
                      height: carouselHeight,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: films.length,
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemBuilder: (context, index) {
                          final film = films[index];
                          final scale = index == currentIndex ? 1.0 : 0.96;

                          return AnimatedPadding(
                            duration: const Duration(milliseconds: 260),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: index == currentIndex ? 0 : 8,
                            ),
                            child: Transform.scale(
                              scale: scale,
                              child: GestureDetector(
                                onTap: () => _openDetails(film),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _backdropWidget(film),
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.75),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            film.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dots indicator + quick thumbnails strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        films.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == currentIndex ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Kleine scrollable thumbnails onderaan
                    SizedBox(
                      height: 180, // Was 110
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: films.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12), // Was 8
                        itemBuilder: (context, i) {
                          final f = films[i];
                          return GestureDetector(
                            onTap: () {
                              // jump to page and open details when tapped twice quickly
                              _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            onDoubleTap: () => _openDetails(f),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 120, // Was 78
                                child: f.poster != null
                                    ? _proxiedImage(f.poster!, fit: BoxFit.cover)
                                    : FutureBuilder<String?>(
                                        future: _fetchTmdbPoster(f.tmdbId),
                                        builder: (ctx, snap) {
                                          if (snap.connectionState ==
                                              ConnectionState.waiting)
                                            return Container(
                                              color: Colors.grey[300],
                                            );
                                          final url = snap.data;
                                          if (url != null && url.isNotEmpty) {
                                            return _proxiedImage(url, fit: BoxFit.cover);
                                          }
                                          return Container(
                                            color: Colors.grey[300],
                                          );
                                        },
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

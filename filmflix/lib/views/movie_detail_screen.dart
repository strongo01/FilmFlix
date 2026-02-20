import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filmflix/services/movie_repository.dart';
import 'package:http/http.dart' as http;

class MovieDetailScreen extends StatelessWidget {
  final String imdbId;

  const MovieDetailScreen({super.key, required this.imdbId});

  static const Map<String, String> _serviceAssetMap = {
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

  Future<void> _openLink(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch url: $url');
    }
  }

  /// Normaliseer input (Map met numeric keys of List) naar List<dynamic>
  List<dynamic> _toList(dynamic maybeListOrMap) {
    if (maybeListOrMap == null) return [];
    if (maybeListOrMap is List) return maybeListOrMap;
    if (maybeListOrMap is Map) {
      // Map might have numeric keys like { "0": {...}, "1": {...} }
      // or arbitrary string keys. We convert to list of values.
      return maybeListOrMap.entries.map((e) => e.value).toList();
    }
    // Unexpected type
    return [];
  }

  Widget _buildServiceIconAsset(
    String? serviceName, {
    double height = 28,
    required BuildContext context,
  }) {
    if (serviceName == null) return const Icon(Icons.tv);

    final key = _serviceAssetMap.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == serviceName.toLowerCase(),
          orElse: () => const MapEntry('', ''),
        )
        .value;

    if (key.isEmpty) return const Icon(Icons.tv);

    // Detecteer of de app dark mode gebruikt
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folder = isDark ? 'dark' : 'light';

    final path = 'assets/logos/$folder/$key.png';
    return Image.asset(path, height: height);
  }

  /// Haalt TMDb images op via jouw backend endpoint:
  /// https://film-flix-olive.vercel.app/api/movies?type=tmdb-images&movie_id=XXXX
  /// movieId moet zonder "movie/" prefix (dus 1321624)
  Future<String?> _fetchTmdbPosterFromRapid(Map<String, dynamic> rapid) async {
    try {
      final tmdbIdRaw = rapid['tmdbId']?.toString();
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

      final json = jsonDecode(resp.body) as Map<String, dynamic>?;

      if (json == null) return null;

      // posters array
      final postersRaw = json['posters'];
      final postersList = _toList(postersRaw).cast<Map<String, dynamic>>();

      // prefer posters with iso_3166_1 == 'US'
      Map<String, dynamic>? chosen;
      for (final p in postersList) {
        final country = (p['iso_3166_1'] ?? '').toString();
        if (country.toUpperCase() == 'US') {
          chosen = p;
          break;
        }
      }
      // if none found, pick first poster
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

      // Build full TMDb URL (original size)
      final url = 'https://image.tmdb.org/t/p/original${filePath}';
      debugPrint('Using TMDb poster URL: $url');
      return url;
    } catch (e, s) {
      debugPrint('Error fetching tmdb poster: $e\n$s');
      return null;
    }
  }

  /// Widget that tries to display poster. If the provided poster URL fails to load
  /// we call _fetchTmdbPosterFromRapid(...) and try that URL.
  Widget _posterWithFallback(
    BuildContext context,
    String? initialPoster,
    Map<String, dynamic> rapid,
  ) {
    if (initialPoster == null || initialPoster.isEmpty) {
      // no initial poster — fetch TMDb immediately
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
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
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
        initialPoster,
        fit: BoxFit.cover,
        // If this fails (invalid image data), errorBuilder runs and we show a FutureBuilder
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
                return Image.network(
                  url,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: FutureBuilder(
        future: MovieRepository.getFullMovie(imdbId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final movie = snapshot.data!;
          final rapid = movie.rapid as Map<String, dynamic>;
          final omdb = movie.omdb as Map<String, dynamic>?;

          // poster fallback: rapid imageSet -> omdb Poster
          final poster =
              (rapid['imageSet']?['verticalPoster']?['w480'] ??
                      rapid['imageSet']?['verticalPoster']?['w300'] ??
                      omdb?['Poster'])
                  ?.toString();

          final title = (rapid['title'] ?? omdb?['Title'] ?? '').toString();
          final overview = (rapid['overview'] ?? omdb?['Plot'] ?? '')
              .toString();
          final rating =
              (omdb?['imdbRating'] ?? rapid['rating']?.toString() ?? '-')
                  .toString();

          // Normalize lists (robust for Map-with-numeric-keys)
          final genres = _toList(rapid['genres']).map((g) {
            if (g is Map && g.containsKey('name')) return g['name'].toString();
            return g.toString();
          }).toList();

          final creators = _toList(
            rapid['creators'],
          ).map((c) => c.toString()).toList();
          final cast = _toList(rapid['cast']).map((c) => c.toString()).toList();

          // seasons and global streaming
          final seasonsRaw = rapid['seasons'];
          final seasons = _toList(seasonsRaw);
          //final streamingRaw = rapid['streamingOptions']?['nl'];
          final streaming = _toList(rapid['streamingOptions']?['nl']);

          // DEBUG prints so you can inspect the exact structure in console
          debugPrint('IMDB ID: $imdbId');
          debugPrint('Poster: $poster');
          debugPrint(
            'Seasons (raw type): ${seasonsRaw?.runtimeType}, normalized length = ${seasons.length}',
          );
          for (var i = 0; i < seasons.length; i++) {
            final s = seasons[i];
            final sTitle = s is Map
                ? (s['title'] ?? s['itemType'] ?? 'season#$i')
                : 'season#$i';
            final epRaw = s is Map ? s['episodes'] : null;
            final eps = _toList(epRaw);
            debugPrint(
              '  Season $i: $sTitle, episodes count (normalized) = ${eps.length}',
            );
          }
          debugPrint('Streaming options normalized: ${streaming.length}');
          for (var i = 0; i < streaming.length; i++) {
            final opt = streaming[i];
            final service = opt is Map ? opt['service'] : null;
            debugPrint(
              '  stream[$i] service=${service?['name']} icon=${service?['imageSet']?['lightThemeImage']} link=${opt['link']}',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                // REPLACED: now uses poster fallback helper so we can try TMDb when invalid image data occurs
                _posterWithFallback(context, poster, rapid),

                const SizedBox(height: 12),

                // Main Info card
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(overview),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 6),
                            Text(rating),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (genres.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: genres
                                .map(
                                  (g) => Chip(
                                    label: Text(g),
                                    backgroundColor: Colors.blue.shade50,
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        if (creators.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: creators
                                .map(
                                  (c) => Chip(
                                    label: Text(c),
                                    backgroundColor: Colors.green.shade50,
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        if (cast.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cast
                                .take(8)
                                .map(
                                  (c) => Chip(
                                    label: Text(c),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        Text('Seasons: ${rapid['seasonCount'] ?? '-'}'),
                        Text('Episodes: ${rapid['episodeCount'] ?? '-'}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Streaming card
                if (streaming.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Streaming',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...streaming.map((option) {
                            final service = (option is Map)
                                ? option['service'] as Map<String, dynamic>?
                                : null;
                            // link is often on the option root (option['link'])
                            final link = (option is Map)
                                ? (option['link'] ??
                                      option['service']?['homePage'])
                                : null;
                            return ListTile(
                              leading: _buildServiceIconAsset(
                                service?['name'],
                                height: 28,
                                context: context,
                              ),
                              title: Text(
                                service?['name']?.toString() ?? 'Service',
                              ),
                              subtitle: link != null
                                  ? Text(
                                      link.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    )
                                  : null,
                              onTap: () => _openLink(link?.toString()),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Seasons & Episodes expansion
                if (seasons.isNotEmpty)
                  Card(
                    child: ExpansionTile(
                      title: Text(
                        'Seasons & Episodes (${seasons.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: seasons.map((seasonRaw) {
                        final season = (seasonRaw is Map)
                            ? seasonRaw
                            : {'title': seasonRaw.toString()};
                        final seasonTitle =
                            (season['title'] ?? season['itemType'] ?? 'Season')
                                .toString();
                        final firstYear =
                            season['firstAirYear']?.toString() ?? '';
                        final lastYear =
                            season['lastAirYear']?.toString() ?? '';
                        final epRaw = season['episodes'];
                        final episodes = _toList(epRaw);

                        return ExpansionTile(
                          title: Text(seasonTitle),
                          subtitle: Text(
                            '$firstYear${lastYear.isNotEmpty ? ' - $lastYear' : ''}',
                          ),
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
                              : episodes.map((epRaw) {
                                  final ep = (epRaw is Map)
                                      ? epRaw
                                      : {'title': epRaw.toString()};
                                  final epTitle =
                                      (ep['title'] ??
                                              ep['itemType'] ??
                                              'Episode')
                                          .toString();
                                  final epOverview = (ep['overview'] ?? '')
                                      .toString();

                                  // episode-level streaming may be nested similar to series streaming
                                  final epStreamRaw =
                                      ep['streamingOptions']?['nl'] ??
                                      ep['streamingOptions'];
                                  final epStreams = _toList(epStreamRaw);
                                  String? epLink;
                                  if (epStreams.isNotEmpty) {
                                    final first = epStreams[0];
                                    if (first is Map) {
                                      epLink =
                                          first['link'] ??
                                          first['service']?['homePage']
                                              ?.toString();
                                    }
                                  }

                                  // optional small thumbnail (if available)
                                  final epThumb =
                                      ep['imageSet']?['verticalPoster']?['w160'] ??
                                      ep['image'] ??
                                      null;

                                  return Column(
                                    children: [
                                      ListTile(
                                        leading: epThumb != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  epThumb.toString(),
                                                  width: 84,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                      ),
                                                ),
                                              )
                                            : null,
                                        title: Text(
                                          epTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        subtitle: epOverview.isNotEmpty
                                            ? Text(
                                                epOverview,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : null,
                                        trailing: epLink != null
                                            ? IconButton(
                                                icon: const Icon(
                                                  Icons.play_arrow,
                                                ),
                                                onPressed: () => _openLink(
                                                  epLink.toString(),
                                                ),
                                              )
                                            : null,
                                      ),
                                      const Divider(height: 1),
                                    ],
                                  );
                                }).toList(),
                        );
                      }).toList(),
                    ),
                  ),

                if (seasons.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'Geen seizoenen gevonden',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

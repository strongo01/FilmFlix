import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filmflix/views/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filmflix/services/movie_repository.dart';
import 'package:http/http.dart' as http;

class MovieDetailScreen extends StatefulWidget {
  final String imdbId;

  const MovieDetailScreen({super.key, required this.imdbId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
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

  String _formatStreamingType(Map<String, dynamic> option) {
    final type = option['type']?.toString();

    switch (type) {
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

    return Chip(label: Text(label), backgroundColor: bg);
  }

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

  List<dynamic> _toList(dynamic maybeListOrMap) {
    if (maybeListOrMap == null) return [];
    if (maybeListOrMap is List) return maybeListOrMap;
    if (maybeListOrMap is Map) {
      return maybeListOrMap.entries.map((e) => e.value).toList();
    }
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

  Future<void> _translateText(String key, String originalText) async {
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

  User? _user;
  StreamSubscription<User?>? _authSub;
  bool _isInWatchlist = false;
  final Set<String> _seenSet = {}; // holds episode keys like 's0_e1'
  bool _loadingUserData = false;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;

    _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() {
        _user = u;
      });
      if (u != null)
        _loadUserData();
      else {
        setState(() {
          _isInWatchlist = false;
          _seenSet.clear();
        });
      }
    });
    if (_user != null) _loadUserData();

    _loadMovie();
  }

  Future<void> _loadMovie() async {
    try {
      final movie = await MovieRepository.getFullMovie(widget.imdbId);
      final rapid = movie.rapid as Map<String, dynamic>;
      final omdb = movie.omdb as Map<String, dynamic>?;
      final poster =
          (rapid['imageSet']?['verticalPoster']?['w480'] ??
                  rapid['imageSet']?['verticalPoster']?['w300'] ??
                  omdb?['Poster'])
              ?.toString();

      setState(() {
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
              (g) => (g is Map && g.containsKey('name') ? g['name'] : g)
                  .toString(),
            )
            .toSet();

        final omdbGenresRaw = omdb?['Genre']?.toString() ?? '';
        final omdbGenres = omdbGenresRaw
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toSet();

        _genres = {...rapidGenres, ...omdbGenres}.toList();

        _creators = _toList(
          rapid['creators'],
        ).map((c) => c.toString()).toList();
        _cast = _toList(rapid['cast']).map((c) => c.toString()).toList();
        _seasons = _toList(rapid['seasons']);
        _streaming = _toList(rapid['streamingOptions']?['nl']);
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
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    setState(() {
      _loadingUserData = true;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .get();
      final data = doc.data() ?? {};
      debugPrint('--- DEBUG USER DATA FOR ${widget.imdbId} ---');
      debugPrint('Firestore keys: ${data.keys.toList()}');

      final watchlist = (data['watchlist'] is List)
          ? List<String>.from(data['watchlist'])
          : <String>[];

      // Robuuste check voor seenEpisodes (genest of plat veld)
      final seenMap = data['seenEpisodes'];
      List<dynamic> rawSeen = [];

      // 1. Probeer platte keys (mocht Firestore het als één veld hebben opgeslagen)
      final flatKey = 'seenEpisodes.${widget.imdbId}';
      final flatKeyLower = 'seenEpisodes.${widget.imdbId.toLowerCase()}';

      if (data.containsKey(flatKey) && data[flatKey] is List) {
        rawSeen = data[flatKey];
      } else if (data.containsKey(flatKeyLower) && data[flatKeyLower] is List) {
        rawSeen = data[flatKeyLower];
      }
      // 2. Probeer geneste structuur (Map)
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
    if (_user != null) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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

    if (result != true || !mounted) return false;

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
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    final newState = !_isInWatchlist;

    // Optimistic update
    setState(() => _isInWatchlist = newState);

    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      if (newState) {
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
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;

    // Optimistic update
    setState(() {
      if (seen) {
        _seenSet.add(epKey);
      } else {
        _seenSet.remove(epKey);
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
      // rollback UI
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

    grouped.forEach((serviceName, options) {
      // Sorteer types: subscription → rent → buy
      options.sort(
        (a, b) => _typePriority(a['type']) - _typePriority(b['type']),
      );

      // Per type unieke opties
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
              // Service naam + icoon
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Per type unieke opties
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: uniqueOptions.values.map((option) {
                  final link = option['link'] ?? option['service']?['homePage'];
                  final chip = _buildTypeChip(option);

                  // Chip zelf is klikbaar, maar geen URL-tekst ernaast
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
    final season = (seasonRaw is Map)
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
    String? epLink;
    if (epStreams.isNotEmpty) {
      final first = epStreams[0];
      if (first is Map) {
        epLink = first['link'] ?? first['service']?['homePage']?.toString();
      }
    }

    // thumbnail
    final epThumb =
        ep['imageSet']?['verticalPoster']?['w160'] ?? ep['image'] ?? null;

    // stable episode key for storage
    final epKey = 's${seasonIndex}_e${episodeIndex}';
    final isSeen = _seenSet.contains(epKey);

    return Column(
      children: [
        ListTile(
          leading: epThumb != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    epThumb.toString(),
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
              if (epStreams.isNotEmpty)
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

              // seen checkbox (always shown)
              Checkbox(
                value: _seenSet.contains(epKey),
                onChanged: (val) async {
                  if (_user == null) {
                    final go = await _ensureLoggedInWithPrompt(context);
                    if (!go) return;
                  }
                  await _toggleEpisodeSeen(epKey, val ?? false);
                  // Trigger rebuild zodat checkbox update
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
    final omdb = _omdbData;
    final poster = _poster;

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_translatedTexts['overview'] ?? _overview ?? ''),
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
                        Text(_rating ?? ''),

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
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.family_restroom_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text('Leeftijdsclassificatie: $_rated'),
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
                                backgroundColor: Colors.blue.shade50,
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    // Creators
                    // Creators
                    if (_creators.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Producers / Creators',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                                  backgroundColor: Colors.green.shade50,
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
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Text(
                              'Actors',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
                                  backgroundColor: Colors.grey.shade200,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Text('Seizoenen: ${rapid['seasonCount'] ?? '-'}'),
                    Text('Afleveringen: ${rapid['episodeCount'] ?? '-'}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Streaming card
            if (_streaming.isNotEmpty)
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
                child: ExpansionTile(
                  title: Text(
                    'Seizoenen & Afleveringen (${_seasons.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

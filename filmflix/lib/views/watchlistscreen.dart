import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cinetrackr/services/movie_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  Future<void> _toggleEpisodeSeenForUser(
    String imdbId,
    String epKey,
    bool seen,
  ) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in om voortgang te bewaren')),
      );
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      if (seen) {
        await docRef.set({
          'seenEpisodes.$imdbId': FieldValue.arrayUnion([epKey]),
        }, SetOptions(merge: true));
      } else {
        if (epKey == 'movie') {
          // remove whole field when unchecking a movie 'Gezien' marker
          await docRef.set({
            'seenEpisodes.$imdbId': FieldValue.delete(),
          }, SetOptions(merge: true));
        } else {
          await docRef.set({
            'seenEpisodes.$imdbId': FieldValue.arrayRemove([epKey]),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('Failed to toggle seen $epKey for $imdbId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon voortgang niet bijwerken')),
      );
    }
  }

  Future<void> _openLink(String? url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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

  Widget _buildServiceIconAsset(String? serviceName, {double height = 28, required BuildContext context}) {
    if (serviceName == null) return const Icon(Icons.tv);
    final key = _serviceAssetMap.entries
        .firstWhere((entry) => entry.key.toLowerCase() == serviceName.toLowerCase(), orElse: () => const MapEntry('', ''))
        .value;
    if (key.isEmpty) return const Icon(Icons.tv);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folder = isDark ? 'dark' : 'light';
    final path = 'assets/logos/$folder/$key.png';
    return Image.asset(path, height: height);
  }

  String _formatStreamingType(Map<String, dynamic> option) {
    final type = option['type']?.toString();
    final price = option['price']?['formatted'];
    switch (type) {
      case 'subscription':
        return 'Inbegrepen';
      case 'buy':
        return price != null ? 'Kopen • $price' : 'Kopen';
      case 'rent':
        return price != null ? 'Huren • $price' : 'Huren';
      default:
        return type ?? '';
    }
  }

  // Build a ListTile quickly from stored metadata to avoid extra API calls.
  String _truncate(String? s, [int max = 120]) {
    if (s == null) return '';
    final clean = s.replaceAll('\n', ' ').trim();
    if (clean.length <= max) return clean;
    return '${clean.substring(0, max).trim()}…';
  }

  Widget _metaTile(
    String id,
    Map meta,
    bool showProgress,
    Map<String, dynamic> seenMap,
  ) {
    final title = meta['title']?.toString() ?? id;
    final overview = _truncate(meta['overview']?.toString());
    final isSeries = (meta['type']?.toString().toLowerCase() ?? '').contains(
      'series',
    );
    int seenCount = 0;
    if (showProgress) {
      final val = seenMap[id];
      if (val is List) seenCount = val.length;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        child: Icon(isSeries ? Icons.tv : Icons.movie, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: overview.isNotEmpty
          ? Text(overview, maxLines: 2, overflow: TextOverflow.ellipsis)
          : const Text('Open details'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSeries)
                Chip(
                  label: const Text('Series'),
                  visualDensity: VisualDensity.compact,
                ),
              if (showProgress) SizedBox(height: 6),
              if (showProgress)
                Chip(
                  label: Text('Gezien: $seenCount'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.bookmark_remove_outlined),
            tooltip: 'Verwijder uit watchlist',
            onPressed: () => _confirmAndRemove(id),
          ),
        ],
      ),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: id))),
    );
  }

  // Build a ListTile using MovieRepository when metadata is not available.
  Widget _futureTile(
    String id,
    Future movieFuture,
    bool showProgress,
    Map<String, dynamic> seenMap,
  ) {
    return FutureBuilder(
      future: movieFuture,
      builder: (ctx, snapMovie) {
        String title = id;
        String subtitle = 'Open details';
        bool isSeries = false;
        int seenCount = 0;
        if (snapMovie.hasData) {
          final md = snapMovie.data as dynamic;
          try {
            final rapid = md.rapid as Map<String, dynamic>?;
            final omdb = md.omdb as Map<String, dynamic>?;
            title = (rapid != null && (rapid['title'] ?? rapid['name']) != null)
                ? (rapid['title'] ?? rapid['name']).toString()
                : (omdb != null && omdb['Title'] != null)
                ? omdb['Title'].toString()
                : id;
            final omdbType = omdb != null
                ? (omdb['Type']?.toString().toLowerCase())
                : null;
            if (omdbType == 'series') isSeries = true;
            if (rapid != null &&
                rapid['type'] != null &&
                rapid['type'].toString().toLowerCase().contains('series'))
              isSeries = true;
            // try to get a short overview if available
            final overviewRaw = rapid?['overview'] ?? omdb?['Plot'];
            subtitle = _truncate(overviewRaw?.toString());
          } catch (_) {}
        }

        if (showProgress) {
          final val = seenMap[id];
          if (val is List) seenCount = val.length;
          // if we already have an overview subtitle, append progress else replace
          subtitle = subtitle.isNotEmpty && subtitle != 'Open details'
              ? '${subtitle}\nGezien: $seenCount'
              : (isSeries ? 'Gezien afleveringen: $seenCount' : 'Open details');
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 26,
            child: Icon(isSeries ? Icons.tv : Icons.movie, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                Chip(
                  label: Text('Gezien: $seenCount'),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined),
                tooltip: 'Verwijder uit watchlist',
                onPressed: () => _confirmAndRemove(id),
              ),
            ],
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: id)),
          ),
        );
      },
    );
  }

  Future<void> _removeFromWatchlist(String imdbId) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in om watchlist te beheren')),
      );
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      await docRef.set({
        'watchlist': FieldValue.arrayRemove([imdbId]),
        'watchlist_meta.$imdbId': FieldValue.delete(),
      }, SetOptions(merge: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item verwijderd uit watchlist')),
      );
    } catch (e) {
      debugPrint('Failed to remove $imdbId from watchlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon item niet verwijderen')),
      );
    }
  }

  Future<void> _confirmAndRemove(String imdbId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verwijderen uit watchlist'),
        content: const Text(
          'Weet je zeker dat je dit item uit je watchlist wilt verwijderen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeFromWatchlist(imdbId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Watchlist'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Opgeslagen'),
              Tab(text: 'Aan het kijken'),
            ],
          ),
        ),
        body: user == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Je bent niet ingelogd.'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // navigate to login screen if available
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: const Text('Inloggen'),
                      ),
                    ],
                  ),
                ),
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (ctx, snap) {
                  if (snap.hasError)
                    return Center(child: Text('Fout bij laden: ${snap.error}'));
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final data = snap.data!.data() ?? {};

                  final watchlist =
                      (data['watchlist'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      <String>[];
                  // seenEpisodes may be stored either as a map under 'seenEpisodes'
                  // or as individual fields named 'seenEpisodes.<imdbId>' (Firestore flattened keys).
                  final Map<String, dynamic> seenMap = {};
                  final seenMapRaw = data['seenEpisodes'];
                  if (seenMapRaw is Map) {
                    seenMapRaw.forEach((k, v) => seenMap[k.toString()] = v);
                  }
                  // merge flattened keys like 'seenEpisodes.tt1632701'
                  for (final k in data.keys) {
                    if (k.startsWith('seenEpisodes.')) {
                      final imdb = k.split('.').last;
                      seenMap[imdb] = data[k];
                    }
                  }

                  // watchlist_meta may be stored as a map under 'watchlist_meta'
                  // or as flattened keys like 'watchlist_meta.<imdbId>'
                  final Map<String, dynamic> metaMap = {};
                  final metaRaw = data['watchlist_meta'];
                  if (metaRaw is Map) {
                    metaRaw.forEach((k, v) => metaMap[k.toString()] = v);
                  }
                  for (final k in data.keys) {
                    if (k.startsWith('watchlist_meta.')) {
                      final imdb = k.split('.').last;
                      metaMap[imdb] = data[k];
                    }
                  }

                  bool seenIndicatesMovie(dynamic val) {
                    if (val is List) {
                      for (final e in val) {
                        if (e != null && e.toString().toLowerCase() == 'movie') return true;
                      }
                    }
                    return false;
                  }

                  final savedSeries = watchlist.where((id) {
                    final val = seenMap[id];
                    if (val is List) {
                      // if the saved seen list explicitly contains 'movie', treat as film
                      if (seenIndicatesMovie(val)) return false;
                      return true; // has seen entries (episodes) -> series
                    }
                    return false;
                  }).toList();

                  final savedFilms = watchlist.where((id) {
                    final val = seenMap[id];
                    if (val is List) {
                      if (seenIndicatesMovie(val)) return true;
                      return false;
                    }
                    // no seen entries -> treat as film by default
                    return !seenMap.containsKey(id);
                  }).toList();

                  final watchingSeries = <String>[];
                  final watchingFilms = <String>[];

                  for (final e in seenMap.entries) {
                    final val = e.value;
                    if (val is List) {
                      // if list explicitly contains the marker 'movie', treat as film
                      final hasMovieMarker = val.any((x) => x != null && x.toString().toLowerCase() == 'movie');
                      if (hasMovieMarker) {
                        watchingFilms.add(e.key.toString());
                      } else if (val.isNotEmpty) {
                        // non-empty list of episode keys -> series
                        watchingSeries.add(e.key.toString());
                      }
                    }
                  }

                  Widget buildList(
                    List<String> items, {
                    bool showProgress = false,
                  }) {
                    if (items.isEmpty)
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Geen items'),
                      );
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final id = items[i];
                        final meta = metaMap[id];
                        if (meta is Map && meta['title'] != null) {
                          return _metaTile(id, meta, showProgress, seenMap);
                        }

                        return _futureTile(
                          id,
                          MovieRepository.getFullMovie(id),
                          showProgress,
                          seenMap,
                        );
                      },
                    );
                  }

                  Widget buildWatchingSeries(List<String> ids) {
                    if (ids.isEmpty)
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Geen items'),
                      );
                    return ListView.separated(
                      itemCount: ids.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final id = ids[i];
                        return FutureBuilder(
                          future: MovieRepository.getFullMovie(id),
                          builder: (ctx, snapMovie) {
                            String title = id;
                            final rapid = (snapMovie.hasData
                                ? (snapMovie.data as dynamic).rapid
                                      as Map<String, dynamic>?
                                : null);
                            final meta = metaMap[id];
                            if (meta is Map && meta['title'] != null) {
                              title = meta['title']?.toString() ?? id;
                            } else if (rapid != null) {
                              title = (rapid['title'] ?? rapid['name'] ?? id)
                                  .toString();
                            }

                            final seenForId = seenMap[id];
                            final seenSet = (seenForId is List)
                                ? seenForId.map((e) => e.toString()).toSet()
                                : <String>{};

                            final children = <Widget>[];

                            if (rapid != null && rapid['seasons'] != null) {
                              final seasons = (rapid['seasons'] is List)
                                  ? List.from(rapid['seasons'])
                                  : (rapid['seasons'] is Map
                                        ? (rapid['seasons'] as Map).values
                                              .toList()
                                        : []);

                              for (var si = 0; si < seasons.length; si++) {
                                final season = seasons[si] is Map
                                    ? seasons[si] as Map<String, dynamic>
                                    : {
                                        'title': seasons[si].toString(),
                                        'episodes': [],
                                      };
                                final seasonTitle =
                                    (season['title'] ?? 'Season ${si + 1}')
                                        .toString();
                                final epRaw = season['episodes'];
                                final episodes = epRaw is List
                                    ? epRaw
                                    : (epRaw is Map
                                          ? (epRaw as Map).values.toList()
                                          : []);

                                final seenCount = episodes
                                    .asMap()
                                    .entries
                                    .where(
                                      (entry) => seenSet.contains(
                                        's${si}_e${entry.key}',
                                      ),
                                    )
                                    .length;

                                children.add(
                                  ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 12,
                                    ),
                                    title: Row(
                                      children: [
                                        Chip(label: Text('S${si + 1}')),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            seasonTitle,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$seenCount/${episodes.length} gezien',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    children: [
                                      ...episodes.asMap().entries.map<Widget>((
                                        entry,
                                      ) {
                                        final ei = entry.key;
                                        final ep = entry.value is Map
                                            ? entry.value
                                                  as Map<String, dynamic>
                                            : {'title': entry.value.toString()};
                                        final epTitle =
                                            (ep['title'] ??
                                                    ep['itemType'] ??
                                                    'Episode')
                                                .toString();
                                        final epKey = 's${si}_e${ei}';
                                        final isSeen = seenSet.contains(epKey);

                                        // gather episode streaming options (nl preferred)
                                        final epStreamRaw = ep['streamingOptions']?['nl'] ?? ep['streamingOptions'];
                                        final epStreams = epStreamRaw is List
                                            ? List.from(epStreamRaw)
                                            : (epStreamRaw is Map ? (epStreamRaw as Map).values.toList() : <dynamic>[]);

                                        return ListTile(
                                          leading: Checkbox(
                                            value: isSeen,
                                            onChanged: (val) async {
                                              final newVal = val ?? false;
                                              if (newVal) {
                                                // collect previous unseen episodes in this season
                                                final unseenPrev = <int>[];
                                                for (var p = 0; p < ei; p++) {
                                                  final prevKey = 's${si}_e${p}';
                                                  if (!seenSet.contains(prevKey)) unseenPrev.add(p);
                                                }

                                                if (unseenPrev.isNotEmpty) {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (dctx) => AlertDialog(
                                                      title: const Text('Vorige afleveringen markeren?'),
                                                      content: Text('Je markeert "$epTitle" als gezien. Wil je ook ${unseenPrev.length} vorige aflevering(en) van seizoen ${si + 1} markeren als gezien?'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Nee')),
                                                        TextButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Ja')),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true) {
                                                    for (final p in unseenPrev) {
                                                      await _toggleEpisodeSeenForUser(id, 's${si}_e${p}', true);
                                                    }
                                                    await _toggleEpisodeSeenForUser(id, epKey, true);
                                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${unseenPrev.length + 1} afleveringen gemarkeerd als gezien')));
                                                    return;
                                                  }
                                                }

                                                await _toggleEpisodeSeenForUser(id, epKey, true);
                                              } else {
                                                await _toggleEpisodeSeenForUser(id, epKey, false);
                                              }
                                            },
                                          ),
                                          title: Text(epTitle),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (epStreams.isNotEmpty)
                                                IconButton(
                                                  icon: const Icon(Icons.play_arrow),
                                                  onPressed: () {
                                                    // dedupe per service+type
                                                    final Map<String, Map<String, dynamic>> deduped = {};
                                                    for (var option in epStreams) {
                                                      if (option is! Map) continue;
                                                      final typedOption = option as Map<String, dynamic>;
                                                      final serviceName = typedOption['service']?['name']?.toString() ?? 'Unknown';
                                                      final type = typedOption['type']?.toString() ?? 'other';
                                                      final key = '${serviceName.toLowerCase()}_$type';
                                                      deduped.putIfAbsent(key, () => typedOption);
                                                    }
                                                    final merged = deduped.values.toList();

                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: merged.map<Widget>((option) {
                                                            final service = option['service']?['name']?.toString() ?? 'Unknown';
                                                            final link = option['link'] ?? option['service']?['homePage']?.toString();
                                                            return ListTile(
                                                              leading: _buildServiceIconAsset(service, context: ctx, height: 28),
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
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      const Divider(height: 1),
                                    ],
                                  ),
                                );
                              }
                            } else {
                              children.add(
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text('$title: een moment geduld...'),
                                ),
                              );
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: ExpansionTile(
                                leading: const Icon(Icons.tv),
                                title: Text(title),
                                children: children,
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return TabBarView(
                    children: [
                      // Opgeslagen
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: [
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  title: const Text('Series'),
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: buildList(savedSeries),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  title: const Text('Films'),
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: buildList(savedFilms),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Aan het kijken
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: [
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  title: const Text('Series'),
                                  children: [
                                    SizedBox(
                                      height: 300,
                                      child: buildWatchingSeries(
                                        watchingSeries,
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: const Text('Films'),
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: watchingFilms.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Text(
                                                'Nog geen voortgang voor films',
                                              ),
                                            )
                                          : ListView.separated(
                                              itemCount: watchingFilms.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(height: 1),
                                              itemBuilder: (c, i) {
                                                final id = watchingFilms[i];
                                                final seenForId = seenMap[id];

                                                return FutureBuilder(
                                                  future: MovieRepository.getFullMovie(id),
                                                  builder: (ctx, snapMovie) {
                                                    String title = id;
                                                    // prefer stored metadata from Firestore
                                                    final meta = metaMap[id];
                                                    if (meta is Map && meta['title'] != null) {
                                                      title = meta['title']?.toString() ?? id;
                                                    } else if (snapMovie.hasData) {
                                                      try {
                                                        final md = snapMovie.data as dynamic;
                                                        final rapid = md.rapid as Map<String, dynamic>?;
                                                        final omdb = md.omdb as Map<String, dynamic>?;
                                                        title = (rapid != null && (rapid['title'] ?? rapid['name']) != null)
                                                            ? (rapid['title'] ?? rapid['name']).toString()
                                                            : (omdb != null && omdb['Title'] != null)
                                                                ? omdb['Title'].toString()
                                                                : id;
                                                      } catch (_) {}
                                                    }

                                                    final isSeen = (seenForId is List)
                                                        ? seenForId.map((e) => e.toString()).contains('movie')
                                                        : false;

                                                    return ListTile(
                                                      leading: const Icon(Icons.movie),
                                                      title: Text(title),
                                                      trailing: Checkbox(
                                                        value: isSeen,
                                                        onChanged: (val) async {
                                                          final newVal = val ?? false;
                                                          await _toggleEpisodeSeenForUser(id, 'movie', newVal);
                                                        },
                                                      ),
                                                      onTap: () => Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                          builder: (_) => MovieDetailScreen(imdbId: id),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

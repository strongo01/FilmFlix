import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cinetrackr/services/movie_repository.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  Future<void> _toggleEpisodeSeenForUser(String imdbId, String epKey, bool seen) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log in om voortgang te bewaren')));
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      if (seen) {
        await docRef.set({'seenEpisodes.$imdbId': FieldValue.arrayUnion([epKey])}, SetOptions(merge: true));
      } else {
        await docRef.set({'seenEpisodes.$imdbId': FieldValue.arrayRemove([epKey])}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Failed to toggle seen $epKey for $imdbId: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kon voortgang niet bijwerken')));
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
          bottom: const TabBar(tabs: [Tab(text: 'Opgeslagen'), Tab(text: 'Aan het kijken')]),
        ),
        body: user == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Je bent niet ingelogd.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () async {
                          // navigate to login screen if available
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: const Text('Inloggen')),
                  ]),
                ),
              )
            : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
                builder: (ctx, snap) {
                  if (snap.hasError) return Center(child: Text('Fout bij laden: ${snap.error}'));
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final data = snap.data!.data() ?? {};

                  final watchlist = (data['watchlist'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
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

                  final savedSeries = watchlist.where((id) => seenMap.containsKey(id)).toList();
                  final savedFilms = watchlist.where((id) => !seenMap.containsKey(id)).toList();

                  final watchingSeries = seenMap.entries.where((e) {
                    final val = e.value;
                    if (val is List) return val.isNotEmpty;
                    return false;
                  }).map((e) => e.key.toString()).toList();

                  final watchingFilms = <String>[]; // no explicit film progress field available

                  Widget buildList(List<String> items, {bool showProgress = false}) {
                    if (items.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Geen items'));
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final id = items[i];
                        return FutureBuilder(
                          future: MovieRepository.getFullMovie(id),
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
                                final omdbType = omdb != null ? (omdb['Type']?.toString().toLowerCase()) : null;
                                if (omdbType == 'series') isSeries = true;
                                if (rapid != null && rapid['type'] != null && rapid['type'].toString().toLowerCase().contains('series')) isSeries = true;
                              } catch (_) {}
                            }

                            // progress for series
                            if (showProgress) {
                              final val = seenMap[id];
                              if (val is List) seenCount = val.length;
                              subtitle = isSeries ? 'Gezien afleveringen: $seenCount' : 'Open details';
                            }

                            return ListTile(
                              leading: CircleAvatar(child: Icon(isSeries ? Icons.tv : Icons.movie)),
                              title: Text(title),
                              subtitle: Text(subtitle),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: id)));
                              },
                            );
                          },
                        );
                      },
                    );
                  }

                  Widget buildWatchingSeries(List<String> ids) {
                    if (ids.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Geen items'));
                    return ListView.separated(
                      itemCount: ids.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (c, i) {
                        final id = ids[i];
                        return FutureBuilder(
                          future: MovieRepository.getFullMovie(id),
                          builder: (ctx, snapMovie) {
                            String title = id;
                            final rapid = (snapMovie.hasData ? (snapMovie.data as dynamic).rapid as Map<String, dynamic>? : null);
                            if (rapid != null) {
                              title = (rapid['title'] ?? rapid['name'] ?? id).toString();
                            }

                            final epList = <Widget>[];
                            // build seasons/episodes if available
                            if (rapid != null && rapid['seasons'] != null) {
                              final seasons = (rapid['seasons'] is List) ? List.from(rapid['seasons']) : (rapid['seasons'] is Map ? (rapid['seasons'] as Map).values.toList() : []);
                              for (var si = 0; si < seasons.length; si++) {
                                final season = seasons[si] is Map ? seasons[si] as Map<String, dynamic> : {'title': seasons[si].toString(), 'episodes': []};
                                final seasonTitle = (season['title'] ?? 'Season ${si + 1}').toString();
                                final epRaw = season['episodes'];
                                final episodes = epRaw is List ? epRaw : (epRaw is Map ? (epRaw as Map).values.toList() : []);

                                epList.add(ExpansionTile(
                                  title: Text('$title — $seasonTitle'),
                                  children: episodes.asMap().entries.map<Widget>((entry) {
                                    final ei = entry.key;
                                    final ep = entry.value is Map ? entry.value as Map<String, dynamic> : {'title': entry.value.toString()};
                                    final epTitle = (ep['title'] ?? ep['itemType'] ?? 'Episode').toString();
                                    final epKey = 's${si}_e${ei}';
                                    final seenForId = seenMap[id];
                                    final isSeen = (seenForId is List) ? seenForId.map((e) => e.toString()).contains(epKey) : false;
                                    return CheckboxListTile(
                                      value: isSeen,
                                      title: Text(epTitle),
                                      onChanged: (val) async {
                                        await _toggleEpisodeSeenForUser(id, epKey, val ?? false);
                                      },
                                    );
                                  }).toList(),
                                ));
                              }
                            } else {
                              epList.add(Padding(padding: const EdgeInsets.all(12), child: Text('$title: geen afleveringen beschikbaar')));
                            }

                            return ExpansionTile(
                              leading: const Icon(Icons.tv),
                              title: Text(title),
                              children: epList,
                            );
                          },
                        );
                      },
                    );
                  }

                  return TabBarView(
                    children: [
                      // Opgeslagen
                      Column(children: [
                        Expanded(
                          child: ListView(padding: const EdgeInsets.all(8), children: [
                            ExpansionTile(
                              initiallyExpanded: true,
                              title: const Text('Series'),
                              children: [SizedBox(height: 200, child: buildList(savedSeries))],
                            ),
                            ExpansionTile(
                              initiallyExpanded: true,
                              title: const Text('Films'),
                              children: [SizedBox(height: 200, child: buildList(savedFilms))],
                            ),
                          ]),
                        ),
                      ]),
                      // Aan het kijken
                      Column(children: [
                        Expanded(
                          child: ListView(padding: const EdgeInsets.all(8), children: [
                            ExpansionTile(
                              initiallyExpanded: true,
                              title: const Text('Series'),
                              children: [SizedBox(height: 300, child: buildWatchingSeries(watchingSeries))],
                            ),
                            ExpansionTile(
                              title: const Text('Films'),
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: watchingFilms.isEmpty
                                      ? const Padding(padding: EdgeInsets.all(16), child: Text('Nog geen voortgang voor films'))
                                      : ListView.separated(
                                          itemCount: watchingFilms.length,
                                          separatorBuilder: (_, __) => const Divider(height: 1),
                                          itemBuilder: (c, i) {
                                            final id = watchingFilms[i];
                                            final seenForId = seenMap[id];
                                            final isSeen = (seenForId is List) ? seenForId.map((e) => e.toString()).contains('s0_e0') : false;
                                            return ListTile(
                                              leading: const Icon(Icons.movie),
                                              title: Text(id),
                                              trailing: Checkbox(
                                                value: isSeen,
                                                onChanged: (val) async {
                                                  await _toggleEpisodeSeenForUser(id, 's0_e0', val ?? false);
                                                },
                                              ),
                                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: id))),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ]),
                        ),
                      ]),
                    ],
                  );
                },
              ),
      ),
    );
  }
}


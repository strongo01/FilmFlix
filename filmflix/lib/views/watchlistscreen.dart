import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cinetrackr/services/movie_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'movie_detail_screen.dart';
import 'loginscreen.dart';
import 'package:cinetrackr/l10n/app_localizations.dart';
import 'package:cinetrackr/widgets/app_top_bar.dart';
import 'package:cinetrackr/widgets/app_background.dart';
import 'package:cinetrackr/main.dart'; // Importeert MainNavigation
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:cinetrackr/services/tutorial_service.dart';

class WatchlistScreen extends StatefulWidget {
  static final GlobalKey<_WatchlistScreenState> watchlistScreenKey = GlobalKey<_WatchlistScreenState>();
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final GlobalKey _tabsKey = GlobalKey();
  final GlobalKey _loginButtonKey = GlobalKey();
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    startWatchlistScreenTutorial();
  }

  @override
  void didUpdateWidget(WatchlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    startWatchlistScreenTutorial();
  }

  void startWatchlistScreenTutorial({bool force = false}) async {
    debugPrint("startWatchlistScreenTutorial called with force=$force");
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('tutorial_done_watchlist_screen') ?? false;
    
    if (done && !force) return;

    _tryStart(prefs, force, 0);
  }

  void _tryStart(SharedPreferences prefs, bool force, int attempts) {
    debugPrint("Watchlist _tryStart: attempts=$attempts, force=$force");
    if (!mounted) {
      debugPrint("Watchlist _tryStart: not mounted, aborting.");
      return;
    }
    if (attempts > 10) {
      debugPrint("Watchlist _tryStart: max attempts reached, aborting.");
      return;
    }

    final isCurrentScreen = (MainNavigation.mainKey.currentState as dynamic)?.currentScreenId == 1;
    if (!isCurrentScreen && !force) {
      return; 
    }

    final loc = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    
    // Determine which targets are needed based on login status
    final tabsCtx = _tabsKey.currentContext;
    final loginCtx = _loginButtonKey.currentContext;
    final contentCtx = _contentKey.currentContext;
    
    bool tabsReady = tabsCtx != null && tabsCtx.findRenderObject() != null;
    bool loginReady = user == null ? (loginCtx != null && loginCtx.findRenderObject() != null) : true;
    bool contentReady = user != null ? (contentCtx != null && contentCtx.findRenderObject() != null) : true;

    if (!tabsReady || !loginReady || !contentReady) {
      Future.delayed(const Duration(milliseconds: 200), () => _tryStart(prefs, force, attempts + 1));
      return;
    }

    if (loc != null) {
      _showWatchlistTutorialTargets(loc, prefs, force, user != null);
    }
  }

  void _showWatchlistTutorialTargets(AppLocalizations loc, SharedPreferences prefs, bool force, bool isLoggedIn) {
    List<TargetFocus> targets = [
      TutorialService.createTarget(
        identify: "watchlist-tabs",
        key: _tabsKey,
        text: loc.tutorialWatchlistTabs,
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
      ),
    ];
    
    if (isLoggedIn) {
      targets.add(
        TutorialService.createTarget(
          identify: "watchlist-content",
          key: _contentKey,
          text: loc.tutorialWatchlistContent,
          align: ContentAlign.bottom,
          shape: ShapeLightFocus.RRect,
        ),
      );
    } else {
      targets.add(
        TutorialService.createTarget(
          identify: "watchlist-login",
          key: _loginButtonKey,
          text: loc.tutorialWatchlistLogin,
          align: ContentAlign.top,
          shape: ShapeLightFocus.RRect,
        ),
      );
    }

    TutorialService.checkAndShowTutorial(
      context,
      tutorialKey: force ? 'force_watchlist_screen_tut' : 'watchlist_screen',
      targets: targets,
      onFinish: () async {
        await prefs.setBool('tutorial_done_watchlist_screen', true);
      },
      onSkip: () async {
        await prefs.setBool('tutorial_done_watchlist_screen', true);
      },
    );
  }

  Future<void> _toggleEpisodeSeenForUser(
    String imdbId,
    String epKey,
    bool seen,
  ) async {
    // togglet een episode/film 'Gezien' status voor de ingelogde gebruiker
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.login_progress_save_snack,
          ),
        ),
      );
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    // verwijzing naar gebruikersdocument in Firestore
    try {
      if (seen) {
        await docRef.set({
          'seenEpisodes.$imdbId': FieldValue.arrayUnion([epKey]),
        }, SetOptions(merge: true));
        // voeg epKey toe aan array van geziene episodes voor dit id
      } else {
        if (epKey == 'movie') {
          // verwijder heel veld bij het uitvinken van een film 'Gezien'-markering
          await docRef.set({
            'seenEpisodes.$imdbId': FieldValue.delete(),
          }, SetOptions(merge: true));
          // verwijder heel veld bij unchecken van een film
        } else {
          await docRef.set({
            'seenEpisodes.$imdbId': FieldValue.arrayRemove([epKey]),
          }, SetOptions(merge: true));
          // verwijder enkel het episode-key uit de array
        }
      }
    } catch (e) {
      debugPrint('Failed to toggle seen $epKey for $imdbId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.progress_update_failed),
        ),
      );
    }
  }

  Future<void> _openLink(String? url) async {
    if (url == null) return;
    // open externe link via browser als valide
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
  // map van streamingdienst-namen naar asset-bestandsnamen

  Widget _buildServiceIconAsset(
    String? serviceName, {
    double height = 28,
    required BuildContext context,
  }) {
    if (serviceName == null) return const Icon(Icons.tv);
    // toon default icon als servicenaam ontbreekt
    final key = _serviceAssetMap.entries
        .firstWhere(
          (entry) => entry.key.toLowerCase() == serviceName.toLowerCase(),
          orElse: () => const MapEntry('', ''),
        )
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
        return AppLocalizations.of(context)!.included_with_subscription;
      case 'buy':
        return price != null
            ? AppLocalizations.of(context)!.buy_with_price(price)
            : AppLocalizations.of(context)!.buy;
      case 'rent':
        return price != null
            ? AppLocalizations.of(context)!.rent_with_price(price)
            : AppLocalizations.of(context)!.rent;
      default:
        return type ?? '';
    }
  }
  // formatteert streaming type (subscription/buy/rent) met prijs indien beschikbaar

  // Bouw snel een ListTile uit opgeslagen metadata om extra API-aanroepen te vermijden.
  String _truncate(String? s, [int max = 120]) {
    if (s == null) return '';
    final clean = s.replaceAll('\n', ' ').trim();
    if (clean.length <= max) return clean;
    return '${clean.substring(0, max).trim()}…';
  }
  // verkort tekst en verwijdert nieuwe regels

  String _getEpisodeTitle(dynamic ep, BuildContext ctx) {
    try {
      dynamic val;
      if (ep is Map) {
        if (ep['title'] != null)
          val = ep['title'];
        else if (ep['name'] != null)
          val = ep['name'];
        else if (ep['itemType'] != null)
          val = ep['itemType'];
      } else {
        val = ep?.toString();
      }

      if (val is String && val.trim().isNotEmpty) {
        final s = val.trim();
        // avoid showing closure/stringified function values
        if (s.toLowerCase().contains('closure'))
          return AppLocalizations.of(ctx)!.episode;
        return s;
      }
      if (val != null) {
        final s = val.toString();
        if (!s.toLowerCase().contains('closure') && s.trim().isNotEmpty)
          return s;
      }
    } catch (_) {}
    return AppLocalizations.of(ctx)!.episode;
  }
  // bepaalt een representatieve titel voor een episode, valt terug naar 'episode'

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
      // toont type icon: tv voor series, film voor films
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: overview.isNotEmpty
          ? Text(overview, maxLines: 2, overflow: TextOverflow.ellipsis)
          : Text(AppLocalizations.of(context)!.open_details),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSeries)
                Chip(
                  label: Text(AppLocalizations.of(context)!.label_series),
                  visualDensity: VisualDensity.compact,
                ),
              if (showProgress) SizedBox(height: 6),
              if (showProgress)
                Chip(
                  label: Text(
                    AppLocalizations.of(context)!.seen_count(seenCount),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.bookmark_remove_outlined),
            tooltip: AppLocalizations.of(
              context,
            )!.remove_from_watchlist_tooltip,
            onPressed: () => _confirmAndRemove(id),
          ),
        ],
      ),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => MovieDetailScreen(imdbId: id))),
    );
  }
  // meta-listtile voor opgeslagen items met actieknoppen en navigatie

  // Bouw een ListTile met MovieRepository wanneer metadata niet beschikbaar is.
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
        String subtitle = AppLocalizations.of(ctx)!.open_details;
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
            // probeer een korte samenvatting te krijgen indien beschikbaar
            final overviewRaw = rapid?['overview'] ?? omdb?['Plot'];
            subtitle = _truncate(overviewRaw?.toString());
          } catch (_) {}
        }

        if (showProgress) {
          final val = seenMap[id];
          if (val is List) seenCount = val.length;
          // als er al een overzicht-subtitel is, voeg voortgang toe; anders vervang
          subtitle =
              subtitle.isNotEmpty &&
                  subtitle != AppLocalizations.of(ctx)!.open_details
              ? '${subtitle}\n${AppLocalizations.of(ctx)!.seen_count(seenCount)}'
              : (isSeries
                    ? AppLocalizations.of(ctx)!.seen_episodes_label(seenCount)
                    : AppLocalizations.of(ctx)!.open_details);
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
                  label: Text(AppLocalizations.of(ctx)!.seen_count(seenCount)),
                  visualDensity: VisualDensity.compact,
                ),
              // toon voortgangsaanduiding indien gewenst
              IconButton(
                icon: const Icon(Icons.bookmark_remove_outlined),
                tooltip: AppLocalizations.of(
                  ctx,
                )!.remove_from_watchlist_tooltip,
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
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.login_manage_watchlist_snack,
          ),
        ),
      );
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      await docRef.set({
        'watchlist': FieldValue.arrayRemove([imdbId]),
        'watchlist_meta.$imdbId': FieldValue.delete(),
        // verwijder ook eventuele seenEpisodes-vermeldingen voor dit id zodat het uit 'aan het kijken' verdwijnt
        'seenEpisodes.$imdbId': FieldValue.delete(),
      }, SetOptions(merge: true));
      // verwijder item uit watchlist en bijbehorende metadata uit Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.item_removed_watchlist),
        ),
      );
    } catch (e) {
      debugPrint('Failed to remove $imdbId from watchlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.remove_item_failed),
        ),
      );
    }
  }

  Future<void> _confirmAndRemove(String imdbId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.remove_from_watchlist_title),
        content: Text(AppLocalizations.of(ctx)!.remove_from_watchlist_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppLocalizations.of(ctx)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _removeFromWatchlist(imdbId);
    }
  }

  // bevestigingsdialoog voor verwijderen uit watchlist

  Future<void> _showAddSeriesDialog() async {
    final titleCtl = TextEditingController();
    final seasonsCtl = TextEditingController();
    final List<TextEditingController> episodeCtrls = [];
    // UI-state voor planning (selectie weekdagen + tot-datum)
    final Set<int> _selectedDays = <int>{};
    DateTime? _untilDate;
    bool _useDates = false;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (dctx, setState) {
              int seasonsCount = int.tryParse(seasonsCtl.text.trim()) ?? 0;
              if (seasonsCount < 0) seasonsCount = 0;
              while (episodeCtrls.length < seasonsCount) {
                episodeCtrls.add(TextEditingController());
              }
              while (episodeCtrls.length > seasonsCount) {
                episodeCtrls.removeLast();
              }

              // gebruiker heeft bevestigd; verzamel input en maak custom series aan
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(ctx)!.add_series_title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: titleCtl,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(ctx)!.title_label,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Toon seizoenen/afleveringen invoervelden alleen wanneer geen terugkerende datumplanning gebruikt wordt
                          if (!_useDates) ...[
                            TextField(
                              controller: seasonsCtl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(
                                  ctx,
                                )!.number_of_seasons,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 8),
                            // Optie om een weekdag-schema met een einddatum te gebruiken
                          ],
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              AppLocalizations.of(ctx)!.add_series_use_dates ??
                                  'Use recurring days',
                            ),
                            value: _useDates,
                            onChanged: (v) => setState(() => _useDates = v),
                          ),
                          if (_useDates) ...[
                            const SizedBox(height: 8),
                            // Weekday circles
                            Wrap(
                              spacing: 8,
                              children: List<Widget>.generate(7, (i) {
                                // Dutch short names: Ma, Di, Wo, Do, Vr, Za, Zo
                                const labels = [
                                  'Ma',
                                  'Di',
                                  'Wo',
                                  'Do',
                                  'Vr',
                                  'Za',
                                  'Zo',
                                ];
                                final selected = _selectedDays.contains(i);
                                return GestureDetector(
                                  onTap: () => setState(() {
                                    if (selected)
                                      _selectedDays.remove(i);
                                    else
                                      _selectedDays.add(i);
                                  }),
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: selected
                                        ? Theme.of(ctx).colorScheme.primary
                                        : Colors.grey.shade300,
                                    child: Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: selected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _untilDate == null
                                        ? AppLocalizations.of(
                                                ctx,
                                              )!.add_series_until_date ??
                                              'Until date'
                                        : '${AppLocalizations.of(ctx)!.until_label ?? 'Until'} ${_untilDate!.toLocal().toString().split(' ')[0]}',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final now = DateTime.now();
                                    final picked = await showDatePicker(
                                      context: dctx,
                                      initialDate: _untilDate ?? now,
                                      firstDate: now,
                                      lastDate: DateTime(now.year + 10),
                                    );
                                    if (picked != null)
                                      setState(() => _untilDate = picked);
                                  },
                                  child: Text(
                                    AppLocalizations.of(ctx)!.select ??
                                        'Select',
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (!_useDates && seasonsCount > 0)
                            ...List<Widget>.generate(seasonsCount, (si) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextField(
                                  controller: episodeCtrls[si],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: AppLocalizations.of(
                                      ctx,
                                    )!.episodes_in_season(si + 1),
                                  ),
                                ),
                              );
                            }),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text(AppLocalizations.of(ctx)!.cancel),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(AppLocalizations.of(ctx)!.save),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (confirmed != true) return;

    final title = titleCtl.text.trim();
    final seasonsCount = int.tryParse(seasonsCtl.text.trim()) ?? 0;

    if (title.isEmpty || (!_useDates && seasonsCount <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalid_series_input),
        ),
      );
      return;
    }

    final epCounts = <int>[];
    List<Map<String, dynamic>> seasons;

    if (_useDates) {
      // Bij gebruik van terugkerende dagen: genereer gedateerde afleveringen voor de geselecteerde weekdagen
      seasons = <Map<String, dynamic>>[];
      if (_selectedDays.isNotEmpty && _untilDate != null) {
        final start = DateTime.now();
        final end = DateTime(
          _untilDate!.year,
          _untilDate!.month,
          _untilDate!.day,
        );
        final Set<int> weekdays = _selectedDays
            .map((i) => i + 1)
            .toSet(); // DateTime.weekday: 1=Mon..7=Sun
        final episodes = <Map<String, dynamic>>[];
        DateTime cur = DateTime(start.year, start.month, start.day);
        while (!cur.isAfter(end)) {
          if (weekdays.contains(cur.weekday)) {
            final dd = cur.day.toString().padLeft(2, '0');
            final mm = cur.month.toString().padLeft(2, '0');
            final yy = cur.year.toString().substring(2);
            final formatted = '$dd-$mm-$yy';
            episodes.add({
              'title': '${AppLocalizations.of(context)!.episode} $formatted',
              'date': cur.toIso8601String(),
            });
          }
          cur = cur.add(const Duration(days: 1));
        }
        if (episodes.isNotEmpty) {
          seasons = [
            {
              'title': AppLocalizations.of(context)!.season_label(1),
              'episodes': episodes,
            },
          ];
        }
      }
    } else {
      for (var i = 0; i < seasonsCount; i++) {
        final v = (i < episodeCtrls.length) ? episodeCtrls[i].text.trim() : '';
        final n = int.tryParse(v);
        epCounts.add(n ?? 1);
      }

      seasons = List<Map<String, dynamic>>.generate(seasonsCount, (si) {
        final epiCount = epCounts[si];
        final episodes = List<Map<String, dynamic>>.generate(
          epiCount,
          (ei) => {
            'title': '${AppLocalizations.of(context)!.episode} ${ei + 1}',
          },
        );
        return {
          'title': AppLocalizations.of(context)!.season_label(si + 1),
          'episodes': episodes,
        };
      });
    }

    final id = 'local_${DateTime.now().millisecondsSinceEpoch}';
    // Bouw optionele schema-metadata als gebruiker datumplanning heeft ingeschakeld
    const _weekdayLabels = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
    Map<String, dynamic>? schedule;
    if (_useDates && _selectedDays.isNotEmpty) {
      final days = _selectedDays.toList()..sort();
      schedule = {
        'days': days.map((i) => _weekdayLabels[i]).toList(),
        'until': _untilDate?.toIso8601String(),
      };
    }

    await _createCustomSeries(id, title, seasons, schedule: schedule);
  }

  Future<void> _createCustomSeries(
    String id,
    String title,
    List<Map<String, dynamic>> seasons, {
    Map<String, dynamic>? schedule,
  }) async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.login_manage_watchlist_snack,
          ),
        ),
      );
      return;
    }
    final docRef = FirebaseFirestore.instance.collection('users').doc(u.uid);
    try {
      final meta = {'mediaType': 'series', 'title': title, 'seasons': seasons};
      if (schedule != null) meta['schedule'] = schedule;

      await docRef.set({
        'watchlist': FieldValue.arrayUnion([id]),
        'watchlist_meta.$id': meta,
      }, SetOptions(merge: true));
      // voeg custom series toe aan watchlist en sla metadata op

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.series_added)),
      );
    } catch (e) {
      debugPrint('Failed to add custom series $id: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.add_series_failed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              kToolbarHeight + kTextTabBarHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTopBar(
                  title: AppLocalizations.of(context)!.watchlist_label,
                  backgroundColor: Colors.transparent,
                ),
                Material(
                  key: _tabsKey,
                  color: Colors.transparent,
                  child: TabBar(
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.tab_saved),
                      Tab(text: AppLocalizations.of(context)!.tab_watching),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnap) {
              final user = authSnap.data;
              if (user == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: InkWell(
                      key: _loginButtonKey,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(returnAfterLogin: true),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blueAccent.withOpacity(0.05),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.watchlist_not_logged_in,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.watchlist_login_tap_message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // gebruiker is ingelogd; luister naar Firestore gebruikersdocument
              }

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (ctx, snap) {
                  if (snap.hasError) {
                    if (snap.error.toString().contains('permission-denied')) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Center(
                      child: Text(
                        AppLocalizations.of(
                          ctx,
                        )!.error_loading(snap.error ?? ''),
                      ),
                    );
                  }
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final data = snap.data!.data() ?? {};

                  final watchlist =
                      (data['watchlist'] as List?)
                          ?.map((e) => e.toString())
                          .toList() ??
                      <String>[];
                  // lees watchlist uit Firestore-data en converteer naar stringlijst
                  // seenEpisodes may be stored either as a map under 'seenEpisodes'
                  // or as individual fields named 'seenEpisodes.<imdbId>' (Firestore flattened keys).
                  final Map<String, dynamic> seenMap = {};
                  final seenMapRaw = data['seenEpisodes'];
                  if (seenMapRaw is Map) {
                    seenMapRaw.forEach((k, v) => seenMap[k.toString()] = v);
                  }
                  // voeg geflatteerde keys zoals 'seenEpisodes.tt1632701' samen
                  for (final k in data.keys) {
                    if (k.startsWith('seenEpisodes.')) {
                      final imdb = k.split('.').last;
                      seenMap[imdb] = data[k];
                    }
                  }

                  // merge eventuele flattened seenEpisodes velden in dezelfde map

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

                  // normaliseer watchlist metadata en merge flattened keys

                  bool seenIndicatesMovie(dynamic val) {
                    if (val is List) {
                      for (final e in val) {
                        if (e != null && e.toString().toLowerCase() == 'movie')
                          return true;
                      }
                    }
                    return false;
                  }

                  final savedSeries = watchlist.where((id) {
                    // Geef voorkeur aan expliciet 'mediaType' opgeslagen in 'watchlist_meta' wanneer beschikbaar
                    final meta = metaMap[id];
                    if (meta is Map && meta['mediaType'] != null) {
                      final mt = meta['mediaType'].toString().toLowerCase();
                      if (mt == 'series') return true;
                      if (mt == 'movie') return false;
                    }

                    final val = seenMap[id];
                    if (val is List) {
                      // als de opgeslagen seen-lijst expliciet 'movie' bevat, behandel als film
                      if (seenIndicatesMovie(val)) return false;
                      return true; // has seen entries (episodes) -> series
                    }
                    return false;
                  }).toList();

                  // Sorteer opgeslagen series op IMDb-id (bijv. tt1632701)
                  savedSeries.sort(
                    (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                  );

                  // sorteer series op imdb id voor consistente weergave

                  final savedFilms = watchlist.where((id) {
                    // Geef voorkeur aan expliciet 'mediaType' opgeslagen in 'watchlist_meta' wanneer beschikbaar
                    final meta = metaMap[id];
                    if (meta is Map && meta['mediaType'] != null) {
                      final mt = meta['mediaType'].toString().toLowerCase();
                      if (mt == 'movie') return true;
                      if (mt == 'series') return false;
                    }

                    final val = seenMap[id];
                    if (val is List) {
                      if (seenIndicatesMovie(val)) return true;
                      return false;
                    }
                    // geen 'seen' vermeldingen -> behandel standaard als film
                    return !seenMap.containsKey(id);
                  }).toList();

                  // Sorteer opgeslagen films alfabetisch op opgeslagen titel (val terug op id)
                  savedFilms.sort((a, b) {
                    final ta =
                        (metaMap[a] is Map && metaMap[a]!['title'] != null)
                        ? metaMap[a]!['title'].toString()
                        : a;
                    final tb =
                        (metaMap[b] is Map && metaMap[b]!['title'] != null)
                        ? metaMap[b]!['title'].toString()
                        : b;
                    return ta.toLowerCase().compareTo(tb.toLowerCase());
                  });

                  // sorteer films alfabetisch op opgeslagen titel (fallback naar id)

                  final watchingSeries = <String>[];
                  final watchingFilms = <String>[];

                  for (final e in seenMap.entries) {
                    final val = e.value;
                    if (val is List) {
                      // als de lijst expliciet de marker 'movie' bevat, behandel als film
                      final hasMovieMarker = val.any(
                        (x) =>
                            x != null && x.toString().toLowerCase() == 'movie',
                      );
                      if (hasMovieMarker) {
                        watchingFilms.add(e.key.toString());
                      } else if (val.isNotEmpty) {
                        // niet-lege lijst van episode-keys -> series
                        watchingSeries.add(e.key.toString());
                      }
                    }
                  }

                  // Neem ook expliciete series op uit de watchlist-metadata van de gebruiker
                  for (final id in watchlist) {
                    final m = metaMap[id];
                    if (m is Map &&
                        m['mediaType'] != null &&
                        m['mediaType'].toString().toLowerCase() == 'series') {
                      if (!watchingSeries.contains(id)) watchingSeries.add(id);
                    }
                  }

                  // Sorteer 'aan het kijken' series op IMDb-id (bijv. tt1632701)
                  watchingSeries.sort(
                    (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                  );
                  watchingFilms.sort((a, b) {
                    final ta =
                        (metaMap[a] is Map && metaMap[a]!['title'] != null)
                        ? metaMap[a]!['title'].toString()
                        : a;
                    final tb =
                        (metaMap[b] is Map && metaMap[b]!['title'] != null)
                        ? metaMap[b]!['title'].toString()
                        : b;
                    return ta.toLowerCase().compareTo(tb.toLowerCase());
                  });

                  Widget buildList(
                    List<String> items, {
                    bool showProgress = false,
                  }) {
                    if (items.isEmpty)
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(AppLocalizations.of(ctx)!.no_items),
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
                  // bouw een lijst (saved/watching) die metadata gebruikt wanneer beschikbaar

                  Widget buildWatchingSeries(List<String> ids) {
                    if (ids.isEmpty)
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(AppLocalizations.of(ctx)!.no_items),
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
                            // probeer seizoenen/episodes uit metadata te halen, indien beschikbaar. Geef voorkeur aan watchlist_meta boven API data omdat gebruikers mogelijk custom series hebben toegevoegd of episode titels hebben aangepast.
                            final seasonsRaw =
                                (meta is Map && meta['seasons'] != null)
                                ? meta['seasons']
                                : (rapid != null ? rapid['seasons'] : null);

                            if (seasonsRaw != null) {
                              final seasons = (seasonsRaw is List)
                                  ? List.from(seasonsRaw)
                                  : (seasonsRaw is Map
                                        ? (seasonsRaw as Map).values.toList()
                                        : []);

                              for (var si = 0; si < seasons.length; si++) {
                                final season = seasons[si] is Map
                                    ? seasons[si] as Map<String, dynamic>
                                    : {
                                        'title': seasons[si].toString(),
                                        'episodes': [],
                                      };
                                final seasonTitle =
                                    (season['title'] ??
                                            AppLocalizations.of(
                                              ctx,
                                            )!.season_label(si + 1))
                                        .toString();
                                final epRaw = season['episodes'];
                                final episodes = epRaw is List
                                    ? epRaw
                                    : (epRaw is Map
                                          ? (epRaw).values.toList()
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
                                        Chip(
                                          label: Text(
                                            AppLocalizations.of(
                                              ctx,
                                            )!.season_short(si + 1),
                                          ),
                                        ),
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
                                          AppLocalizations.of(ctx)!.seen_x_of_y(
                                            seenCount,
                                            episodes.length,
                                          ),
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
                                        final epTitle = _getEpisodeTitle(
                                          ep,
                                          ctx,
                                        );
                                        final epKey = 's${si}_e${ei}';

                                        // verzamel streamingopties voor aflevering (nl heeft voorkeur)
                                        final epStreamRaw =
                                            ep['streamingOptions']?['nl'] ??
                                            ep['streamingOptions'];
                                        final epStreams = epStreamRaw is List
                                            ? List.from(epStreamRaw)
                                            : (epStreamRaw is Map
                                                  ? (epStreamRaw).values
                                                        .toList()
                                                  : <dynamic>[]);

                                        // Sla loopvariabelen lokaal op om closure-problemen te voorkomen
                                        final localId = id;
                                        final localSi = si;
                                        final localEi = ei;
                                        final localEpKey =
                                            's${localSi}_e${localEi}';
                                        final localEpTitle = epTitle;
                                        final localIsSeen = seenSet.contains(
                                          localEpKey,
                                        );

                                        return ListTile(
                                          leading: Checkbox(
                                            value: localIsSeen,
                                            onChanged: (val) async {
                                              // togglet gezien-status en vraagt optioneel bevestiging
                                              final newVal = val ?? false;
                                              if (newVal) {
                                                // verzamel voorgaande niet-geziene afleveringen in dit seizoen
                                                final unseenPrev = <int>[];
                                                for (
                                                  var p = 0;
                                                  p < localEi;
                                                  p++
                                                ) {
                                                  final prevKey =
                                                      's${localSi}_e${p}';
                                                  if (!seenSet.contains(
                                                    prevKey,
                                                  ))
                                                    unseenPrev.add(p);
                                                }

                                                if (unseenPrev.isNotEmpty) {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (dctx) => AlertDialog(
                                                      title: Text(
                                                        AppLocalizations.of(
                                                          dctx,
                                                        )!.mark_previous_episodes_title,
                                                      ),
                                                      content: Text(
                                                        AppLocalizations.of(
                                                          dctx,
                                                        )!.mark_previous_episodes_message(
                                                          unseenPrev.length,
                                                          localSi + 1,
                                                          localEpTitle,
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dctx,
                                                              ).pop(false),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              dctx,
                                                            )!.no,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dctx,
                                                              ).pop(true),
                                                          child: Text(
                                                            AppLocalizations.of(
                                                              dctx,
                                                            )!.yes,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true) {
                                                    for (final p
                                                        in unseenPrev) {
                                                      await _toggleEpisodeSeenForUser(
                                                        localId,
                                                        's${localSi}_e${p}',
                                                        true,
                                                      );
                                                    }
                                                    await _toggleEpisodeSeenForUser(
                                                      localId,
                                                      localEpKey,
                                                      true,
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.episodes_marked_seen(
                                                            unseenPrev.length +
                                                                1,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }

                                                await _toggleEpisodeSeenForUser(
                                                  localId,
                                                  localEpKey,
                                                  true,
                                                );
                                              } else {
                                                await _toggleEpisodeSeenForUser(
                                                  localId,
                                                  localEpKey,
                                                  false,
                                                );
                                              }
                                            },
                                          ),
                                          title: Text(epTitle),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (epStreams.isNotEmpty)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.play_arrow,
                                                  ),
                                                  onPressed: () {
                                                    // verwijder duplicaten per service+type
                                                    final Map<
                                                      String,
                                                      Map<String, dynamic>
                                                    >
                                                    deduped = {};
                                                    for (var option
                                                        in epStreams) {
                                                      if (option is! Map)
                                                        continue;
                                                      final typedOption =
                                                          option
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;
                                                      final serviceName =
                                                          typedOption['service']?['name']
                                                              ?.toString() ??
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.unknown;
                                                      final type =
                                                          typedOption['type']
                                                              ?.toString() ??
                                                          'other';
                                                      final key =
                                                          '${serviceName.toLowerCase()}_$type';
                                                      deduped.putIfAbsent(
                                                        key,
                                                        () => typedOption,
                                                      );
                                                    }
                                                    final merged = deduped
                                                        .values
                                                        .toList();

                                                    showModalBottomSheet(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: merged.map<Widget>((
                                                            option,
                                                          ) {
                                                            final service =
                                                                option['service']?['name']
                                                                    ?.toString() ??
                                                                AppLocalizations.of(
                                                                  ctx,
                                                                )!.unknown;
                                                            final link =
                                                                option['link'] ??
                                                                option['service']?['homePage']
                                                                    ?.toString();
                                                            return ListTile(
                                                              leading:
                                                                  _buildServiceIconAsset(
                                                                    service,
                                                                    context:
                                                                        ctx,
                                                                    height: 28,
                                                                  ),
                                                              title: Text(
                                                                service,
                                                              ),
                                                              subtitle: Text(
                                                                _formatStreamingType(
                                                                  option,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.pop(
                                                                  ctx,
                                                                );
                                                                _openLink(
                                                                  link?.toString(),
                                                                );
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
                                  child: Text(
                                    AppLocalizations.of(ctx)!.title_wait(title),
                                  ),
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
                                  key: _contentKey,
                                  initiallyExpanded: true,
                                  title: Text(
                                    AppLocalizations.of(ctx)!.label_series,
                                  ),
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: buildList(savedSeries),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(AppLocalizations.of(ctx)!.films),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outline),
                                  tooltip: AppLocalizations.of(ctx)!.infoTooltip,
                                  onPressed: () {
                                    showDialog(
                                      context: ctx,
                                      builder: (context) => AlertDialog(
                                        title: Text(AppLocalizations.of(ctx)!.watchlistInfoTitle),
                                        content: Text(
                                          AppLocalizations.of(ctx)!.watchlistInfoContent,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(AppLocalizations.of(ctx)!.ok),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(8),
                              children: [
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  title: Text(
                                    AppLocalizations.of(ctx)!.label_series,
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal: 4.0,
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showAddSeriesDialog(),
                                        icon: const Icon(Icons.add),
                                        label: Text(
                                          AppLocalizations.of(
                                            ctx,
                                          )!.add_series_button,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 300,
                                      child: buildWatchingSeries(
                                        watchingSeries,
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text(AppLocalizations.of(ctx)!.films),
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      child: watchingFilms.isEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Text(
                                                AppLocalizations.of(
                                                  ctx,
                                                )!.no_progress_for_films,
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
                                                  future:
                                                      MovieRepository.getFullMovie(
                                                        id,
                                                      ),
                                                  builder: (ctx, snapMovie) {
                                                    String title = id;
                                                    // geef voorkeur aan opgeslagen metadata uit Firestore
                                                    final meta = metaMap[id];
                                                    if (meta is Map &&
                                                        meta['title'] != null) {
                                                      title =
                                                          meta['title']
                                                              ?.toString() ??
                                                          id;
                                                    } else if (snapMovie
                                                        .hasData) {
                                                      try {
                                                        final md =
                                                            snapMovie.data
                                                                as dynamic;
                                                        final rapid =
                                                            md.rapid
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >?;
                                                        final omdb =
                                                            md.omdb
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >?;
                                                        title =
                                                            (rapid != null &&
                                                                (rapid['title'] ??
                                                                        rapid['name']) !=
                                                                    null)
                                                            ? (rapid['title'] ??
                                                                      rapid['name'])
                                                                  .toString()
                                                            : (omdb != null &&
                                                                  omdb['Title'] !=
                                                                      null)
                                                            ? omdb['Title']
                                                                  .toString()
                                                            : id;
                                                      } catch (_) {}
                                                    }

                                                    final isSeen =
                                                        (seenForId is List)
                                                        ? seenForId
                                                              .map(
                                                                (e) => e
                                                                    .toString(),
                                                              )
                                                              .contains('movie')
                                                        : false;

                                                    return ListTile(
                                                      leading: const Icon(
                                                        Icons.movie,
                                                      ),
                                                      title: Text(title),
                                                      trailing: Checkbox(
                                                        value: isSeen,
                                                        onChanged: (val) async {
                                                          final newVal =
                                                              val ?? false;
                                                          await _toggleEpisodeSeenForUser(
                                                            id,
                                                            'movie',
                                                            newVal,
                                                          );
                                                        },
                                                      ),
                                                      onTap: () =>
                                                          Navigator.of(
                                                            context,
                                                          ).push(
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  MovieDetailScreen(
                                                                    imdbId: id,
                                                                  ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

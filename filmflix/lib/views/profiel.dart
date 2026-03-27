import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'loginscreen.dart';
import 'settingscreen.dart';
import 'package:cinetrackr/l10n/app_localizations.dart';

void main() => runApp(const MaterialApp(home: ProfileScreen()));

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  int _watchlistCount = 0;
  int _filmsCount = 0;
  int _adventureCount = 0;
  int _horrorCount = 0;
  int _earlyBirdCount = 0;
  int _bingeCount = 0;
  bool _hasAdventurerBadge = false;
  String? _displayName;
  bool _isLoggedIn = false;
  // Avatar customization (emoji + background color stored as hex string in Firestore)
  Color? _avatarColor;
  String? _avatarEmoji;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen();
  }

  // Show a dialog to edit the display name and save it to Firebase Auth and user doc
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _displayName ?? '');
    final parentContext = context;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.edit_profile),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Voer je naam in'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                final user = FirebaseAuth.instance.currentUser;
                final uid = user?.uid;
                try {
                  if (user != null) {
                    await user.updateDisplayName(newName);
                  }
                  if (uid != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .set({'displayName': newName}, SetOptions(merge: true));
                  }
                  if (mounted) {
                    setState(() {
                      _displayName = newName;
                    });
                  }
                } catch (e) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Opslaan mislukt')),
                  );
                }
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text(AppLocalizations.of(ctx)!.save),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initFirebaseAndListen() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
    } catch (e) {
      // ignore init errors here; app may already be initialized elsewhere
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userDocSub?.cancel();
      if (user != null) {
        _isLoggedIn = true;
        _displayName = user.displayName;
        _userDocSub = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snap) {
              final data = snap.data() ?? {};
              final watchlist = (data['watchlist'] is List)
                  ? List.from(data['watchlist'])
                  : <dynamic>[];

              // Count films from watchlist_meta and detect adventure-genre items.
              // Handle two shapes: 1) data['watchlist_meta'] is a Map with keys -> objects
              // 2) document fields named like 'watchlist_meta.<id>' (flattened)
              int films = 0;
              int adventures = 0;
              int horrors = 0;
              int earlyBirds = 0;
              final List<DateTime> allSaved = [];
              bool _metaHasAdventure(Map m) {
                try {
                  final genres = m['genres'] ?? m['genre'] ?? m['genre_names'];
                  if (genres is List) {
                    for (final g in genres) {
                      if (g is String) {
                        if (g.toLowerCase().contains('advent')) return true;
                      } else if (g is Map) {
                        final name = g['name'] ?? g['genre'];
                        if (name is String &&
                            name.toLowerCase().contains('advent'))
                          return true;
                      }
                    }
                  }
                } catch (_) {}
                return false;
              }

              bool _metaHasHorrorThriller(Map m) {
                try {
                  final genres = m['genres'] ?? m['genre'] ?? m['genre_names'];
                  if (genres is List) {
                    for (final g in genres) {
                      if (g is String) {
                        final lower = g.toLowerCase();
                        if (lower.contains('horror') ||
                            lower.contains('thriller'))
                          return true;
                      } else if (g is Map) {
                        final name = g['name'] ?? g['genre'];
                        if (name is String) {
                          final lower = name.toLowerCase();
                          if (lower.contains('horror') ||
                              lower.contains('thriller'))
                            return true;
                        }
                      }
                    }
                  }
                } catch (_) {}
                return false;
              }

              try {
                final wm = data['watchlist_meta'];
                if (wm is Map) {
                  for (final v in wm.values) {
                    if (v is Map) {
                      final mt = v['mediaType'];
                      if (mt != null && mt.toString().toLowerCase() == 'movie')
                        films += 1;
                      if (_metaHasAdventure(v)) adventures += 1;
                      if (_metaHasHorrorThriller(v)) horrors += 1;
                      // early bird check
                      try {
                        final saved = v['savedAt'];
                        DateTime? dt;
                        if (saved is Timestamp)
                          dt = saved.toDate();
                        else if (saved is DateTime)
                          dt = saved;
                        else if (saved is String)
                          dt = DateTime.tryParse(saved);
                        if (dt != null) {
                          final h = dt.toLocal().hour;
                          if (h >= 0 && h < 6) earlyBirds += 1;
                        }
                      } catch (_) {}
                      // collect saved timestamp for any media (movie or series)
                      try {
                        final saved = v['savedAt'];
                        DateTime? dt;
                        if (saved is Timestamp)
                          dt = saved.toDate();
                        else if (saved is DateTime)
                          dt = saved;
                        else if (saved is String)
                          dt = DateTime.tryParse(saved);
                        if (dt != null) allSaved.add(dt.toUtc());
                      } catch (_) {}
                    } else if (v is List) {
                      final hasMovie = v.any(
                        (e) =>
                            e is Map &&
                            e['mediaType'] != null &&
                            e['mediaType'].toString().toLowerCase() == 'movie',
                      );
                      if (hasMovie) films += 1;
                      final hasAdv = v.any(
                        (e) => e is Map && _metaHasAdventure(e),
                      );
                      if (hasAdv) adventures += 1;
                      final hasH = v.any(
                        (e) => e is Map && _metaHasHorrorThriller(e),
                      );
                      if (hasH) horrors += 1;
                      try {
                        for (final e in v) {
                          if (e is Map) {
                            final saved = e['savedAt'];
                            DateTime? dt;
                            if (saved is Timestamp)
                              dt = saved.toDate();
                            else if (saved is DateTime)
                              dt = saved;
                            else if (saved is String)
                              dt = DateTime.tryParse(saved);
                            if (dt != null) {
                              final h = dt.toLocal().hour;
                              if (h >= 0 && h < 6) {
                                earlyBirds += 1;
                                break;
                              }
                            }
                            final mt2 = e['mediaType'];
                            final mtStr2 = mt2?.toString().toLowerCase() ?? '';
                            // collect saved timestamp for any media type
                            if (dt != null) allSaved.add(dt.toUtc());
                          }
                        }
                      } catch (_) {}
                    }
                  }
                } else {
                  // fallback: look for keys that start with 'watchlist_meta'
                  for (final entry in data.entries) {
                    final k = entry.key as String;
                    final v = entry.value;
                    if (k.startsWith('watchlist_meta')) {
                      if (v is Map) {
                        final mt = v['mediaType'];
                        if (mt != null &&
                            mt.toString().toLowerCase() == 'movie')
                          films += 1;
                        if (_metaHasAdventure(v)) adventures += 1;
                        if (_metaHasHorrorThriller(v)) horrors += 1;
                        try {
                          final saved = v['savedAt'];
                          DateTime? dt;
                          if (saved is Timestamp)
                            dt = saved.toDate();
                          else if (saved is DateTime)
                            dt = saved;
                          else if (saved is String)
                            dt = DateTime.tryParse(saved);
                          if (dt != null) {
                            final h = dt.toLocal().hour;
                            if (h >= 0 && h < 6) earlyBirds += 1;
                          }
                        } catch (_) {}
                        // collect saved timestamp for any media (movie or series)
                        try {
                          final saved = v['savedAt'];
                          DateTime? dt;
                          if (saved is Timestamp)
                            dt = saved.toDate();
                          else if (saved is DateTime)
                            dt = saved;
                          else if (saved is String)
                            dt = DateTime.tryParse(saved);
                          if (dt != null) allSaved.add(dt.toUtc());
                        } catch (_) {}
                      } else if (v is List) {
                        final hasMovie = v.any(
                          (e) =>
                              e is Map &&
                              e['mediaType'] != null &&
                              e['mediaType'].toString().toLowerCase() ==
                                  'movie',
                        );
                        if (hasMovie) films += 1;
                        final hasAdv = v.any(
                          (e) => e is Map && _metaHasAdventure(e),
                        );
                        if (hasAdv) adventures += 1;
                        final hasH = v.any(
                          (e) => e is Map && _metaHasHorrorThriller(e),
                        );
                        if (hasH) horrors += 1;
                        try {
                          for (final e in v) {
                            if (e is Map) {
                              final saved = e['savedAt'];
                              DateTime? dt;
                              if (saved is Timestamp)
                                dt = saved.toDate();
                              else if (saved is DateTime)
                                dt = saved;
                              else if (saved is String)
                                dt = DateTime.tryParse(saved);
                              if (dt != null) {
                                final h = dt.toLocal().hour;
                                if (h >= 0 && h < 6) {
                                  earlyBirds += 1;
                                  break;
                                }
                              }
                              final mt2 = e['mediaType'];
                              final mtStr2 =
                                  mt2?.toString().toLowerCase() ?? '';
                              // collect saved timestamp for any media type
                              if (dt != null) allSaved.add(dt.toUtc());
                            }
                          }
                        } catch (_) {}
                      }
                    }
                  }
                }
              } catch (_) {}

              // compute binge events from collected saved timestamps (any media)
              int bingeEvents = 0;
              try {
                if (allSaved.isNotEmpty) {
                  allSaved.sort();
                  int i = 0;
                  final n = allSaved.length;
                  while (i < n) {
                    int j = i;
                    while (j + 1 < n &&
                        allSaved[j + 1].difference(allSaved[i]).inMinutes <=
                            10) {
                      j++;
                    }
                    if (j - i + 1 >= 2) {
                      bingeEvents += 1;
                      i = j + 1;
                    } else {
                      i += 1;
                    }
                  }
                }
              } catch (_) {}

              setState(() {
                _watchlistCount = watchlist.length;
                _filmsCount = films;
                _adventureCount = adventures;
                _horrorCount = horrors;
                _earlyBirdCount = earlyBirds;
                _bingeCount = bingeEvents;
                _hasAdventurerBadge = adventures > 10;
                _displayName = (data['displayName'] as String?) ?? _displayName;
                // load avatar customization if present
                try {
                  final avatar = data['profileAvatar'] ?? data['avatar'];
                  if (avatar is Map) {
                    final emoji = avatar['emoji'] as String?;
                    final colorStr = avatar['color'] as String?;
                    _avatarEmoji = emoji;
                    if (colorStr is String && colorStr.isNotEmpty) {
                      final cleaned = colorStr.replaceAll('#', '');
                      final val = int.tryParse(cleaned, radix: 16);
                      if (val != null) _avatarColor = Color(0xFF000000 | val);
                    }
                  }
                } catch (_) {}
              });
            });
      } else {
        setState(() {
          _isLoggedIn = false;
          _watchlistCount = 0;
          _filmsCount = 0;
          _displayName = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121B22)
        : const Color(0xFFF5F7F8);
    final cardColor = isDark
        ? const Color(0xFF1D272F)
        : const Color(0xFFFFFFFF);
    final accentColor = isDark
        ? const Color(0xFFEBB143)
        : const Color(0xFFD4AF37);
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondaryText = isDark ? Colors.white70 : Colors.black54;
    final iconColor = isDark ? Colors.white70 : Colors.black45;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header met Avatar en Level Progress
          SliverAppBar(
            expandedHeight: 280,
            backgroundColor: backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [cardColor, backgroundColor],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.avatar_login_prompt,
                                  ),
                                ),
                              );
                              return;
                            }
                            _showAvatarEditor();
                          },
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: accentColor.withOpacity(0.3),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  _avatarColor ?? Colors.grey.shade200,
                              child:
                                  _avatarEmoji != null &&
                                      _avatarEmoji!.isNotEmpty
                                  ? Text(
                                      _avatarEmoji!,
                                      style: const TextStyle(fontSize: 32),
                                    )
                                  : (_displayName != null &&
                                        _displayName!.isNotEmpty)
                                  ? Text(
                                      _displayName!
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white54,
                                  ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!_isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context)!.avatar_login_prompt,
                                  ),
                                ),
                              );
                              return;
                            }
                            _showAvatarEditor();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (!_isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context)!.avatar_login_prompt,
                              ),
                            ),
                          );
                          return;
                        }
                        _showEditNameDialog();
                      },
                      child: Text(
                        _displayName ?? AppLocalizations.of(context)!.profile_default_name,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildQuickStat(
                        context,
                        _isLoggedIn ? _filmsCount.toString() : '-',
                        AppLocalizations.of(context)!.films,
                        accentColor,
                      ),
                      _buildQuickStat(
                        context,
                        _isLoggedIn ? _watchlistCount.toString() : '-',
                        AppLocalizations.of(context)!.watchlist_label,
                        Colors.blueAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // BADGES SECTIE (Vervangt Favorieten tekst)
                  Text(
                    AppLocalizations.of(context)!.your_badges,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // Avonturier always zichtbaar; show numeric progress and level
                        _buildBadge(
                          context,
                          AppLocalizations.of(context)!.badge_adventurer,
                          Icons.explore,
                          Colors.greenAccent,
                          count: _adventureCount,
                          levelBase: 10,
                        ),
                        _buildBadge(
                          context,
                          AppLocalizations.of(context)!.badge_horror_king,
                          Icons.auto_awesome,
                          Colors.purpleAccent,
                          count: _horrorCount,
                          levelBase: 10,
                        ),
                        _buildBadge(
                          context,
                          AppLocalizations.of(context)!.badge_binge_watcher,
                          Icons.bolt,
                          Colors.orangeAccent,
                          count: _bingeCount,
                          levelBase: 10,
                        ),
                        _buildBadge(
                          context,
                          AppLocalizations.of(context)!.badge_early_bird,
                          Icons.wb_sunny,
                          Colors.yellowAccent,
                          count: _earlyBirdCount,
                          levelBase: 10,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)!.account_section,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Edit profile tile removed; name is editable by tapping the display name.
                  _buildMenuTile(
                    context,
                    Icons.settings_outlined,
                    AppLocalizations.of(context)!.settingsTitle,
                    cardColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  // Show 'Uitloggen' when logged in, otherwise show 'Inloggen'
                  if (_isLoggedIn)
                    _buildMenuTile(
                      context,
                      Icons.logout,
                      AppLocalizations.of(context)!.logout,
                      cardColor,
                      isDestructive: true,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    )
                  else
                    _buildMenuTile(
                      context,
                      Icons.login,
                      AppLocalizations.of(context)!.loginIn,
                      cardColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.appVersion,
                      style: TextStyle(
                        color: primaryText.withOpacity(0.1),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show bottom sheet for avatar customization (emoji + color). Saves choice to Firestore.
  void _showAvatarEditor() {
    bool _isOnlyEmoji(String s) {
      if (s.isEmpty) return false;
      final re = RegExp(
        r'^[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{FE0F}\u{200D}]+$',
        unicode: true,
      );
      try {
        return re.hasMatch(s);
      } catch (_) {
        return false;
      }
    }

    final presetColors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.brown,
      Colors.grey,
    ];
    final emojis = [
      '😀',
      '😎',
      '🤓',
      '🥳',
      '🤠',
      '😇',
      '🧐',
      '🙂',

      '🎬',
      '🍿',
      '🎥',
      '📽️',
      '🎞️',
      '⭐️',
      '🎭',
      '🎟️',

      '😂',
      '😍',
      '😅',
      '😭',
      '🤩',
      '🤯',
      '😴',
      '🤢',
      '🤕',
      '🤡',

      '✨',
      '💫',
      '🔥',
      '🌟',
      '🎉',
      '🎊',
      '🎵',
      '🎶',
    ];
    Color selectedColor = _avatarColor ?? Colors.grey.shade300;
    String? selectedEmoji = _avatarEmoji;
    final TextEditingController emojiController = TextEditingController(
      text: selectedEmoji,
    );

    final parentContext = context;
    final rootMessenger = ScaffoldMessenger.of(parentContext);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.edit_avatar_title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.choose_color,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedColor = Colors.grey.shade200;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border:
                                      selectedColor.value ==
                                          Colors.grey.shade200.value
                                      ? Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        )
                                      : Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ...presetColors.map((c) {
                              final isSelected = c.value == selectedColor.value;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedColor = c;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.choose_emoji_optional,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        // custom emoji input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: emojiController,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.emoji_input_hint,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                onChanged: (v) {
                                  // update preview inline but don't validate yet
                                  setModalState(() {
                                    selectedEmoji = v.trim().isEmpty
                                        ? null
                                        : v.trim();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final input = emojiController.text.trim();
                                if (input.isEmpty) {
                                  setModalState(() {
                                    selectedEmoji = null;
                                    emojiController.text = '';
                                  });
                                  return;
                                }
                                if (!_isOnlyEmoji(input)) {
                                  showDialog<void>(
                                    context: parentContext,
                                    builder: (dctx) => AlertDialog(
                                      title: Text(AppLocalizations.of(parentContext)!.invalid_input),
                                      content: Text(AppLocalizations.of(parentContext)!.only_emoji_error),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dctx).pop(),
                                          child: Text(AppLocalizations.of(parentContext)!.ok),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                setModalState(() {
                                  selectedEmoji = input;
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.use),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedEmoji = null;
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selectedEmoji == null
                                      ? Colors.black12
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            ...emojis.map((e) {
                              final isSelected = e == selectedEmoji;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedEmoji = e;
                                    emojiController.text = e;
                                  });
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black12
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    e,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(AppLocalizations.of(ctx)!.cancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () async {
                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid == null) return;
                                final input = emojiController.text.trim();
                                if (input.isNotEmpty && !_isOnlyEmoji(input)) {
                                  showDialog<void>(
                                    context: parentContext,
                                    builder: (dctx) => AlertDialog(
                                      title: Text(AppLocalizations.of(parentContext)!.invalid_input),
                                      content: Text(AppLocalizations.of(parentContext)!.only_emoji_error),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dctx).pop(),
                                          child: Text(AppLocalizations.of(parentContext)!.ok),
                                        ),
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                final colorHex =
                                    '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                                final docRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid);
                                await docRef.set({
                                  'profileAvatar': {
                                    'emoji': input.isEmpty
                                        ? (selectedEmoji ?? '')
                                        : input,
                                    'color': colorHex,
                                  },
                                }, SetOptions(merge: true));
                                setState(() {
                                  _avatarColor = selectedColor;
                                  _avatarEmoji = input.isEmpty
                                      ? selectedEmoji
                                      : input;
                                });
                                Navigator.of(ctx).pop();
                              },
                              child: Text(AppLocalizations.of(ctx)!.save),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Kleine stat-indicator bovenaan
  Widget _buildQuickStat(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondary = isDark ? Colors.white38 : Colors.black45;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: secondary, fontSize: 12)),
        ],
      ),
    );
  }

  // Badge Widget
  Widget _buildBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color, {
    double? progress,
    int? count,
    int levelBase = 10,
    bool simpleCount = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1D272F) : const Color(0xFFF2F4F6);
    final primaryText = isDark ? Colors.white : Colors.black87;
    // If count is provided, compute level and progress fraction based on levelBase
    int displayLevel = 1;
    int displayTotal = levelBase;
    double fraction = progress ?? 0.0;
    String counterText = '';
    if (count != null) {
      if (simpleCount) {
        counterText = '$count';
      } else {
        displayLevel = (count ~/ levelBase) + 1;
        displayTotal = displayLevel * levelBase;
        final currentLevelProgress = count - (displayLevel - 1) * levelBase;
        fraction = (currentLevelProgress / levelBase).clamp(0.0, 1.0);
        counterText = '$count/$displayTotal';
      }
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          if (count != null) ...[
            if (simpleCount) ...[
              Text(
                counterText,
                style: TextStyle(
                  color: primaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
            ] else ...[
              SizedBox(
                height: 8,
                width: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    counterText,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (displayLevel > 1) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${AppLocalizations.of(context)!.badge_level_prefix}$displayLevel',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
            ],
          ] else if (progress != null) ...[
            SizedBox(
              height: 8,
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (progress.clamp(0.0, 1.0)),
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryText,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Menu Items
  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    Color color, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final iconColor = isDestructive
        ? Colors.redAccent
        : (isDark ? Colors.white70 : Colors.black45);
    final trailingColor = isDestructive
        ? Colors.redAccent.withOpacity(0.3)
        : (isDark ? Colors.white10 : Colors.black12);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : primaryText,
            fontSize: 15,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
      ),
    );
  }
}

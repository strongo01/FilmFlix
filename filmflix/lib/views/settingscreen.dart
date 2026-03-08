import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
// VERGEET DEZE IMPORT NIET:
import 'package:cinetrackr/views/customer_service.dart';
import 'package:cinetrackr/main.dart';
import 'package:cinetrackr/views/loginscreen.dart';
import 'package:cinetrackr/utils/notification_permissions.dart';
import 'package:cinetrackr/utils/fcm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color movieBlue = const Color.fromRGBO(43, 77, 91, 1);
  final Color goldAccent = const Color(0xFFD4AF37);
  bool _notificationsEnabled = true;
  StreamSubscription<User?>? _authSub;
  User? _currentUser;
  String? _displayName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _displayName = _currentUser?.displayName;
    _email = _currentUser?.email;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _displayName = user?.displayName;
        _email = user?.email;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1C1E);
    final cardColor = isDark ? const Color(0xFF1C282E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F171B)
          : const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text(
          'Instellingen',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: movieBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionLabel('Mijn Dashboard'),
          _buildAccountCard(cardColor, textColor),

          const SizedBox(height: 24),

          _buildSectionLabel('Voorkeuren'),
          _buildProfessionalCard(
            cardColor,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: Icon(Icons.notifications_none, color: movieBlue),
                  title: const Text('Meldingen'),
                  value: _notificationsEnabled,
                  activeColor: goldAccent,
                  onChanged: (val) async {
                    if (val == true) {
                      final granted = await requestNotificationPermission();
                      if (!mounted) return;
                      if (granted) {
                        await registerFcmTokenForUser(FirebaseAuth.instance.currentUser);
                        if (!mounted) return;
                        setState(() => _notificationsEnabled = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Meldingen ingeschakeld')),
                        );
                      } else {
                        setState(() => _notificationsEnabled = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Machtiging voor meldingen geweigerd')),
                        );
                      }
                    } else {
                      // User turned off notifications locally — unregister token
                      await unregisterFcmTokenForUser(FirebaseAuth.instance.currentUser);
                      if (!mounted) return;
                      setState(() => _notificationsEnabled = false);
                    }
                  },
                ),
                _buildDivider(isDark),
                // Hier geven we een lege functie mee voor nu
                _buildSimpleTile(
                  Icons.language,
                  'Taal',
                  'Nederlands',
                  textColor,
                  () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionLabel('Support'),
          _buildProfessionalCard(
            cardColor,
            child: Column(
              children: [
                // HIER GEBEURT DE NAVIGATIE:
                _buildSimpleTile(
                  Icons.help_outline,
                  'Klantenservice',
                  '',
                  textColor,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomerServiceScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(isDark),
                _buildSimpleTile(
                  Icons.info_outline,
                  'Over CineTrackr',
                  '',
                  textColor,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AboutCineTrackrScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(isDark),
                _buildSimpleTile(
                  Icons.lock_outline,
                  'Privacybeleid',
                  '',
                  textColor,
                  () {
                    _openPrivacyPolicy();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Center(
            child: _currentUser != null
                ? TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                      );
                    },
                    child: const Text(
                      'UITLOGGEN',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'INLOGGEN',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 10),
          Center(
            child: Text(
              'v1.0.4',
              style: TextStyle(color: textColor.withOpacity(0.3), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Widget _buildAccountCard(Color cardColor, Color textColor) {
    return _buildProfessionalCard(
      cardColor,
      child: InkWell(
        onTap: () async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Je moet ingelogd zijn om je naam te wijzigen')),
            );
            return;
          }

          final formKey = GlobalKey<FormState>();
          final ctrl = TextEditingController(text: _displayName ?? '');
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Wijzig je naam'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Je naam'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Vul je naam in';
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuleer')),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Opslaan'),
                ),
              ],
            ),
          );

          if (result != true) return;
          final newName = ctrl.text.trim();
          try {
            await user.updateDisplayName(newName);
            await user.reload();
            final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
            await usersRef.set({
              'displayName': newName,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            if (!mounted) return;
            setState(() {
              _displayName = newName;
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Naam bijgewerkt')));
          } catch (e) {
            debugPrint('Failed to update displayName: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bijwerken mislukt')));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: movieBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName ?? 'Kevin le Goat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          _email ?? 'kevinlegoat@example.com',
                          style: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              // Dynamic counts from Firestore
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('—', 'Films af', textColor),
                        _buildStatItem('—', 'Watchlist', textColor),
                      ],
                    );
                  }

                  final data = snap.data!.data() ?? {};

                  final watchlist = (data['watchlist'] is List)
                      ? List<String>.from(data['watchlist'])
                      : <String>[];

                  // Build seenMap merging possible flattened keys
                  final Map<String, dynamic> seenMap = {};
                  final seenRaw = data['seenEpisodes'];
                  if (seenRaw is Map)
                    seenRaw.forEach((k, v) => seenMap[k.toString()] = v);
                  for (final k in data.keys) {
                    if (k.startsWith('seenEpisodes.')) {
                      final imdb = k.split('.').last;
                      seenMap[imdb] = data[k];
                    }
                  }

                  bool seenIndicatesMovie(dynamic val) {
                    if (val is List) {
                      for (final e in val) {
                        if (e != null && e.toString().toLowerCase() == 'movie')
                          return true;
                      }
                    }
                    return false;
                  }

                  // Count only items explicitly marked as 'movie' in seenEpisodes.
                  // This means we do NOT treat a watchlist item without a 'movie'
                  // marker as a counted 'film' here — that matches expected output.
                  final watchingFilms = <String>[];
                  for (final e in seenMap.entries) {
                    final val = e.value;
                    if (val is List) {
                      final hasMovieMarker = val.any(
                        (x) =>
                            x != null && x.toString().toLowerCase() == 'movie',
                      );
                      if (hasMovieMarker) watchingFilms.add(e.key.toString());
                    }
                  }

                  // If a watchlist entry also has an explicit 'movie' marker, include it.
                  final savedFilmsMarkedMovie = watchlist.where((id) {
                    final val = seenMap[id];
                    return val is List && seenIndicatesMovie(val);
                  }).toList();

                  final filmIds = {...savedFilmsMarkedMovie, ...watchingFilms};

                  // Debug prints to help inspect what counts are computed
                  debugPrint('SettingsScreen: watchlist=${watchlist}');
                  debugPrint(
                    'SettingsScreen: seenMap_keys=${seenMap.keys.toList()}',
                  );
                  debugPrint(
                    'SettingsScreen: savedFilmsMarkedMovie=${savedFilmsMarkedMovie}',
                  );
                  debugPrint('SettingsScreen: watchingFilms=${watchingFilms}');
                  debugPrint('SettingsScreen: filmIds=${filmIds}');

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        filmIds.length.toString(),
                        'Films af',
                        textColor,
                      ),
                      _buildStatItem(
                        watchlist.length.toString(),
                        'Watchlist',
                        textColor,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: movieBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildProfessionalCard(Color color, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  // Aangepaste helper met onTap parameter:
  Widget _buildSimpleTile(
    IconData icon,
    String title,
    String trailing,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: movieBlue.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
      onTap: onTap, // Nu voert hij de navigatie uit
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://sites.google.com/view/cinetrackr/homepage');
    try {
      // Try to open in an in-app webview (if supported)
      if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
        // Fallback to external browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch privacy policy url: $e');
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 55,
      endIndent: 10,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }
}

const String _kAboutText = '''
CineTrackr

Welkom bij CineTrackr, jouw persoonlijke gids voor films en bioscoopbezoek.

Met CineTrackr kun je eenvoudig filmprogramma's bekijken, je eigen watchlist bijhouden en snel toegang krijgen tot bioscooplocaties en klantenservice.

Bedankt voor het gebruiken van CineTrackr — veel kijkplezier!
''';

class AboutCineTrackrScreen extends StatelessWidget {
  const AboutCineTrackrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Over CineTrackr',
          style: TextStyle(color: Colors.white),
        ),

        backgroundColor: const Color.fromRGBO(43, 77, 91, 1),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Text(
            _kAboutText,
            style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
          ),
        ),
      ),
    );
  }
}

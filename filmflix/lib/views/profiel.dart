import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'loginscreen.dart';
import 'settingscreen.dart';

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
  String? _displayName;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen();
  }

  Future<void> _initFirebaseAndListen() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
    } catch (e) {
      // ignore init errors here; app may already be initialized elsewhere
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _userDocSub?.cancel();
      if (user != null) {
        _isLoggedIn = true;
        _displayName = user.displayName;
        _userDocSub = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().listen((snap) {
          final data = snap.data() ?? {};
          final watchlist = (data['watchlist'] is List) ? List.from(data['watchlist']) : <dynamic>[];

          // Count films from watchlist_meta. Handle two shapes:
          // 1) data['watchlist_meta'] is a Map with keys -> movie objects
          // 2) fields in the document are named like 'watchlist_meta.<id>' (flattened)
          int films = 0;
          try {
            final wm = data['watchlist_meta'];
            if (wm is Map) {
              for (final v in wm.values) {
                if (v is Map) {
                  final mt = v['mediaType'];
                  if (mt != null && mt.toString().toLowerCase() == 'movie') films += 1;
                } else if (v is List) {
                  final hasMovie = v.any((e) => e is Map && e['mediaType'] != null && e['mediaType'].toString().toLowerCase() == 'movie');
                  if (hasMovie) films += 1;
                }
              }
            } else {
              // fallback: look for keys that start with 'watchlist_meta.'
              for (final entry in data.entries) {
                final k = entry.key as String;
                final v = entry.value;
                if (k.startsWith('watchlist_meta')) {
                  if (v is Map) {
                    final mt = v['mediaType'];
                    if (mt != null && mt.toString().toLowerCase() == 'movie') films += 1;
                  } else if (v is List) {
                    final hasMovie = v.any((e) => e is Map && e['mediaType'] != null && e['mediaType'].toString().toLowerCase() == 'movie');
                    if (hasMovie) films += 1;
                  }
                }
              }
            }
          } catch (_) {}

          setState(() {
            _watchlistCount = watchlist.length;
            _filmsCount = films;
            _displayName = (data['displayName'] as String?) ?? _displayName;
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
    final backgroundColor = isDark ? const Color(0xFF121B22) : const Color(0xFFF5F7F8);
    final cardColor = isDark ? const Color(0xFF1D272F) : const Color(0xFFFFFFFF);
    final accentColor = isDark ? const Color(0xFFEBB143) : const Color(0xFFD4AF37);
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
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: accentColor.withOpacity(0.3),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=kevin'),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                          child: const Icon(Icons.star, size: 20, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _displayName ?? 'Kevin le Goat',
                      style: TextStyle(color: primaryText, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Film Fanaat • Level 4',
                      style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w500),
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
                  // Statistieken in één oogopslag (Films + Watchlist)
                  Row(
                    children: [
                      _buildQuickStat(context, _isLoggedIn ? _filmsCount.toString() : '-', 'Films', accentColor),
                      _buildQuickStat(context, _isLoggedIn ? _watchlistCount.toString() : '-', 'Watchlist', Colors.blueAccent),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // BADGES SECTIE (Vervangt Favorieten tekst)
                  Text(
                    'JOUW BADGES',
                    style: TextStyle(color: secondaryText, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildBadge(context, 'Horror King', Icons.auto_awesome, Colors.purpleAccent),
                        _buildBadge(context, 'Binge Watcher', Icons.bolt, Colors.orangeAccent),
                        _buildBadge(context, 'Early Bird', Icons.wb_sunny, Colors.yellowAccent),
                        _buildBadge(context, 'Critic', Icons.rate_review, Colors.cyanAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    'ACCOUNT',
                    style: TextStyle(color: secondaryText, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(context, Icons.person_outline, 'Profiel bewerken', cardColor, onTap: () {}),
                  _buildMenuTile(context, Icons.settings_outlined, 'Instellingen', cardColor, onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  }),
                  // Show 'Uitloggen' when logged in, otherwise show 'Inloggen'
                  if (_isLoggedIn)
                    _buildMenuTile(context, Icons.logout, 'Uitloggen', cardColor, isDestructive: true, onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                    })
                  else
                    _buildMenuTile(context, Icons.login, 'Inloggen', cardColor, onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }),
                  
                  const SizedBox(height: 30),
                  Center(
                    child: Text('CineTrackr v1.0.4', style: TextStyle(color: primaryText.withOpacity(0.1), fontSize: 12)),
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

  // Kleine stat-indicator bovenaan
  Widget _buildQuickStat(BuildContext context, String value, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final secondary = isDark ? Colors.white38 : Colors.black45;
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(height: 3, width: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: secondary, fontSize: 12)),
        ],
      ),
    );
  }

  // Badge Widget
  Widget _buildBadge(BuildContext context, String label, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1D272F) : const Color(0xFFF2F4F6);
    final primaryText = isDark ? Colors.white : Colors.black87;
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
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
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: primaryText, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Menu Items
  Widget _buildMenuTile(BuildContext context, IconData icon, String title, Color color, {bool isDestructive = false, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? Colors.white : Colors.black87;
    final iconColor = isDestructive ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black45);
    final trailingColor = isDestructive ? Colors.redAccent.withOpacity(0.3) : (isDark ? Colors.white10 : Colors.black12);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.redAccent : primaryText, fontSize: 15)),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
      ),
    );
  }
}
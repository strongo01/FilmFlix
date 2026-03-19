import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cinetrackr/views/customer_service.dart';
import 'package:cinetrackr/main.dart';
import 'package:cinetrackr/views/loginscreen.dart';
import 'package:cinetrackr/utils/notification_permissions.dart';
import 'package:cinetrackr/utils/fcm_service.dart';
import 'package:cinetrackr/l10n/l10n.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int _cachedUnreadCustomerReplies = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _customerQuestionsSub;
  String _languageCode = 'nl';

  @override
  void initState() {
    super.initState();
    // Default to device locale unless a saved preference exists
    try {
      final deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      _languageCode = deviceLang;
    } catch (_) {
      _languageCode = 'nl';
    }
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

      if (user != null) {
        _subscribeCustomerQuestions(user.uid);
        _fetchUnreadCustomerReplies().then((v) {
          if (mounted) setState(() => _cachedUnreadCustomerReplies = v);
        });
        
        // Initialiseer _notificationsEnabled op basis van of we een token hebben in firestore
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (mounted && doc.exists) {
            final data = doc.data() ?? {};
            setState(() {
              _notificationsEnabled = data.containsKey('fcmToken') && (data['fcmToken']?.toString().isNotEmpty ?? false);
            });
          }
        });
      } else {
        _customerQuestionsSub?.cancel();
        _customerQuestionsSub = null;
        if (mounted) setState(() => _cachedUnreadCustomerReplies = 0);
      }
    });

    // Load saved language preference for display
    SharedPreferences.getInstance().then((prefs) {
      final lc = prefs.getString('app_locale') ?? _languageCode;
      if (mounted) setState(() => _languageCode = lc);
    }).catchError((e) {
      debugPrint('Failed to load saved language: $e');
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _customerQuestionsSub?.cancel();
    super.dispose();
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
        title: Text(
          L10n.of(context)?.settingsTitle ?? 'Instellingen',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: movieBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionLabel(L10n.of(context)?.myDashboard ?? 'Mijn Dashboard'),
          _buildAccountCard(cardColor, textColor),

          const SizedBox(height: 24),

          _buildSectionLabel(L10n.of(context)?.preferences ?? 'Voorkeuren'),
          _buildProfessionalCard(
            cardColor,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: Icon(Icons.notifications_none, color: movieBlue),
                  title: Text(L10n.of(context)?.notifications ?? 'Meldingen'),
                  value: _notificationsEnabled,
                  activeColor: goldAccent,
                  onChanged: (val) async {
                    if (val == true) {
                      // Probeer (opnieuw) permissies te vragen. Als het vastzit, opent dit de OS instellingen.
                      final granted = await requestNotificationPermission();
                      if (!mounted) return;

                      // We forceren alsnog het registreren van de fcmToken in de database ongeacht OS block!
                      // Waarom? Als de gebruiker het in de instellingen zometeen aanzet, hebben we het token al nodig.
                      final ok = await registerFcmTokenForUser(FirebaseAuth.instance.currentUser);
                      
                      if (!mounted) return;
                      // Update toggle UI
                      setState(() => _notificationsEnabled = true);

                      if (granted && ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(L10n.of(context)?.notifications_enabled ?? 'Meldingen ingeschakeld')),
                        );
                      } else if (!granted) {
                        // OS had permissie geblokkeerd of we zitten in Android Settings. Het token gokken we succesvol geupload.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(L10n.of(context)?.notifications_check_system ?? 'Controleer de Systeem Instellingen om meldingen toe te laten.'),
                              duration: const Duration(seconds: 4),
                          ),
                        );
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(L10n.of(context)?.notifications_registration_failed ?? 'Aanmelden voor notificaties mislukt.')),
                        );
                         setState(() => _notificationsEnabled = false);
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
                _buildSimpleTile(
                  Icons.language,
                  L10n.of(context)?.language ?? 'Taal',
                  // Show the currently selected language label
                  _languageLabel(_languageCode, context),
                  textColor,
                  () async {
                    final prefs = await SharedPreferences.getInstance();
                    final current = prefs.getString('app_locale') ?? _languageCode;

                    final langOptions = [
                      {'code': 'nl', 'label': L10n.of(context)?.dutch ?? 'Nederlands'},
                      {'code': 'en', 'label': L10n.of(context)?.english ?? 'English'},
                      {'code': 'fr', 'label': L10n.of(context)?.french ?? 'Français'},
                      {'code': 'de', 'label': L10n.of(context)?.german ?? 'Deutsch'},
                      {'code': 'es', 'label': L10n.of(context)?.spanish ?? 'Español'},
                      {'code': 'tr', 'label': L10n.of(context)?.turkish ?? 'Türkçe'},
                    ];

                    final choice = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: cardColor,
                        title: Text(L10n.of(context)?.language ?? 'Taal', style: TextStyle(color: textColor)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: langOptions.map((opt) {
                            return RadioListTile<String>(
                              value: opt['code']!,
                              groupValue: current,
                              title: Text(opt['label']!, style: TextStyle(color: textColor)),
                              onChanged: (v) => Navigator.of(ctx).pop(v),
                            );
                          }).toList(),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(L10n.of(context)?.close ?? 'Close', style: TextStyle(color: textColor)))
                        ],
                      ),
                    );

                    if (choice != null) {
                      await prefs.setString('app_locale', choice);
                      if (!mounted) return;
                      setState(() => _languageCode = choice);
                      // Update global notifier so the app updates immediately
                      localeNotifier.value = Locale(choice);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionLabel(L10n.of(context)?.support ?? 'Support'),
          _buildProfessionalCard(
            cardColor,
            child: Column(
              children: [
                // HIER GEBEURT DE NAVIGATIE:
                ListTile(
                  leading: Icon(Icons.help_outline, color: movieBlue.withOpacity(0.7)),
                  title: Text(
                    L10n.of(context)?.customerService_title ?? 'Klantenservice',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_cachedUnreadCustomerReplies > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              _cachedUnreadCustomerReplies > 99
                                  ? '99+'
                                  : '$_cachedUnreadCustomerReplies',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
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
                  L10n.of(context)?.aboutTitle ?? 'Over CineTrackr',
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
                  L10n.of(context)?.privacyPolicy ?? 'Privacybeleid',
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
                    child: Text(
                      (L10n.of(context)?.logout ?? 'Uitloggen').toUpperCase(),
                      style: const TextStyle(
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
                    child: Text(
                      (L10n.of(context)?.loginIn ?? 'Inloggen').toUpperCase(),
                      style: const TextStyle(
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
              style: TextStyle(color: textColor.withValues(alpha: 0.3), fontSize: 12),
            ),
          ),
        ],
      ),
    );
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
              SnackBar(content: Text(L10n.of(context)?.mustBeLoggedIn ?? 'Je moet ingelogd zijn om je naam te wijzigen')),
            );
            return;
          }

          final formKey = GlobalKey<FormState>();
          final ctrl = TextEditingController(text: _displayName ?? '');
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(L10n.of(context)?.changeNameTitle ?? 'Wijzig je naam'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(labelText: L10n.of(context)?.nameLabel ?? 'Je naam'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return L10n.of(context)?.nameValidation ?? 'Vul je naam in';
                    return null;
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(L10n.of(context)?.cancel ?? 'Annuleer')),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(L10n.of(context)?.save ?? 'Opslaan'),
                ),
              ],
            ),
          );

          if (result != true) return;
          if (!mounted) return;
          final newName = ctrl.text.trim();
          try {
            // 1. Update Firebase Auth Profile
            await user.updateDisplayName(newName);
            await user.reload();
            
            // 2. Update Firestore User Document
            final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
            await usersRef.set({
              'displayName': newName,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            
            if (!mounted) return;
            setState(() {
              _displayName = newName;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(L10n.of(context)?.nameUpdated ?? 'Naam bijgewerkt')),
            );
          } catch (e) {
            debugPrint('Failed to update displayName: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(L10n.of(context)?.nameUpdateFailed ?? 'Bijwerken mislukt')),
            );
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
                          _displayName ?? L10n.of(context)?.profile_default_name ?? 'Kevin le Goat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          _email ?? L10n.of(context)?.profile_default_email ?? 'kevinlegoat@example.com',
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
                        _buildStatItem('—', L10n.of(context)?.filmsDone ?? 'Films af', textColor),
                        _buildStatItem('—', L10n.of(context)?.watchlist_label ?? 'Watchlist', textColor),
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
                        L10n.of(context)?.filmsDone ?? 'Films af',
                        textColor,
                      ),
                      _buildStatItem(
                        watchlist.length.toString(),
                        L10n.of(context)?.watchlist_label ?? 'Watchlist',
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

  String _languageLabel(String code, BuildContext context) {
    switch (code) {
      case 'en':
        return L10n.of(context)?.english ?? 'English';
      case 'nl':
        return L10n.of(context)?.dutch ?? 'Nederlands';
      case 'fr':
        return L10n.of(context)?.french ?? 'Français';
      case 'de':
        return L10n.of(context)?.german ?? 'Deutsch';
      case 'es':
        return L10n.of(context)?.spanish ?? 'Español';
      case 'tr':
        return L10n.of(context)?.turkish ?? 'Türkçe';
      default:
        return code;
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

  Future<int> _fetchUnreadCustomerReplies() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0;
      final uid = user.uid;
      final snap = await FirebaseFirestore.instance
          .collection('customerquestions')
          .where('userId', isEqualTo: uid)
          .get();
      int unread = 0;
      for (final d in snap.docs) {
        final data = d.data();
        final adminReplies = (data['adminReplies'] as List?) ?? [];
        final userRead = data['userRead'] == true;

        if (!userRead) {
          unread += 1;
          continue;
        }

        for (final ar in adminReplies) {
          if (ar is Map) {
            final seenBy =
                (ar['seenBy'] as List?)?.map((e) => e.toString()).toList() ??
                    [];
            if (!seenBy.contains(uid)) {
              unread += 1;
              break;
            }
          }
        }
      }
      return unread;
    } catch (e) {
      debugPrint('Failed fetching unread customer replies (settings): $e');
      return 0;
    }
  }

  void _subscribeCustomerQuestions(String uid) {
    _customerQuestionsSub?.cancel();
    _customerQuestionsSub = FirebaseFirestore.instance
        .collection('customerquestions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen(
      (snap) {
        try {
          int unread = 0;
          for (final d in snap.docs) {
            final data = d.data();
            final adminReplies = (data['adminReplies'] as List?) ?? [];
            final userRead = data['userRead'] == true;

            if (!userRead) {
              unread += 1;
              continue;
            }

            for (final ar in adminReplies) {
              if (ar is Map) {
                final seenBy = (ar['seenBy'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [];
                if (!seenBy.contains(uid)) {
                  unread += 1;
                  break;
                }
              }
            }
          }
          if (mounted) setState(() => _cachedUnreadCustomerReplies = unread);
        } catch (e) {
          debugPrint('Failed to compute unread count in SettingsScreen: $e');
        }
      },
      onError: (e) {
        debugPrint('customerquestions listen error (settings): $e');
      },
    );
  }
}

// About text is provided via localization (app_nl.arb / app_en.arb)

class AboutCineTrackrScreen extends StatelessWidget {
  const AboutCineTrackrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          L10n.of(context)?.aboutTitle ?? 'Over CineTrackr',
          style: const TextStyle(color: Colors.white),
        ),

        backgroundColor: const Color.fromRGBO(43, 77, 91, 1),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
            child: Text(
              L10n.of(context)?.aboutText ?? '',
              style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
            ),
        ),
      ),
    );
  }
}

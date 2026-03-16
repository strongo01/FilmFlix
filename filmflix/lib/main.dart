import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cinetrackr/firebase_options.dart';
import 'package:cinetrackr/views/filmsnowscreen.dart';
import 'package:cinetrackr/views/foodscreen.dart';
import 'package:cinetrackr/views/search_screen.dart';
import 'package:cinetrackr/views/homescreen.dart';
import 'package:cinetrackr/views/loginscreen.dart';
import 'package:cinetrackr/views/settingscreen.dart'; 
import 'package:cinetrackr/views/watchlistscreen.dart';
import 'package:cinetrackr/utils/fcm_service.dart';
import 'package:cinetrackr/views/profiel.dart';
import 'package:cinetrackr/services/tutorial_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final analytics = FirebaseAnalytics.instance;

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await analytics.setUserId(id: user.uid);
  } else {
    final prefs = await SharedPreferences.getInstance();
    var anon = prefs.getString('analytics_anon_id');
      if (anon == null) {
        anon = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 31)}';
      await prefs.setString('analytics_anon_id', anon);
    }
    await analytics.setUserId(id: anon);
  }

  try {
    await analytics.logAppOpen();
  } catch (_) {
    }

  runApp(const CineTrackrApp());
}

class CineTrackrApp extends StatelessWidget {
  const CineTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineTrackr',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB22222),
        ),
      ),
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFB22222),
        ),
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
         // if (snapshot.hasData) {
             // Hier kun je nog steeds forceren voor testen als je wilt:
             // return const MovieDetailScreen(imdbId: "tt1632701"); 
             return const MainNavigation(); 
          //}
          //return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigation(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static final GlobalKey kaartKey = GlobalKey();

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  StreamSubscription<User?>? _authSub;

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _watchlistKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _foodKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  // Alle schermen die je in de balk wilt kunnen aanklikken
  final List<Widget> _screens = [
    const HomeScreen(),          // Index 0
    const WatchlistScreen(),     // Index 1 (Nieuw in balk)
    const SearchScreen(),        // Index 2
    const FoodScreen(),          // Index 3 (Nieuw in balk)
    const ProfileScreen(),      // Index 4
  ];

  void _showTutorial() {
    // Check of de eerste key wel echt in de widget tree zit
    if (_homeKey.currentContext == null) {
      debugPrint("Tutorial: _homeKey context is null, skipping tutorial trigger.");
      return;
    }

    List<TargetFocus> targets = [
      TutorialService.createTarget(
        identify: "home",
        key: _homeKey,
        text: "Welkom! Hier vind je de nieuwste films en series.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "watchlist",
        key: _watchlistKey,
        text: "Sla hier je favoriete films op voor later.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "search",
        key: _searchKey,
        text: "Zoek naar specifieke titels of genres.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "food",
        key: _foodKey,
        text: "Bekijk bijpassende snacks voor je filmavond!",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "profile",
        key: _profileKey,
        text: "Beheer hier je profiel en instellingen.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "kaart-target",
        key: MainNavigation.kaartKey,
        text: "Hier kun je de kaart bekijken om bioscopen in de buurt te vinden!",
        align: ContentAlign.bottom,
      ),
    ];

    void markTutorialAsDone() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_done', true);
      debugPrint("Tutorial: Marked as done in SharedPreferences.");
    }

    TutorialService.showTutorial(
      context,
      targets,
      onFinish: markTutorialAsDone,
      onSkip: markTutorialAsDone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C282E) : Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', _homeKey),
            _buildNavItem(1, Icons.movie_outlined, Icons.movie_filter_rounded, 'Watchlist', _watchlistKey),
            _buildNavItem(2, Icons.search_rounded, Icons.search_rounded, 'Zoeken', _searchKey),
            _buildNavItem(3, Icons.fastfood_outlined, Icons.fastfood_rounded, 'Food', _foodKey),
            _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profiel', _profileKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, GlobalKey key) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.grey;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            key: key,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Gebruik een herhalende check om te wachten tot de key beschikbaar is
      _checkAndStartTutorial();
    });
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      // Keep analytics user id in sync with auth state.
      final analytics = FirebaseAnalytics.instance;
      if (user != null) {
        await analytics.setUserId(id: user.uid);
        final ok = await registerFcmTokenForUser(user);
        debugPrint('Main: registerFcmTokenForUser result=$ok for uid=${user.uid}');
      } else {
        // user signed out: fall back to the stored anonymous id
        final prefs = await SharedPreferences.getInstance();
        var anon = prefs.getString('analytics_anon_id');
        if (anon == null) {
          anon = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 31)}';
          await prefs.setString('analytics_anon_id', anon);
        }
        await analytics.setUserId(id: anon);
      }
    });
  }

  int _tutorialRetryCount = 0;
  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDone = prefs.getBool('tutorial_done') ?? false;

    // Om de tutorial WEL elke keer te tonen (voor testen), comment de 'if (isDone) return;' hieronder uit:
    //TUTORIAL UIT/AAN
    if (isDone) return;

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (_homeKey.currentContext != null) {
        debugPrint("Tutorial: Home key valid, starting...");
        _showTutorial();
      } else if (_tutorialRetryCount < 5) {
        _tutorialRetryCount++;
        debugPrint("Tutorial: Home key not found, retry $_tutorialRetryCount...");
        _checkAndStartTutorial();
      } else {
        debugPrint("Tutorial: Gave up after 5 retries.");
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
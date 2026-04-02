import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cinetrackr/l10n/l10n.dart';

// dit zorgt voor dat we de gekozen taal kunnen opslaan en teruglezen, zodat de app in de juiste taal start bij volgende keren openen.
final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

Future<void> main() async {
  // Zorgt ervoor dat we eerst de benodigde services initialiseren voordat de app start.
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    // Forceer portrait mode voor een betere gebruikerservaring op mobiele apparaten.
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Initialiseer Firebase met de juiste opties voor het huidige platform.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final analytics = FirebaseAnalytics.instance;

  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await analytics.setUserId(
      id: user.uid,
    ); // Als de gebruiker al is ingelogd, stel dan de userId in voor analytics zodat we gebruikersgedrag kunnen volgen.
  } else {
    final prefs = await SharedPreferences.getInstance();
    var anon = prefs.getString('analytics_anon_id');
    if (anon == null) {
      anon =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 31)}'; // Genereer een unieke anonieme ID voor analytics tracking als er nog geen is opgeslagen.
      await prefs.setString('analytics_anon_id', anon);
    }
    await analytics.setUserId(id: anon);
  }

  try {
    await analytics
        .logAppOpen(); // Log een app open event voor analytics zodat we kunnen zien hoe vaak de app wordt geopend.
  } catch (_) {}

  // Laad opgeslagen taalvoorkeur (indien aanwezig) zodat de app in de gekozen taal kan starten.
  try {
    final prefs =
        await SharedPreferences.getInstance(); // Toegang tot SharedPreferences om de opgeslagen taalvoorkeur te lezen.
    final saved = prefs.getString('app_locale');
    if (saved != null) {
      // Als er een opgeslagen taal is, stel deze dan in op de localeNotifier zodat de app in die taal start.
      if (saved == 'nl')
        localeNotifier.value = const Locale('nl');
      else if (saved == 'en')
        localeNotifier.value = const Locale('en');
    }
  } catch (e) {
    debugPrint('Could not load saved locale: $e');
  }

  runApp(const CineTrackrApp());
}

class CineTrackrApp extends StatelessWidget {
  // De root widget van de app, verantwoordelijk voor het instellen van thema, taal en navigatie.
  const CineTrackrApp({super.key}); // Constructor voor de app widget.

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(
      context,
    ); // Toegang tot de gelokaliseerde strings zodat we de app-titel en andere teksten in de juiste taal kunnen tonen.
    return ValueListenableBuilder<Locale?>(
      // Gebruik een ValueListenableBuilder om te luisteren naar veranderingen in de gekozen taal (locale) en de app opnieuw op te bouwen met de nieuwe taalinstelling.
      valueListenable: localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          locale: locale,
          title:
              l10n?.appTitle ??
              'CineTrackr', // Stel de app-titel in op basis van de gelokaliseerde string, met een fallback naar 'CineTrackr' als de gelokaliseerde string niet beschikbaar is.
          debugShowCheckedModeBanner: false,
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(
              // Pas de kleuren aan voor het donkere thema zodat het er stijlvol uitziet.
              primary: Color(0xFFD4AF37),
              secondary: Color(0xFFB22222),
            ),
          ),
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF5F7F8),
            colorScheme: const ColorScheme.light(
              // Pas de kleuren aan voor het lichte thema zodat het er fris uitziet.
              primary: Color(0xFFD4AF37),
              secondary: Color(0xFFB22222),
            ),
          ),
          themeMode: ThemeMode.system,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaleFactor: mediaQuery.textScaleFactor.clamp(1.0, 1.3),
              ),
              child: child!,
            );
          },
          localizationsDelegates: [
            // Voeg de benodigde localizations delegates toe zodat de app in meerdere talen kan worden gebruikt.
            L10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            // Definieer de ondersteunde talen voor de app.
            Locale('nl'),
            Locale('en'),
            Locale('de'),
            Locale('fr'),
            Locale('tr'),
            Locale('es'),
          ],
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ), // Toon een laadindicator terwijl we wachten op de auth state om te laden, zodat de gebruiker weet dat er iets gebeurt.
                );
              }

              // if (snapshot.hasData) {
              // Hier kun je nog steeds forceren voor testen als je wilt:
              // return const MovieDetailScreen(imdbId: "tt1632701");
              return const MainNavigation(); // Als de gebruiker is ingelogd, ga dan naar het hoofdscherm van de app (MainNavigation) waar de belangrijkste functies beschikbaar zijn.
              //}
              //return const LoginScreen();
            },
          ),
          routes: {
            // Definieer de routes voor navigatie binnen de app, zodat we gemakkelijk kunnen navigeren tussen verschillende schermen.
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const MainNavigation(),
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  // Het hoofdscherm van de app met een bottom navigation bar om te navigeren tussen verschillende secties zoals Home, Watchlist, Search, Food en Profile.
  //statefulwidget is nodig omdat we de geselecteerde index van de navigatiebalk moeten bijhouden en mogelijk ook andere state zoals of de tutorial al is getoond.
  const MainNavigation({super.key});

  static final GlobalKey kaartKey =
      GlobalKey(); // Een globale key die we kunnen gebruiken om de kaart in de tutorial te targeten, zodat we gebruikers kunnen laten zien waar ze de kaart kunnen vinden in de app.

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  StreamSubscription<User?>?
  _authSub; // Een subscription om te luisteren naar veranderingen in de auth state, zodat we bijvoorbeeld analytics kunnen bijwerken wanneer de gebruiker inlogt of uitlogt.

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _watchlistKey = GlobalKey();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _foodKey = GlobalKey();
  final GlobalKey _profileKey = GlobalKey();

  // Alle schermen die je in de balk wilt kunnen aanklikken
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0
    const WatchlistScreen(), // Index 1
    const SearchScreen(), // Index 2
    const FoodScreen(), // Index 3
    const ProfileScreen(), // Index 4
  ];

  void _showTutorial() {
    // Check of de eerste key wel echt in de widget tree zit
    if (_homeKey.currentContext == null) {
      debugPrint(
        "Tutorial: _homeKey context is null, skipping tutorial trigger.",
      );
      return;
    }

    final l10n = L10n.of(context);
    List<TargetFocus> targets = [
      // Definieer de targets voor de tutorial, waarbij we elke belangrijke functie in de navigatiebalk targeten met een beschrijving van wat het doet, zodat nieuwe gebruikers snel kunnen leren hoe ze de app kunnen gebruiken.
      TutorialService.createTarget(
        // Target voor de Home-knop in de navigatiebalk.
        identify: "home",
        key: _homeKey,
        text:
            l10n?.tutorialHome ??
            "Welkom! Hier vind je de nieuwste films en series.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "watchlist",
        key: _watchlistKey,
        text:
            l10n?.tutorialWatchlist ??
            "Sla hier je favoriete films op voor later.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "search",
        key: _searchKey,
        text: l10n?.tutorialSearch ?? "Zoek naar specifieke titels of genres.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "food",
        key: _foodKey,
        text:
            l10n?.tutorialFood ??
            "Bekijk bijpassende snacks voor je filmavond!",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "profile",
        key: _profileKey,
        text:
            l10n?.tutorialProfile ?? "Beheer hier je profiel en instellingen.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "kaart-target",
        key: MainNavigation.kaartKey,
        text:
            l10n?.tutorialMap ??
            "Hier kun je de kaart bekijken om bioscopen in de buurt te vinden!",
        align: ContentAlign.bottom,
      ),
    ];

    void markTutorialAsDone() async {
      // Functie om aan te geven dat de tutorial is voltooid, zodat we deze niet opnieuw hoeven te tonen bij volgende app-starts.
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
    // Bouw het hoofdscherm van de app met een Scaffold, waarbij we een IndexedStack gebruiken om de verschillende schermen te tonen op
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        // Een container voor de bottom navigation bar, waarbij we de achtergrondkleur aanpassen op basis van het thema (donker of licht) en een subtiele scheidingslijn toevoegen aan de bovenkant.
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C282E) : Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              // Bouw elk item in de navigatiebalk met een icon, label en een key voor de tutorial, zodat we gebruikers kunnen laten zien waar ze op moeten klikken om naar verschillende secties van de app te gaan.
              0,
              Icons.home_outlined,
              Icons.home_rounded,
              l10n?.navHome ?? 'Home',
              _homeKey,
            ),
            _buildNavItem(
              1,
              Icons.movie_outlined,
              Icons.movie_filter_rounded,
              l10n?.navWatchlist ?? 'Watchlist',
              _watchlistKey,
            ),
            _buildNavItem(
              2,
              Icons.search_rounded,
              Icons.search_rounded,
              l10n?.navSearch ?? 'Zoeken',
              _searchKey,
            ),
            _buildNavItem(
              3,
              Icons.fastfood_outlined,
              Icons.fastfood_rounded,
              l10n?.navFood ?? 'Food',
              _foodKey,
            ),
            _buildNavItem(
              4,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              l10n?.navProfile ?? 'Profiel',
              _profileKey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    // Helperfunctie om een item in de navigatiebalk te bouwen, waarbij we de geselecteerde status controleren om de juiste icon en kleur te tonen, en een GestureDetector gebruiken om te reageren op taps zodat we kunnen navigeren naar het juiste scherm.
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    GlobalKey key,
  ) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.grey;

    return GestureDetector(
      // Gebruik een GestureDetector om te detecteren wanneer de gebruiker op een item in de navigatiebalk tikt, zodat we de geselecteerde index kunnen bijwerken en het juiste scherm kunnen tonen.
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior
          .opaque, // Zorg ervoor dat de hele ruimte van het item klikbaar is, niet alleen het icon of label, voor een betere gebruikerservaring.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : icon, key: key, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  @override
  void initState() {
    // In de initState van het hoofdscherm zetten we een post-frame callback om te controleren of we de tutorial moeten tonen, en we luisteren naar veranderingen in de auth state om analytics bij te werken, zodat we gebruikersgedrag kunnen volgen en de tutorial kunnen tonen aan nieuwe gebruikers.
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //   Zodra het eerste frame is gerenderd, controleren we of we de tutorial moeten tonen door te kijken naar de opgeslagen voorkeuren, zodat nieuwe gebruikers een introductie krijgen tot de belangrijkste functies van de app.
      // Gebruik een herhalende check om te wachten tot de key beschikbaar is
      _checkAndStartTutorial();
    });
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      // Keep analytics user id in sync with auth state.
      final analytics = FirebaseAnalytics.instance;
      if (user != null) {
        await analytics.setUserId(id: user.uid);
        final ok = await registerFcmTokenForUser(user);
        debugPrint(
          'Main: registerFcmTokenForUser result=$ok for uid=${user.uid}',
        );
      } else {
        // Als de gebruiker uitlogt, stel dan een anonieme ID in voor analytics zodat we nog steeds gebruikersgedrag kunnen volgen zonder persoonlijke informatie te verzamelen.
        final prefs = await SharedPreferences.getInstance();
        var anon = prefs.getString('analytics_anon_id');
        if (anon == null) {
          anon =
              '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 31)}';
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
      //dit stukje doet een check na een korte vertraging om te zien of de home key beschikbar is
      if (!mounted) return;

      if (_homeKey.currentContext != null) {
        debugPrint("Tutorial: Home key valid, starting...");
        _showTutorial(); // Als de home key beschikbaar is, start dan de tutorial zodat we gebruikers kunnen laten zien hoe ze de app kunnen gebruiken.
      } else if (_tutorialRetryCount < 5) {
        _tutorialRetryCount++;
        debugPrint(
          "Tutorial: Home key not found, retry $_tutorialRetryCount...",
        );
        _checkAndStartTutorial();
      } else {
        debugPrint("Tutorial: Gave up after 5 retries.");
      }
    });
  }

  @override
  void dispose() {
    //dispose betekent dat we resources opruimen wanneer deze widget uit de widget tree wordt verwijderd, in dit geval annuleren we de subscription naar auth state changes om geheugenlekken te voorkomen.
    _authSub?.cancel();
    super.dispose();
  }
}

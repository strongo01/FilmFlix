import 'dart:async';
import 'dart:math';

import 'package:cinetrackr/services/tutorial_service.dart';
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

import 'services/tutorial_service.dart';

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
              return MainNavigation(
                key: MainNavigation.mainKey,
              ); // Als de gebruiker is ingelogd, ga dan naar het hoofdscherm van de app (MainNavigation) waar de belangrijkste functies beschikbaar zijn.
              //}
              //return const LoginScreen();
            },
          ),
          routes: {
            // Definieer de routes voor navigatie binnen de app, zodat we gemakkelijk kunnen navigeren tussen verschillende schermen.
            '/login': (context) => const LoginScreen(),
            '/home': (context) => MainNavigation(key: MainNavigation.mainKey),
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
  // Global key to access the state from other widgets (e.g. to retrigger tutorial)
  // Use an untyped GlobalKey to avoid exposing the private state type across libraries.
  static final GlobalKey mainKey = GlobalKey();
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
  final GlobalKey _navBarKey = GlobalKey();

  // Alle schermen die je in de balk wilt kunnen aanklikken
  final List<Widget> _screens = [
    HomeScreen(key: HomeScreen.homeKey), // Index 0
    WatchlistScreen(key: WatchlistScreen.watchlistScreenKey), // Index 1
    SearchScreen(key: SearchScreen.searchScreenKey), // Index 2
    FoodScreen(key: FoodScreen.foodScreenKey), // Index 3
    ProfileScreen(key: ProfileScreen.profileScreenKey), // Index 4
  ];

  // Nav order stores the screen ids in the order they should appear in the bar.
  // Default is [0,1,2,3,4]. Persisted in SharedPreferences as strings.
  List<int> _navOrder = [0, 1, 2, 3, 4];
  bool _reorderMode = false; // When true, user can drag to reorder items

  int get currentScreenId =>
      (_selectedIndex >= 0 && _selectedIndex < _navOrder.length)
      ? _navOrder[_selectedIndex]
      : _navOrder.first;

  // Map screen id -> GlobalKey used for tutorial targeting (keep existing keys)
  late final Map<int, GlobalKey> _navKeys = {
    0: _homeKey,
    1: _watchlistKey,
    2: _searchKey,
    3: _foodKey,
    4: _profileKey,
  };

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
        identify: "nav-bar",
        key: _navBarKey,
        text:
            l10n?.tutorialNavBar ??
            "Welkom! Hier kan je het startscherm veranderen. Houd een knop lang ingedrukt om dat scherm je startscherm te maken.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        identify: "nav-bar",
        key: _navBarKey,
        text:
            l10n?.tutorialNavBar2 ??
            "Als je de ruimte tussen de knoppen ingedrukt houdt, kun je de volgorde van de knoppen veranderen.",
        align: ContentAlign.top,
      ),
      TutorialService.createTarget(
        // Target voor de Home-knop in de navigatiebalk.
        identify: "home",
        key: _homeKey,
        text: l10n?.tutorialHome ?? "Hier vind je de nieuwste films en series.",
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

    // Add screen-specific tips that appear when the user is currently on that screen.
    final displayedScreenId =
        (_selectedIndex >= 0 && _selectedIndex < _navOrder.length)
        ? _navOrder[_selectedIndex]
        : _navOrder.first;

    /* switch (displayedScreenId) {
      case 0: // Home
        if (!targets.any((t) => t.keyTarget == _homeKey)) {
          targets.add(TutorialService.createTarget(
            identify: 'home-screen-tip',
            key: _homeKey,
            text: l10n?.tutorialHomeExtra ??
                'Op het Home-scherm zie je de nieuwste releases en aanbevelingen.',
            align: ContentAlign.bottom,
          ));
        }
        break;
      case 1: // Watchlist
        if (!targets.any((t) => t.keyTarget == _watchlistKey)) {
          targets.add(TutorialService.createTarget(
            identify: 'watchlist-screen-tip',
            key: _watchlistKey,
            text: l10n?.tutorialWatchlistExtra ??
                'In je Watchlist kun je films verwijderen of later terugkijken.',
            align: ContentAlign.bottom,
          ));
        }
        break;
      case 2: // Search
        if (!targets.any((t) => t.keyTarget == _searchKey)) {
          targets.add(TutorialService.createTarget(
            identify: 'search-screen-tip',
            key: _searchKey,
            text: l10n?.tutorialSearchExtra ??
                'Gebruik de zoekbalk om snel titels en acteurs te vinden.',
            align: ContentAlign.bottom,
          ));
        }
        break;
      case 3: // Food
        if (!targets.any((t) => t.keyTarget == _foodKey)) {
          targets.add(TutorialService.createTarget(
            identify: 'food-screen-tip',
            key: _foodKey,
            text: l10n?.tutorialFoodExtra ??
                'Bekijk hier snacks en recepten die passen bij je filmkeuze.',
            align: ContentAlign.bottom,
          ));
        }
        break;
      case 4: // Profile
        if (!targets.any((t) => t.keyTarget == _profileKey)) {
          targets.add(TutorialService.createTarget(
            identify: 'profile-screen-tip',
            key: _profileKey,
            text: l10n?.tutorialProfileExtra ??
                'In je profiel beheer je instellingen, voorkeuren en accountgegevens.',
            align: ContentAlign.bottom,
          ));
        }
        break;
    }*/

    // Voor de hoofdnavigatie (initieel) gebruiken we de check.
    // Maar als onFinish wordt aangeroepen, doen we dat ook via de prefs.
    TutorialService.checkAndShowTutorial(
      context,
      tutorialKey: 'main_navigation',
      targets: targets,
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('tutorial_done_main_navigation', true);
        debugPrint(
          "Main navigation tutorial complete, starting Home tutorial...",
        );

        // We gebruiken een setState om de UI te forceren te verversen
        if (mounted) setState(() {});

        // Directe aanroep zonder lange delay om de UI thread "wakker" te houden
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedIndex == 0) {
            () async {
              final prefs = await SharedPreferences.getInstance();
              final homeDone = prefs.getBool('tutorial_done_home_screen') ?? true;
              if (!homeDone) {
                HomeScreen.homeKey.currentState?.startHomeScreenTutorial();
              }
            }();
          }
        });
      },
      onSkip: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('tutorial_done_main_navigation', true);
        debugPrint(
          "Main navigation tutorial skipped, starting Home tutorial...",
        );

        if (mounted) setState(() {});

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedIndex == 0) {
            () async {
              final prefs = await SharedPreferences.getInstance();
              final homeDone = prefs.getBool('tutorial_done_home_screen') ?? true;
              if (!homeDone) {
                HomeScreen.homeKey.currentState?.startHomeScreenTutorial();
              }
            }();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bouw het hoofdscherm van de app met een Scaffold, waarbij we een IndexedStack gebruiken om de verschillende schermen te tonen op
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context);

    final displayedScreenId =
        (_selectedIndex >= 0 && _selectedIndex < _navOrder.length)
        ? _navOrder[_selectedIndex]
        : _navOrder.first;

    return Scaffold(
      body: IndexedStack(index: displayedScreenId, children: _screens),
      bottomNavigationBar: GestureDetector(
        onLongPress: _showReorderDialog,
        child: Container(
          key: _navBarKey,
          // Een container voor de bottom navigation bar, waarbij we de achtergrondkleur aanpassen op basis van het thema (donker of licht) en een subtiele scheidingslijn toevoegen aan de bovenkant.
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C282E) : Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          padding: const EdgeInsets.only(top: 14, bottom: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navOrder.length, (pos) {
              final screenId = _navOrder[pos];
              // Define icons/labels based on screenId
              IconData icon = Icons.home_outlined;
              IconData activeIcon = Icons.home_rounded;
              String label = l10n?.navHome ?? 'Home';
              switch (screenId) {
                case 0:
                  icon = Icons.home_outlined;
                  activeIcon = Icons.home_rounded;
                  label = l10n?.navHome ?? 'Home';
                  break;
                case 1:
                  icon = Icons.movie_outlined;
                  activeIcon = Icons.movie_filter_rounded;
                  label = l10n?.navWatchlist ?? 'Watchlist';
                  break;
                case 2:
                  icon = Icons.search_rounded;
                  activeIcon = Icons.search_rounded;
                  label = l10n?.navSearch ?? 'Zoeken';
                  break;
                case 3:
                  icon = Icons.fastfood_outlined;
                  activeIcon = Icons.fastfood_rounded;
                  label = l10n?.navFood ?? 'Food';
                  break;
                case 4:
                  icon = Icons.person_outline_rounded;
                  activeIcon = Icons.person_rounded;
                  label = l10n?.navProfile ?? 'Profiel';
                  break;
              }

              final baseItem = _buildNavItem(
                pos,
                screenId,
                icon,
                activeIcon,
                label,
                _navKeys[screenId]!,
              );

              if (_reorderMode) {
                // Make draggable and a drag target to allow swapping positions.
                return LongPressDraggable<int>(
                  data: pos,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Opacity(
                      opacity: 0.9,
                      // Use a key-less copy for feedback to avoid duplicate GlobalKey errors.
                      child: _buildNavItem(
                        pos,
                        screenId,
                        icon,
                        activeIcon,
                        label,
                        null,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.4,
                    child: _buildNavItem(
                      pos,
                      screenId,
                      icon,
                      activeIcon,
                      label,
                      null,
                    ),
                  ),
                  child: DragTarget<int>(
                    onWillAccept: (from) => from != pos,
                    onAccept: (from) {
                      setState(() {
                        final moving = _navOrder.removeAt(from);
                        _navOrder.insert(pos, moving);
                        _saveNavOrder();
                        // adjust selected pos if needed
                        if (_selectedIndex == from)
                          _selectedIndex = pos;
                        else if (from < _selectedIndex && pos >= _selectedIndex)
                          _selectedIndex -= 1;
                        else if (from > _selectedIndex && pos <= _selectedIndex)
                          _selectedIndex += 1;
                      });
                    },
                    builder: (context, candidateData, rejectedData) => baseItem,
                  ),
                );
              }

              return baseItem;
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _showReorderDialog() async {
    setState(() => _reorderMode = true);

    final l10n = L10n.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(l10n?.navigationReorder ?? 'Herorden navigatie'),
              content: SizedBox(
                width: double.maxFinite,
                height: 320,
                child: ReorderableListView(
                  buildDefaultDragHandles: true,
                  children: _navOrder.map((screenId) {
                    String label;
                    IconData icon;
                    switch (screenId) {
                      case 0:
                        label = l10n?.navHome ?? 'Home';
                        icon = Icons.home_outlined;
                        break;
                      case 1:
                        label = l10n?.navWatchlist ?? 'Watchlist';
                        icon = Icons.movie_outlined;
                        break;
                      case 2:
                        label = l10n?.navSearch ?? 'Zoeken';
                        icon = Icons.search_rounded;
                        break;
                      case 3:
                        label = l10n?.navFood ?? 'Food';
                        icon = Icons.fastfood_outlined;
                        break;
                      default:
                        label = l10n?.navProfile ?? 'Profiel';
                        icon = Icons.person_outline_rounded;
                    }

                    return ListTile(
                      key: ValueKey('nav-$screenId'),
                      leading: Icon(icon),
                      title: Text(label),
                      trailing: const Icon(Icons.drag_handle),
                      onTap: () async {
                        // allow tapping to set as start screen
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('start_screen_id', screenId);
                        final message =
                            l10n?.set_as_start_screen(label) ??
                            '${label} ingesteld als startscherm';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  onReorder: (oldIndex, newIndex) {
                    // update dialog UI first
                    setStateDialog(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _navOrder.removeAt(oldIndex);
                      _navOrder.insert(newIndex, item);
                    });
                    // persist and update outer UI
                    setState(() {
                      _saveNavOrder();
                      if (_selectedIndex == oldIndex)
                        _selectedIndex = newIndex;
                      else if (oldIndex < _selectedIndex &&
                          newIndex >= _selectedIndex)
                        _selectedIndex -= 1;
                      else if (oldIndex > _selectedIndex &&
                          newIndex <= _selectedIndex)
                        _selectedIndex += 1;
                    });
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n?.close ?? 'Sluiten'),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() => _reorderMode = false);
  }

  Widget _buildNavItem(
    int position,
    int screenId,
    IconData icon,
    IconData activeIcon,
    String label,
    GlobalKey? key,
  ) {
    final isSelected = _selectedIndex == position;
    final color = isSelected ? const Color(0xFFD4AF37) : Colors.grey;
    final l10n = L10n.of(context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = position);
            if (screenId == 2) {
              // When switching to search tab, try starting the search tutorial
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SearchScreen.searchScreenKey.currentState
                    ?.startSearchScreenTutorial();
              });
            } else if (screenId == 3) {
              // When switching to food tab, try starting the food tutorial
              WidgetsBinding.instance.addPostFrameCallback((_) {
                FoodScreen.foodScreenKey.currentState
                    ?.startFoodScreenTutorial();
              });
            } else if (screenId == 1) {
              // When switching to watchlist tab, try starting the watchlist tutorial
              WidgetsBinding.instance.addPostFrameCallback((_) {
                WatchlistScreen.watchlistScreenKey.currentState
                    ?.startWatchlistScreenTutorial();
              });
            } else if (screenId == 4) {
              // When switching to profile tab, try starting the profile tutorial
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ProfileScreen.profileScreenKey.currentState
                    ?.startProfileScreenTutorial();
              });
            }
          },
          onLongPress: () async {
            // A plain long press (without drag) sets this screen as the start screen.
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('start_screen_id', screenId);
            final message =
                l10n?.set_as_start_screen(label) ??
                '${label} ingesteld als startscherm';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (key != null)
                Icon(isSelected ? activeIcon : icon, key: key, color: color)
              else
                Icon(isSelected ? activeIcon : icon, color: color),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 10)),
              if (_reorderMode) const SizedBox(height: 4),
              if (_reorderMode)
                Icon(Icons.drag_indicator_rounded, size: 12, color: color),
            ],
          ),
        ),
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
    // load nav order and preferred start screen
    _loadNavOrder();
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

  Future<void> _loadNavOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('nav_order');
      if (list != null && list.isNotEmpty) {
        _navOrder = list.map((s) => int.tryParse(s) ?? 0).toList();
      }
      final startId = prefs.getInt('start_screen_id');
      if (startId != null) {
        final pos = _navOrder.indexOf(startId);
        _selectedIndex = pos >= 0 ? pos : 0;
      } else {
        _selectedIndex = 0;
      }
      setState(() {});
    } catch (e) {
      debugPrint('Could not load nav order: $e');
    }
  }

  Future<void> _saveNavOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'nav_order',
      _navOrder.map((i) => i.toString()).toList(),
    );
  }

  int _tutorialRetryCount = 0;
  void _checkAndStartTutorial() async {
    // Om de tutorial WEL elke keer te tonen (voor testen), kun je de check in TutorialService tijdelijk skippen.

    Future.delayed(const Duration(milliseconds: 100), () async {
      //dit stukje doet een check na een korte vertraging om te zien of de home key beschikbar is
      if (!mounted) return;

      if (_homeKey.currentContext != null) {
        debugPrint("Tutorial: Home key valid, asking user permission...");
        await _askToStartTutorial();
      } else if (_tutorialRetryCount < 10) {
        _tutorialRetryCount++;
        debugPrint(
          "Tutorial: Home key not found, retry $_tutorialRetryCount...",
        );
        _checkAndStartTutorial();
      } else {
        debugPrint("Tutorial: Gave up after 10 retries.");
      }
    });
  }

  Future<void> _askToStartTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyDone = prefs.getBool('tutorial_done_main_navigation') ?? false;
      if (alreadyDone) return;

      final l10n = L10n.of(context);

      final bool? start = await showDialog<bool>(
        context: _homeKey.currentContext ?? context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n?.tutorialPromptTitle ?? 'Introductietour'),
            content: Text(l10n?.tutorialPromptBody ??
                'Wil je graag een korte rondleiding door de app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n?.no ?? 'Nee'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n?.yes ?? 'Ja'),
              ),
            ],
          );
        },
      );

      if (start == true) {
        _showTutorial();
      } else {
       // Markeer bekende tutorial keys als done (ook als ze nog niet bestaan),
       // en zet ook alle bestaande tutorial-pref keys op true.
        final knownKeys = [
          'tutorial_done_main_navigation',
          'tutorial_done_home_screen',
          'tutorial_done_search_screen',
          'tutorial_done_food_screen',
          'tutorial_done_watchlist_screen',
          'tutorial_done_profile_screen',
          'tutorial_done_movie_detail',
          'tutorial_done', 
        ];
        for (final key in knownKeys) {
          await prefs.setBool(key, true);
        }
        // Daarnaast, als er nog andere keys in prefs zijn die 'tutorial' bevatten, markeer die ook als done. Dit zorgt ervoor dat zelfs als we later nieuwe tutorial keys toevoegen, gebruikers die de tutorial hebben overgeslagen niet alsnog getarget worden door die nieuwe keys.
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.contains('tutorial') || key.contains('tutorial_done')) {
            await prefs.setBool(key, true);
          }
        }
        debugPrint('Tutorial: user declined - marked tutorial keys as done.');
      }
    } catch (e) {
      debugPrint('Error asking/setting tutorial prefs: $e');
    }
  }

  // dit is een helper functie die we kunnen aanroepen vanuit andere schermen om de tutorial opnieuw te starten, bijvoorbeeld als de gebruiker in de instellingen op "Tutorial opnieuw starten" klikt. We forceren hier ook dat we teruggaan naar het home scherm voordat we de tutorial starten, zodat we zeker weten dat alle elementen van de tutorial beschikbaar zijn.
  void startTutorial() {
    setState(() {
      _selectedIndex = 0; // Forceer terug naar home
    });
    // Wacht even tot de Tab is gewisseld voordat de tutorial start
    Future.delayed(const Duration(milliseconds: 300), () {
      _showTutorial(); // Direct de tutorial tonen zonder status-checks
    });
  }

  void startSearchTutorial() {
    final pos = _navOrder.indexOf(2);
    if (pos != -1) {
      setState(() => _selectedIndex = pos);
      Future.delayed(const Duration(milliseconds: 300), () {
        SearchScreen.searchScreenKey.currentState?.startSearchScreenTutorial(
          force: true,
        );
      });
    }
  }

  void startFoodTutorial() {
    final pos = _navOrder.indexOf(3);
    if (pos != -1) {
      setState(() => _selectedIndex = pos);
      Future.delayed(const Duration(milliseconds: 300), () {
        FoodScreen.foodScreenKey.currentState?.startFoodScreenTutorial(
          force: true,
        );
      });
    }
  }

  void startWatchlistTutorial() {
    final pos = _navOrder.indexOf(1);
    if (pos != -1) {
      setState(() => _selectedIndex = pos);
      Future.delayed(const Duration(milliseconds: 300), () {
        WatchlistScreen.watchlistScreenKey.currentState
            ?.startWatchlistScreenTutorial(force: true);
      });
    }
  }

  void startProfileTutorial() {
    final pos = _navOrder.indexOf(4);
    if (pos != -1) {
      setState(() => _selectedIndex = pos);
      Future.delayed(const Duration(milliseconds: 300), () {
        ProfileScreen.profileScreenKey.currentState?.startProfileScreenTutorial(
          force: true,
        );
      });
    }
  }

  @override
  void dispose() {
    //dispose betekent dat we resources opruimen wanneer deze widget uit de widget tree wordt verwijderd, in dit geval annuleren we de subscription naar auth state changes om geheugenlekken te voorkomen.
    _authSub?.cancel();
    super.dispose();
  }
}

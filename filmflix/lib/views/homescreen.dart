import 'dart:convert'; // Importeer het convert-pakket voor JSON-decodering
import 'dart:async'; // Importeer async-pakket voor Stream en Future functies
import 'dart:math' as Math; // Importeer math-pakket voor wiskundige bewerkingen

import 'package:cinetrackr/l10n/l10n.dart';
import 'package:cinetrackr/views/adminscreen.dart'; // Importeer het adminscherm
import 'package:cinetrackr/views/customer_service.dart'; // Importeer klantenservice-scherm
import 'package:cinetrackr/views/filmsnowscreen.dart'; // Importeer films-nu-scherm
import 'package:cinetrackr/views/foodscreen.dart'; // Importeer voedselscherm
import 'package:cinetrackr/views/kaart.dart'; // Importeer kaartscherm
import 'package:cinetrackr/views/search_screen.dart'; // Importeer zoekscherm
import 'package:cinetrackr/views/settingscreen.dart'; // Importeer instellingenscherm
import 'package:cinetrackr/views/watchlistscreen.dart'; // Importeer watchlistscherm
import 'package:flutter/material.dart'; // Importeer Flutter Material Design
import 'package:http/http.dart'
    as http; // Importeer HTTP-pakket voor API-verzoeken
import 'package:firebase_auth/firebase_auth.dart'; // Importeer Firebase-authenticatie
import 'package:cloud_firestore/cloud_firestore.dart'; // Importeer Firestore-database

import 'package:cinetrackr/views/movie_detail_screen.dart'; // Importeer filmdetailscherm
import 'package:cinetrackr/services/tutorial_service.dart'; // Importeer tutorialservice
import 'package:cinetrackr/main.dart'; // Importeer hoofdapp-bestand
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; // Importeer tutorial-gids-pakket
import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeer lokalisatiebestand

// Dataklasse voor filmgegevens uit de API
class FilmNowItem {
  final String tmdbId; // TMDB ID van de film
  final String title; // Filmtitel
  final String? poster; // URL van de filmaffiche
  final String? backdrop; // URL van filmachtergrond
  String? imdbId; // IMDB ID voor navigatie naar detail-scherm

  FilmNowItem({
    // Constructor voor FilmNowItem
    required this.tmdbId,
    required this.title,
    this.poster,
    this.backdrop,
    this.imdbId,
  });
}

class HomeScreen extends StatefulWidget {
  // Statefulwidget voor het homescherm
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // Maak de staat voor het homescherm
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseApi =
      'https://film-flix-olive.vercel.app/api/movies'; // API-URL voor filmgegevens
  List<FilmNowItem> films = []; // Lijst met huidige films
  bool loadingFilms = true; // Laadstatus van films
  int currentIndex = 0; // Huidige geselecteerde filmindex
  final PageController _pageController = PageController(
    viewportFraction: 0.85,
  ); // Controller voor filmcarrousel

  int _cachedUnreadCustomerReplies = 0; // Cache voor ongelezen klantreplies
  int _cachedUnreadAdminChats = 0; // Cache voor ongelezen admin-chats
  Future<void>? _initialLoads; // Future voor initiële laadprocessen
  StreamSubscription<User?>? _authSub; // Abonnement op authenticatiewijzigingen
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _customerQuestionsSub; // Abonnement op klantenvragen
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _allCustomerQuestionsSub; // Abonnement op alle klantenvragen

  @override
  void initState() {
    // Initialisatie van de widget
    super.initState();

    // Check direct of de tutorial getoond moet worden
    _checkTutorialOnInit();

    // Start de initiële laden- en controleprocessen
    _initialLoads = (() async {
      final loadNow = _loadNowPlaying(); // Laad hudig speelende films
      final fetchUnread = _fetchUnreadCustomerReplies().then((v) {
        // Haal ongelezen replies op
        if (mounted)
          setState(
            () => _cachedUnreadCustomerReplies = v,
          ); // Update cache indien widget nog actief is
      });
      await Future.wait([
        loadNow,
        fetchUnread,
      ]); // Wacht tot alle taken klaar zijn
    })();

    // Voer displaynaam-controle uit na initiële laden
    _initialLoads!.then((_) {
      _ensureDisplayName(); // Zorg ervoor dat gebruiker displaynaam heeft
    });

    // Abonneer op authenticatiewijzigingen voor live badge-updates
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // Als gebruiker ingelogd is
        _subscribeCustomerQuestions(user.uid); // Abonneer op klantenvragen
        _maybeSubscribeAdmin(
          user.uid,
        ); // Controleer admin-status en abonneer indien nodig
      } else {
        // Als gebruiker uitgelogd is
        _customerQuestionsSub?.cancel(); // Zeg abonnement op
        _customerQuestionsSub = null;
        _allCustomerQuestionsSub?.cancel(); // Zeg admin-abonnement op
        _allCustomerQuestionsSub = null;
        if (mounted) {
          // Update badge indien widget nog actief is
          setState(() {
            _cachedUnreadCustomerReplies = 0;
            _cachedUnreadAdminChats = 0;
          });
        }
      }
    });
  }

  void _maybeSubscribeAdmin(String uid) async {
    // Controleer of gebruiker admin is en abonneer op admin-chats
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(); // Haal gebruikersdocument op
      final data = doc.data();
      bool isAdmin = false;
      if (data != null) {
        // Als document bestaat
        final role = data['role']; // Haal rolveld op
        if (role is String)
          isAdmin =
              role.toLowerCase() ==
              'admin'; // Controleer of rol admin is (als string)
        if (role is List) // Controleer of rol admin is (als lijst)
          isAdmin = role.any(
            (e) => (e?.toString().toLowerCase() ?? '') == 'admin',
          );
      }
      if (isAdmin) {
        // Als gebruiker admin is
        _subscribeAllCustomerQuestions(); // Abonneer op alle klantenvragen
      } else {
        // Als gebruiker geen admin is
        _allCustomerQuestionsSub?.cancel(); // Zeg abonnement op
        _allCustomerQuestionsSub = null;
        if (mounted)
          setState(
            () => _cachedUnreadAdminChats = 0,
          ); // Reset admin-chat-counter
      }
    } catch (e) {
      debugPrint('Failed to determine admin role (home): $e'); // Log fout
    }
  }

  void _subscribeAllCustomerQuestions() {
    // Abonneer op alle klantenvragen voor admin-badge
    _allCustomerQuestionsSub?.cancel(); // Zeg vorig abonnement op
    _allCustomerQuestionsSub = FirebaseFirestore.instance
        .collection('customerquestions')
        .snapshots() // Luister naar wijzigingen
        .listen(
          (snap) {
            try {
              int adminUnread = 0;
              for (final d in snap.docs) {
                // Loop door alle documenten
                final data = d.data();

                int _tsToMs(dynamic ts) {
                  // Helperfunctie: converteer timestamp naar milliseconden
                  try {
                    if (ts == null) return 0;
                    if (ts is Timestamp) return ts.millisecondsSinceEpoch;
                    if (ts is DateTime) return ts.millisecondsSinceEpoch;
                    if (ts is int) return ts;
                    if (ts is String)
                      return DateTime.tryParse(ts)?.millisecondsSinceEpoch ?? 0;
                  } catch (_) {}
                  return 0;
                }

                final adminReplies =
                    (data['adminReplies'] as List?) ??
                    []; // Haal admin-replies op
                final userReplies =
                    (data['userReplies'] as List?) ??
                    []; // Haal gebruiker-replies op
                final answer = (data['answer'] ?? '')
                    .toString(); // Haal antwoord op

                int lastUserMs = _tsToMs(
                  data['createdAt'],
                ); // Zet aanmaakdatum als laatste gebruikersreactie
                for (final ur in userReplies) {
                  // Loop door gebruiker-replies
                  try {
                    final ts = ur is Map
                        ? (ur['createdAt'] ?? ur['updatedAt'])
                        : null;
                    lastUserMs = Math.max(
                      lastUserMs,
                      _tsToMs(ts),
                    ); // Voeg nieuwe gebruikerstijd bij indien recenter
                  } catch (_) {}
                }

                int lastAdminMs = _tsToMs(
                  data['answerAt'] ?? data['updatedAt'],
                ); // Zet admin-reactietijd
                if (answer.isNotEmpty) // Als antwoord bestaat
                  lastAdminMs = Math.max(
                    lastAdminMs,
                    _tsToMs(data['answerAt'] ?? data['updatedAt']),
                  );
                lastAdminMs = Math.max(
                  lastAdminMs,
                  _tsToMs(data['adminSeenAt']),
                ); // Voeg gezien-time bij indien recenter
                for (final ar in adminReplies) {
                  // Loop door admin-replies
                  try {
                    final ts = ar is Map
                        ? (ar['createdAt'] ?? ar['answerAt'] ?? ar['updatedAt'])
                        : null;
                    lastAdminMs = Math.max(
                      lastAdminMs,
                      _tsToMs(ts),
                    ); // Voeg nieuwe admin-tijd bij indien recenter
                  } catch (_) {}
                }

                final bool adminReadFlag = data['adminRead'] is bool
                    ? data['adminRead'] as bool
                    : true; // Lees admin-gelezen-status
                final bool unreadForAdmin =
                    (!adminReadFlag && lastUserMs > 0) ||
                    (lastUserMs >
                        lastAdminMs); // Controleer of ongelezen voor admin
                if (unreadForAdmin) adminUnread += 1; // Tel ongelezen vraag
              }
              if (mounted)
                setState(
                  () => _cachedUnreadAdminChats = adminUnread,
                ); // Update admin-chat-counter
            } catch (e) {
              debugPrint(
                'Failed to compute admin unread count in HomeScreen: $e',
              ); // Log fout
            }
          },
          onError: (e) {
            debugPrint(
              'customerquestions listen error (home admin): $e',
            ); // Log abonnementsfout
          },
        );
  }

  void _subscribeCustomerQuestions(String uid) {
    // Abonneer op klantenvragen van huidige gebruiker
    _customerQuestionsSub?.cancel(); // Zeg vorig abonnement op
    _customerQuestionsSub = FirebaseFirestore.instance
        .collection('customerquestions')
        .where('userId', isEqualTo: uid)
        .snapshots() // Luister naar wijzigingen
        .listen(
          (snap) {
            try {
              int unread = 0;
              for (final d in snap.docs) {
                // Loop door alle documenten
                final data = d.data();
                final adminReplies =
                    (data['adminReplies'] as List?) ??
                    []; // Haal admin-replies op
                final userRead =
                    data['userRead'] ==
                    true; // Controleer of gebruiker heeft gelezen

                if (!userRead) {
                  // Als gebruiker niet heeft gelezen
                  unread += 1; // Tel als ongelezen
                  continue;
                }

                for (final ar in adminReplies) {
                  // Loop door admin-replies
                  if (ar is Map) {
                    // Als reply een Map is
                    final seenBy =
                        (ar['seenBy'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        []; // Haal lijst op van gebruikers die gezien hebben
                    if (!seenBy.contains(uid)) {
                      // Als huidige gebruiker niet in gezien-lijst
                      unread += 1; // Tel als ongelezen
                      break;
                    }
                  }
                }
              }
              if (mounted)
                setState(
                  () => _cachedUnreadCustomerReplies = unread,
                ); // Update ongelezen-counter
            } catch (e) {
              debugPrint(
                'Failed to compute unread count in HomeScreen: $e',
              ); // Log fout
            }
          },
          onError: (e) {
            debugPrint(
              'customerquestions listen error (home): $e',
            ); // Log abonnementsfout
          },
        );
  }

  @override
  void dispose() {
    // Schoonmaak bij verwijdering van widget
    _pageController.dispose(); // Verwijder PageController
    _authSub?.cancel(); // Zeg authenticatie-abonnement op
    _customerQuestionsSub?.cancel(); // Zeg klantenvragen-abonnement op
    _allCustomerQuestionsSub?.cancel(); // Zeg alle-klantenvragen-abonnement op
    super.dispose();
  }

  Future<void> _loadNowPlaying() async {
    // Laad hudig speelende films van API
    try {
      final uri = Uri.parse(baseApi).replace(
        queryParameters: {
          'type': 'actualfilms',
          'page': '1',
          'language': 'nl-NL',
          'region': 'NL',
        },
      ); // Bouw API-URL met parameters
      final resp = await http.get(uri); // Verstuur GET-verzoek
      if (resp.statusCode == 200) {
        // Als verzoek succesvol is
        final jsonData = jsonDecode(resp.body); // Decodeer JSON-antwoord
        final results =
            (jsonData['results'] as List<dynamic>?) ?? []; // Haal resultaten op
        final temp = <FilmNowItem>[]; // Maak tijdelijke filmlijst

        for (final r in results) {
          // Loop door alle filmresultaten
          final map = r as Map<String, dynamic>;
          temp.add(
            FilmNowItem(
              tmdbId: map['id'].toString(),
              title: map['title'] ?? map['original_title'],
              poster: map['poster_path'] != null
                  ? 'https://image.tmdb.org/t/p/w500${map['poster_path']}'
                  : null,
              backdrop: map['backdrop_path'] != null
                  ? 'https://image.tmdb.org/t/p/original${map['backdrop_path']}'
                  : null,
            ),
          ); // Voeg film toe aan lijst
        }

        setState(() {
          films = temp;
          loadingFilms = false;
        }); // Update state met films en zet laden op false

        for (var item in films) {
          // Loop door alle films
          _fetchImdbIdFor(item); // Haal IMDB ID op voor elke film
        }
      }
    } catch (e) {
      debugPrint('Error: $e'); // Log fout
      setState(() => loadingFilms = false); // Zet laden op false
    }
  }

  Future<void> _fetchImdbIdFor(FilmNowItem item) async {
    // Haal IMDB ID op voor een film
    try {
      final uri = Uri.parse(baseApi).replace(
        queryParameters: {'type': 'tmdbmovieinfo', 'movie_id': item.tmdbId},
      ); // Bouw API-URL voor filmdetails
      final resp = await http.get(uri); // Verstuur GET-verzoek
      if (resp.statusCode == 200) {
        // Als verzoek succesvol is
        final data = jsonDecode(resp.body); // Decodeer JSON-antwoord
        item.imdbId = data['imdb_id']; // Zet IMDB ID
      }
    } catch (_) {}
  }

  String proxiedUrl(String url) =>
      '$baseApi?type=image-proxy&imageUrl=${Uri.encodeComponent(url)}'; // Bouw proxy-URL voor afbeeldingen

  Future<void> _ensureDisplayName() async {
    // Zorg ervoor dat gebruiker een displaynaam heeft
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Stop als geen gebruiker ingelogd is
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(); // Haal gebruikersdocument op
    var data = doc.data();

    if (data == null &&
        user.displayName != null &&
        user.displayName!.trim().isNotEmpty) {
      // Als doc niet bestaat maar gebruiker heeft displaynaam
      debugPrint(
        'ensureDisplayName: doc null but user.displayName found. Creating doc.',
      );
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Maak gebruikersdoc aan
      data = {'displayName': user.displayName};
    }

    debugPrint(
      'ensureDisplayName: uid=${user.uid}, userdoc=${data ?? '<null>'}',
    );

    final dynamic rawName = data == null
        ? null
        : (data['displayName'] ??
              data['display_name'] ??
              data['name']); // Haal displaynaam op
    if (rawName is String && rawName.trim().isNotEmpty)
      return; // Stop als displaynaam bestaat
    await _promptForDisplayName(user.uid); // Vraag om displaynaam
  }

  Future<void> _promptForDisplayName(String uid) async {
    // Toon dialoog om displaynaam in te voeren
    final formKey = GlobalKey<FormState>();
    final ctrl = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final loc = AppLocalizations.of(ctx)!;
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(loc.changeNameTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.enter_name_description),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: ctrl,
                    autofocus: true,
                    decoration: InputDecoration(labelText: loc.nameLabel),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return loc.nameValidation;
                      return null;
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Bij klikken op knop
                  if (!formKey.currentState!.validate())
                    return; // Valideer form
                  final name = ctrl.text.trim();
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Als gebruiker ingelogd is
                      await user.updateDisplayName(
                        name,
                      ); // Update displaynaam in Auth
                      await user.reload(); // Herlaad gebruikersgegevens
                    }
                    final usersRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid);
                    await usersRef.set(
                      {
                        'displayName': name,
                        'email': user?.email,
                        'updatedAt': FieldValue.serverTimestamp(),
                      },
                      SetOptions(merge: true),
                    ); // Update displaynaam in Firestore
                  } catch (e) {
                    debugPrint(
                      'Failed saving displayName from dialog: $e',
                    ); // Log fout
                  }
                  if (mounted) Navigator.of(ctx).pop(); // Sluit dialoog
                },
                child: Text(loc.save_and_continue),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _fetchUnreadCustomerReplies() async {
    // Haal aantal ongelezen replies op
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0; // Stop als geen gebruiker ingelogd is
      final uid = user.uid;
      final snap = await FirebaseFirestore.instance
          .collection('customerquestions')
          .where('userId', isEqualTo: uid)
          .get(); // Haal alle vragen van gebruiker op
      int unread = 0;
      for (final d in snap.docs) {
        // Loop door alle documenten
        final data = d.data();
        final adminReplies =
            (data['adminReplies'] as List?) ?? []; // Haal admin-replies op
        final userRead =
            data['userRead'] == true; // Controleer of gebruiker heeft gelezen

        if (!userRead) {
          // Als gebruiker niet heeft gelezen
          unread += 1; // Tel als ongelezen
          continue;
        }

        for (final ar in adminReplies) {
          // Loop door admin-replies
          if (ar is Map) {
            // Als reply een Map is
            final seenBy =
                (ar['seenBy'] as List?)?.map((e) => e.toString()).toList() ??
                []; // Haal lijst op van gebruikers die gezien hebben
            if (!seenBy.contains(uid)) {
              // Als huidige gebruiker niet in gezien-lijst
              unread += 1; // Tel als ongelezen
              break;
            }
          }
        }
      }
      return unread;
    } catch (e) {
      debugPrint('Failed fetching unread customer replies: $e'); // Log fout
      return 0;
    }
  }

  Future<bool> _checkIfAdmin() async {
    // Controleer of gebruiker admin is
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false; // Stop als geen gebruiker ingelogd is
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(); // Haal gebruikersdocument op
    return doc.data()?['role']?.toString().toLowerCase() ==
        'admin'; // Controleer rol
  }

  final GlobalKey _movieSliderKey = GlobalKey();

  void _checkTutorialOnInit() async {
    final prefs = await SharedPreferences.getInstance();
    final isDone = prefs.getBool('tutorial_done_home_screen') ?? false;
    if (isDone) return;

    // Als hij nog niet gedaan is, wachten we even tot de UI er is en tonen hem dan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showHomeScreenTutorial();
      });
    });
  }

  void _showHomeScreenTutorial() {
    if (!mounted) return;
    
    final l10n = L10n.of(context);
    List<TargetFocus> targets = [
      TutorialService.createTarget(
        identify: "movie-slider",
        key: _movieSliderKey,
        text: l10n?.tutorialHomeExtra ?? "Swipe door de nieuwste films in de bioscoop!",
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.RRect,
        radius: 4,
      ),
    ];

    TutorialService.checkAndShowTutorial(
      context,
      tutorialKey: 'home_screen',
      targets: targets,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Controleer of het apparaat in donkere modus is
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    // Stel tekstkleur in op wit voor donker en zwart voor licht
    final textColor = isDarkMode ? Colors.white : Colors.black;
    // Haal de schermhoogte op
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        // Maak een achtergrondverloop afhankelijk van de huidige modus
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                )
              : const LinearGradient(
                  colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF)],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- BOVENBALK ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          key: MainNavigation.kaartKey,
                          icon: Icon(Icons.map_outlined, color: textColor),
                          // Navigeer naar de kaartweergave wanneer kaartpictogram wordt geklikt
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CinemasMapView(),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        // Toon de titel van de app in het midden
                        child: Text(
                          AppLocalizations.of(context)!.appTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder<bool>(
                              // Controleer of de huidige gebruiker een admin is
                              future: _checkIfAdmin(),
                              builder: (context, snap) => snap.data == true
                                  ? Stack(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.admin_panel_settings,
                                            color: Colors.amber,
                                          ),
                                          // Navigeer naar het adminscherm bij klikken
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const AdminScreen(),
                                            ),
                                          ),
                                        ),
                                        // Toon een rode badge als er ongelezen admin-chats zijn
                                        if (_cachedUnreadAdminChats > 0)
                                          Positioned(
                                            right: 6,
                                            top: 6,
                                            child: IgnorePointer(
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Center(
                                                  // Toon het aantal ongelezen chats (max 99+)
                                                  child: Text(
                                                    _cachedUnreadAdminChats > 99
                                                        ? '99+'
                                                        : '$_cachedUnreadAdminChats',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  // Toon een lege ruimte als de gebruiker geen admin is
                                  : const SizedBox(width: 48),
                            ),
                            const SizedBox(width: 8),
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.settings, color: textColor),
                                  // Navigeer naar het instellingenscherm bij klikken
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                ),
                                // Toon een rode badge als er ongelezen replies zijn
                                if (_cachedUnreadCustomerReplies > 0)
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: IgnorePointer(
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Center(
                                          // Toon het aantal ongelezen replies (max 99+)
                                          child: Text(
                                            _cachedUnreadCustomerReplies > 99
                                                ? '99+'
                                                : '$_cachedUnreadCustomerReplies',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Toon de sectietitel "Nu in bioscoop"
              Text(
                key: _movieSliderKey,
                AppLocalizations.of(context)!.nowPlayingTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 10),

              // --- DE SWIPER (FILM CARROUSEL) ---
              Expanded(
                // Toon een laadspinner als films nog laden
                child: loadingFilms
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: films.length,
                        // Update de huidige index wanneer de pagina verandert
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemBuilder: (context, index) {
                          final film = films[index];
                          // Controleer of deze film momenteel geselecteerd is
                          final isSelected = index == currentIndex;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            // Maak het formaat groter als het geselecteerd is
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: isSelected ? 20 : 50,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                // Voeg een schaduweffect toe aan de filmkaart
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GestureDetector(
                                // Navigeer naar filmdetails wanneer de kaart wordt geklikt
                                onTap: () {
                                  if (film.imdbId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MovieDetailScreen(
                                          imdbId: film.imdbId!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Laad de filmaffiche via de proxy-URL
                                    Image.network(
                                      proxiedUrl(film.poster ?? ""),
                                      fit: BoxFit.cover,
                                      // Toon een grijze container als de afbeelding niet kan laden
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey),
                                    ),
                                    // Titel overlay
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(15),
                                        // Maak een verloop van zwart naar transparant aan de onderkant
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.8),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        // Toon de filmtitel in het midden onderin
                                        child: Text(
                                          film.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // --- DOT INDICATOR ---
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 30,
                ),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    // Bereken welke stip we aanraken op basis van de scroll-positie
                    final RenderBox box = context.findRenderObject() as RenderBox;
                    final localOffset = box.globalToLocal(details.globalPosition);
                    final double x = localOffset.dx;
                    final double screenWidth = MediaQuery.of(context).size.width;
                    
                    // We schalen de drag over de breedte van het scherm naar de lijst met films
                    final double relativePos = (x / screenWidth).clamp(0.0, 1.0);
                    final int targetIndex = (relativePos * (films.length - 1)).round();
                    
                    if (targetIndex != currentIndex) {
                      _pageController.jumpToPage(targetIndex);
                    }
                  },
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      // Genereer een punt voor elke film
                      children: List.generate(
                        films.length,
                        (i) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            // Maak het geselecteerde punt groter
                            width: i == currentIndex ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              // Maak het geselecteerde punt blauw en andere grijs
                              color: i == currentIndex
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

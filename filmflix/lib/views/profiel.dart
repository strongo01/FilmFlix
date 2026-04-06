import 'dart:async'; // Importeert async-functionaliteit voor streams

import 'package:cinetrackr/l10n/app_localizations.dart'; // Importeert multi-language ondersteuning
import 'package:flutter/material.dart'; // Importeert Flutter UI-framework
import 'package:firebase_core/firebase_core.dart'; // Importeert Firebase initialisatie
import 'package:firebase_auth/firebase_auth.dart'; // Importeert Firebase authenticatie
import 'package:cloud_firestore/cloud_firestore.dart'; // Importeert Firestore database
import '../firebase_options.dart'; // Importeert Firebase configuratie
import 'loginscreen.dart'; // Importeert login scherm
import 'settingscreen.dart'; // Importeert instellingen scherm
import 'package:cinetrackr/widgets/app_background.dart'; // Importeert achtergrond widget
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeert top navigatie bar

void main() => runApp(
  const MaterialApp(home: ProfileScreen()),
); // Start app met ProfileScreen als thuisscherm

class ProfileScreen extends StatefulWidget {
  // Definieert ProfileScreen widget die state ondersteunt
  const ProfileScreen({super.key}); // Constructor met optionele key parameter

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // Maakt state object aan
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Implementatie van ProfileScreen state
  StreamSubscription<User?>?
  _authSub; // Subscription op Firebase authentication wijzigingen
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userDocSub; // Subscription op gebruiker document updates
  int _watchlistCount = 0; // Aantal items in watchlist
  int _filmsCount = 0; // Aantal films in watchlist
  int _adventureCount = 0; // Aantal avontuur films
  int _horrorCount = 0; // Aantal horror/thriller films
  int _earlyBirdCount = 0; // Aantal items opgeslagen in vroege ochtend
  int _bingeCount = 0; // Aantal bingewatchings
  bool _hasAdventurerBadge = false; // Of gebruiker adventurer badge heeft
  String? _displayName; // Weergave naam van gebruiker
  bool _isLoggedIn = false; // Of gebruiker ingelogd is
  Color? _avatarColor; // Achtergrond kleur van avatar
  String? _avatarEmoji; // Emoji in avatar

  @override
  void initState() {
    // Initialisatie lifecycle method
    super.initState(); // Roept parent initState aan
    _initFirebaseAndListen(); // Start Firebase listeners
  }

  void _showEditNameDialog() {
    // Toont dialoog voor naamswijziging
    final controller = TextEditingController(
      text: _displayName ?? '',
    ); // Maakt text controller met huidige naam
    final parentContext = context; // Slaat context op voor latere referentie

    showDialog<void>(
      // Toont dialoog
      context: context, // Dialogcontext
      builder: (ctx) {
        // Builder function voor dialoog inhoud
        return AlertDialog(
          // Maakt alertaindialog
          title: Text(AppLocalizations.of(ctx)!.edit_profile), // Dialoog titel
          content: TextField(
            // Tekstinvoer veld
            controller: controller, // Koppelt controller
            decoration: const InputDecoration(
              hintText: 'Voer je naam in',
            ), // Hint tekst
          ),
          actions: [
            // Dialogknoppen
            TextButton(
              // Annuleer knop
              onPressed: () => Navigator.of(ctx).pop(), // Sluit dialoog
              child: Text(AppLocalizations.of(ctx)!.cancel), // Knoptekst
            ),
            ElevatedButton(
              // Opslaan knop
              onPressed: () async {
                // Async functie voor opslaan
                final newName = controller.text
                    .trim(); // Haalt ingevulde naam op
                if (newName.isEmpty) return; // Controleert of naam niet leeg is
                final user = FirebaseAuth
                    .instance
                    .currentUser; // Haalt huige gebruiker op
                final uid = user?.uid; // Haalt gebruiker ID op
                try {
                  // Try-catch voor error handling
                  if (user != null) {
                    // Controleert of gebruiker bestaat
                    await user.updateDisplayName(
                      newName,
                    ); // Werkt displaynaam bij in Auth
                  }
                  if (uid != null) {
                    // Controleert of UID beschikbaar is
                    await FirebaseFirestore
                        .instance // Firestore instance
                        .collection('users') // Users collectie
                        .doc(uid) // Gebruiker document
                        .set({
                          'displayName': newName,
                        }, SetOptions(merge: true)); // Slaat naam op met merge
                  }
                  if (mounted) {
                    // Controleert of widget nog actief is
                    setState(() {
                      // Werkt lokale state bij
                      _displayName = newName; // Werkt weergave naam bij
                    });
                  }
                } catch (e) {
                  // Error handler
                  final l10n = AppLocalizations.of(parentContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    // Toont foutmelding
                    SnackBar(
                      content: Text(
                        l10n?.save_failed ?? 'Opslaan mislukt',
                      ),
                    ), // Foutbericht
                  );
                }
                if (mounted) Navigator.of(ctx).pop(); // Sluit dialoog
              },
              child: Text(AppLocalizations.of(ctx)!.save), // Knoptekst
            ),
          ],
        );
      },
    );
  }

  Future<void> _initFirebaseAndListen() async {
    // Initialiseert Firebase en start listeners
    try {
      // Try-catch voor init errors
      if (Firebase.apps.isEmpty) {
        // Controleert of Firebase nog niet is geinitialiseerd
        await Firebase.initializeApp(
          // Initialiseert Firebase
          options: DefaultFirebaseOptions
              .currentPlatform, // Platform-specifieke instellingen
        );
      }
    } catch (e) {
      // Error handling
      // ignore init errors here; app may already be initialized elsewhere
    }

    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Luistert naar auth wijzigingen
      _userDocSub?.cancel(); // Canceld vorige document listener
      if (user != null) {
        // Controleert of gebruiker ingelogd is
        _isLoggedIn = true; // Zet login status
        _displayName = user.displayName; // Haalt naam uit auth op
        _userDocSub = FirebaseFirestore
            .instance // Maakt document listener
            .collection('users') // Users collectie
            .doc(user.uid) // Gebruiker document
            .snapshots() // Luistert naar wijzigingen
            .listen((snap) {
              // Callback bij wijzigingen
              final data = snap.data() ?? {}; // Haalt document data op
              final watchlist =
                  (data['watchlist'] is List) // Controleert watchlist type
                  ? List.from(data['watchlist']) // Converteert naar List
                  : <dynamic>[]; // Fallback lege list

              int films = 0; // Teller voor films
              int adventures = 0; // Teller voor avonturen
              int horrors = 0; // Teller voor horror/thriller
              int earlyBirds = 0; // Teller voor vroeg spaarders
              final List<DateTime> allSaved =
                  []; // Lijst van alle save timestamps
              bool _metaHasAdventure(Map m) {
                // Helper functie voor avontuur genre check
                try {
                  // Try-catch voor genre parsing
                  final genres =
                      m['genres'] ??
                      m['genre'] ??
                      m['genre_names']; // Haalt genre field op
                  if (genres is List) {
                    // Controleert of genres een list is
                    for (final g in genres) {
                      // Loopt door genres
                      if (g is String) {
                        // Controleert of genre een string is
                        if (g.toLowerCase().contains('advent'))
                          return true; // Zoekt 'advent' in lopende tekst
                      } else if (g is Map) {
                        // Controleert of genre een map is
                        final name =
                            g['name'] ?? g['genre']; // Haalt genre naam op
                        if (name is String && // Controleert string type
                            name.toLowerCase().contains(
                              'advent',
                            )) // Zoekt 'advent'
                          return true; // Retourneert true als gevonden
                      }
                    }
                  }
                } catch (_) {} // Negeer genre parse errors
                return false; // Retourneert false als niet gevonden
              }

              bool _metaHasHorrorThriller(Map m) {
                // Helper functie voor horror/thriller check
                try {
                  // Try-catch voor genre parsing
                  final genres =
                      m['genres'] ??
                      m['genre'] ??
                      m['genre_names']; // Haalt genre field op
                  if (genres is List) {
                    // Controleert of genres een list is
                    for (final g in genres) {
                      // Loopt door genres
                      if (g is String) {
                        // Controleert of genre een string is
                        final lower = g.toLowerCase(); // Zet naar lowercase
                        if (lower.contains('horror') || // Zoekt 'horror'
                            lower.contains('thriller')) // Of 'thriller'
                          return true; // Retourneert true als gevonden
                      } else if (g is Map) {
                        // Controleert of genre een map is
                        final name =
                            g['name'] ?? g['genre']; // Haalt genre naam op
                        if (name is String) {
                          // Controleert string type
                          final lower = name
                              .toLowerCase(); // Zet naar lowercase
                          if (lower.contains('horror') || // Zoekt 'horror'
                              lower.contains('thriller')) // Of 'thriller'
                            return true; // Retourneert true als gevonden
                        }
                      }
                    }
                  }
                } catch (_) {} // Negeer genre parse errors
                return false; // Retourneert false als niet gevonden
              }

              try {
                // Try-catch voor watchlist verwerking
                final wm =
                    data['watchlist_meta']; // Haalt watchlist metadata op
                if (wm is Map) {
                  // Controleert of metadata een map is
                  for (final v in wm.values) {
                    // Loopt door alle values
                    if (v is Map) {
                      // Controleert of value een map is
                      final mt = v['mediaType']; // Haalt media type op
                      if (mt != null &&
                          mt.toString().toLowerCase() ==
                              'movie') // Controleert of het een film is
                        films += 1; // Telt film
                      if (_metaHasAdventure(v))
                        adventures += 1; // Telt avontuur
                      if (_metaHasHorrorThriller(v))
                        horrors += 1; // Telt horror
                      try {
                        // Try-catch voor timestamp parsing
                        final saved = v['savedAt']; // Haalt save timestamp op
                        DateTime? dt; // Variabele voor parsed datetime
                        if (saved
                            is Timestamp) // Controleert of Firestore timestamp
                          dt = saved.toDate(); // Converteert naar datetime
                        else if (saved
                            is DateTime) // Controleert of al datetime
                          dt = saved; // Gebruikt direct
                        else if (saved is String) // Controleert of string
                          dt = DateTime.tryParse(
                            saved,
                          ); // Parsed string naar datetime
                        if (dt != null) {
                          // Controleert of datetime geldig is
                          final h = dt
                              .toLocal()
                              .hour; // Haalt uur op in lokale tijd
                          if (h >= 0 && h < 6)
                            earlyBirds += 1; // Telt als nachtuil
                        }
                      } catch (_) {} // Negeer timestamp errors
                      try {
                        // Try-catch voor allSaved verzameling
                        final saved = v['savedAt']; // Haalt save timestamp op
                        DateTime? dt; // Variabele voor parsed datetime
                        if (saved
                            is Timestamp) // Controleert of Firestore timestamp
                          dt = saved.toDate(); // Converteert naar datetime
                        else if (saved
                            is DateTime) // Controleert of al datetime
                          dt = saved; // Gebruikt direct
                        else if (saved is String) // Controleert of string
                          dt = DateTime.tryParse(
                            saved,
                          ); // Parsed string naar datetime
                        if (dt != null)
                          allSaved.add(dt.toUtc()); // Voegt UTC timestamp toe
                      } catch (_) {} // Negeer timestamp errors
                    } else if (v is List) {
                      // Controleert of value een list is
                      final hasMovie = v.any(
                        // Controleert of list film bevat
                        (e) => // Voor elk element
                            e is Map && // Controleert of map
                            e['mediaType'] !=
                                null && // Controleert media type bestaat
                            e['mediaType'].toString().toLowerCase() ==
                                'movie', // Controleert of film
                      );
                      if (hasMovie) films += 1; // Telt film
                      final hasAdv = v.any(
                        // Controleert of list avontuur bevat
                        (e) =>
                            e is Map &&
                            _metaHasAdventure(e), // Controleert avontuur helper
                      );
                      if (hasAdv) adventures += 1; // Telt avontuur
                      final hasH = v.any(
                        // Controleert of list horror bevat
                        (e) =>
                            e is Map &&
                            _metaHasHorrorThriller(
                              e,
                            ), // Controleert horror helper
                      );
                      if (hasH) horrors += 1; // Telt horror
                      try {
                        // Try-catch voor list element parsing
                        for (final e in v) {
                          // Loopt door list elementen
                          if (e is Map) {
                            // Controleert of element een map is
                            final saved =
                                e['savedAt']; // Haalt save timestamp op
                            DateTime? dt; // Variabele voor parsed datetime
                            if (saved
                                is Timestamp) // Controleert of Firestore timestamp
                              dt = saved.toDate(); // Converteert naar datetime
                            else if (saved
                                is DateTime) // Controleert of al datetime
                              dt = saved; // Gebruikt direct
                            else if (saved is String) // Controleert of string
                              dt = DateTime.tryParse(
                                saved,
                              ); // Parsed string naar datetime
                            if (dt != null) {
                              // Controleert of datetime geldig is
                              final h = dt
                                  .toLocal()
                                  .hour; // Haalt uur op in lokale tijd
                              if (h >= 0 && h < 6) {
                                // Controleert of vroeg in morgen
                                earlyBirds += 1; // Telt nachtuil
                                break; // Stopt looping na eerste match
                              }
                            }
                            final mt2 = e['mediaType']; // Haalt media type op
                            final mtStr2 =
                                mt2?.toString().toLowerCase() ??
                                ''; // Converteert naar lowercase string
                            if (dt != null)
                              allSaved.add(
                                dt.toUtc(),
                              ); // Voegt UTC timestamp toe
                          }
                        }
                      } catch (_) {} // Negeer list parsing errors
                    }
                  }
                } else {
                  // Fallback als metadata geen map is
                  for (final entry in data.entries) {
                    // Loopt door alle velden
                    final k = entry.key as String; // Haalt veld naam op
                    final v = entry.value; // Haalt veld waarde op
                    if (k.startsWith('watchlist_meta')) {
                      // Controleert of veld watchlist_meta is
                      if (v is Map) {
                        // Controleert of value een map is
                        final mt = v['mediaType']; // Haalt media type op
                        if (mt != null && // Controleert of media type bestaat
                            mt.toString().toLowerCase() ==
                                'movie') // Controleert of film
                          films += 1; // Telt film
                        if (_metaHasAdventure(v))
                          adventures += 1; // Telt avontuur
                        if (_metaHasHorrorThriller(v))
                          horrors += 1; // Telt horror
                        try {
                          // Try-catch voor timestamp parsing
                          final saved = v['savedAt']; // Haalt save timestamp op
                          DateTime? dt; // Variabele voor parsed datetime
                          if (saved
                              is Timestamp) // Controleert of Firestore timestamp
                            dt = saved.toDate(); // Converteert naar datetime
                          else if (saved
                              is DateTime) // Controleert of al datetime
                            dt = saved; // Gebruikt direct
                          else if (saved is String) // Controleert of string
                            dt = DateTime.tryParse(
                              saved,
                            ); // Parsed string naar datetime
                          if (dt != null) {
                            // Controleert of datetime geldig is
                            final h = dt
                                .toLocal()
                                .hour; // Haalt uur op in lokale tijd
                            if (h >= 0 && h < 6)
                              earlyBirds += 1; // Telt nachtuil
                          }
                        } catch (_) {} // Negeer timestamp errors
                        try {
                          // Try-catch voor allSaved verzameling
                          final saved = v['savedAt']; // Haalt save timestamp op
                          DateTime? dt; // Variabele voor parsed datetime
                          if (saved
                              is Timestamp) // Controleert of Firestore timestamp
                            dt = saved.toDate(); // Converteert naar datetime
                          else if (saved
                              is DateTime) // Controleert of al datetime
                            dt = saved; // Gebruikt direct
                          else if (saved is String) // Controleert of string
                            dt = DateTime.tryParse(
                              saved,
                            ); // Parsed string naar datetime
                          if (dt != null)
                            allSaved.add(dt.toUtc()); // Voegt UTC timestamp toe
                        } catch (_) {} // Negeer timestamp errors
                      } else if (v is List) {
                        // Controleert of value een list is
                        final hasMovie = v.any(
                          // Controleert of list film bevat
                          (e) => // Voor elk element
                              e is Map && // Controleert of map
                              e['mediaType'] !=
                                  null && // Controleert media type bestaat
                              e['mediaType']
                                      .toString()
                                      .toLowerCase() == // Converteert naar lowercase
                                  'movie', // Controleert of film
                        );
                        if (hasMovie) films += 1; // Telt film
                        final hasAdv = v.any(
                          // Controleert of list avontuur bevat
                          (e) =>
                              e is Map &&
                              _metaHasAdventure(
                                e,
                              ), // Controleert avontuur helper
                        );
                        if (hasAdv) adventures += 1; // Telt avontuur
                        final hasH = v.any(
                          // Controleert of list horror bevat
                          (e) =>
                              e is Map &&
                              _metaHasHorrorThriller(
                                e,
                              ), // Controleert horror helper
                        );
                        if (hasH) horrors += 1; // Telt horror
                        try {
                          // Try-catch voor list element parsing
                          for (final e in v) {
                            // Loopt door list elementen
                            if (e is Map) {
                              // Controleert of element een map is
                              final saved =
                                  e['savedAt']; // Haalt save timestamp op
                              DateTime? dt; // Variabele voor parsed datetime
                              if (saved
                                  is Timestamp) // Controleert of Firestore timestamp
                                dt = saved
                                    .toDate(); // Converteert naar datetime
                              else if (saved
                                  is DateTime) // Controleert of al datetime
                                dt = saved; // Gebruikt direct
                              else if (saved is String) // Controleert of string
                                dt = DateTime.tryParse(
                                  saved,
                                ); // Parsed string naar datetime
                              if (dt != null) {
                                // Controleert of datetime geldig is
                                final h = dt
                                    .toLocal()
                                    .hour; // Haalt uur op in lokale tijd
                                if (h >= 0 && h < 6) {
                                  // Controleert of vroeg in morgen
                                  earlyBirds += 1; // Telt nachtuil
                                  break; // Stopt looping na eerste match
                                }
                              }
                              final mt2 = e['mediaType']; // Haalt media type op
                              final mtStr2 = // Converteert naar string
                                  mt2?.toString().toLowerCase() ??
                                  ''; // Of defaultt naar lege string
                              if (dt != null)
                                allSaved.add(
                                  dt.toUtc(),
                                ); // Voegt UTC timestamp toe
                            }
                          }
                        } catch (_) {} // Negeer list parsing errors
                      }
                    }
                  }
                }
              } catch (_) {} // Negeer watchlist parsing errors

              int bingeEvents = 0; // Teller voor binge events
              try {
                // Try-catch voor binge detection
                if (allSaved.isNotEmpty) {
                  // Controleert of timestamps verzameld zijn
                  allSaved.sort(); // Sorteert timestamps chronologisch
                  int i = 0; // Loop index
                  final n = allSaved.length; // Aantal timestamps
                  while (i < n) {
                    // Loopt door alle timestamps
                    int j = i; // Start van huidge groep
                    while (j + 1 < n && // Controleert of meer elementen zijn
                        allSaved[j + 1]
                                .difference(allSaved[i])
                                .inMinutes <= // Controleert tijds verschil
                            10) {
                      // Maximaal 10 minuten
                      j++; // Gaat naar volgende element
                    }
                    if (j - i + 1 >= 2) {
                      // Controleert of minimum 2 items in groep
                      bingeEvents += 1; // Telt binge event
                      i = j + 1; // Set index na groep
                    } else {
                      // Als groep kleiner dan 2
                      i += 1; // Gaat naar volgende element
                    }
                  }
                }
              } catch (_) {} // Negeer binge detection errors

              setState(() {
                // Werkt UI state bij
                _watchlistCount = watchlist.length; // Zet watchlist teller
                _filmsCount = films; // Zet film teller
                _adventureCount = adventures; // Zet avontuur teller
                _horrorCount = horrors; // Zet horror teller
                _earlyBirdCount = earlyBirds; // Zet nachtuil teller
                _bingeCount = bingeEvents; // Zet binge teller
                _hasAdventurerBadge =
                    adventures > 10; // Controleert avontuur badge
                _displayName =
                    (data['displayName'] as String?) ??
                    _displayName; // Werkt display naam bij
                try {
                  // Try-catch voor avatar parsing
                  final avatar =
                      data['profileAvatar'] ??
                      data['avatar']; // Haalt avatar data op
                  if (avatar is Map) {
                    // Controleert of avatar een map is
                    final emoji = avatar['emoji'] as String?; // Haalt emoji op
                    final colorStr =
                        avatar['color'] as String?; // Haalt kleur string op
                    _avatarEmoji = emoji; // Zet avatar emoji
                    if (colorStr is String && colorStr.isNotEmpty) {
                      // Controleert kleur string
                      final cleaned = colorStr.replaceAll(
                        '#',
                        '',
                      ); // Verwijdert # symbool
                      final val = int.tryParse(
                        cleaned,
                        radix: 16,
                      ); // Parsed hex naar int
                      if (val != null)
                        _avatarColor = Color(
                          0xFF000000 | val,
                        ); // Zet avatar kleur
                    }
                  }
                } catch (_) {} // Negeer avatar parsing errors
              });
            });
      } else {
        // Gebruiker niet ingelogd
        setState(() {
          // Werkt UI state bij
          _isLoggedIn = false; // Zet login status
          _watchlistCount = 0; // Reset watchlist teller
          _filmsCount = 0; // Reset film teller
          _displayName = null; // Reset display naam
        });
      }
    });
  }

  @override
  void dispose() {
    // Cleanup lifecycle method
    _authSub?.cancel(); // Canceld auth subscription
    _userDocSub?.cancel(); // Canceld user document subscription
    super.dispose(); // Roept parent dispose aan
  }

  @override
  Widget build(BuildContext context) {
    // Bouwt de UI
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Controleert dark mode
    final cardColor =
        isDark // Zet kaart kleur op basis van theme
        ? const Color(0xFF1D272F)
        : const Color(0xFFFFFFFF);
    final accentColor =
        isDark // Zet accent kleur op basis van theme
        ? const Color(0xFFEBB143)
        : const Color(0xFFD4AF37);
    final primaryText = isDark
        ? Colors.white
        : Colors.black87; // Zet primaire tekst kleur
    final secondaryText = isDark
        ? Colors.white70
        : Colors.black54; // Zet secundaire tekst kleur

    return AppBackground(
      // Wrapper widget met achtergrond
      child: Scaffold(
        // Materiaalontwerp scaffold
        backgroundColor: Colors.transparent, // Transparante achtergrond
        appBar: PreferredSize(
          // Aangepaste appbar hoogte
          preferredSize: const Size.fromHeight(56), // Hoogte 56
          child: AppTopBar(
            // Aangepaste top bar
            title: AppLocalizations.of(context)!.navProfile, // Titel
            backgroundColor: Colors.transparent, // Transparante achtergrond
          ),
        ),
        body: CustomScrollView(
          // Scrollable widget met slivers
          slivers: [
            // Lijst van sliver widgets
            SliverToBoxAdapter(
              // Sliver wrapper voor reguliere widget
              child: Container(
                // Container voor header
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                ), // Verticale padding
                child: Column(
                  // Kolom layout
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center alignment
                  children: [
                    // Kinder widgets
                    Stack(
                      // Layering widget
                      alignment:
                          Alignment.bottomRight, // Align edit knop rechts onder
                      children: [
                        // Kinder widgets
                        GestureDetector(
                          // Click detector voor avatar
                          onTap: () {
                            // Callback bij tik
                            if (!_isLoggedIn) {
                              // Controleert login status
                              ScaffoldMessenger.of(context).showSnackBar(
                                // Toont snackbar
                                SnackBar(
                                  // Snackbar widget
                                  content: Text(
                                    // Bericht
                                    AppLocalizations.of(
                                      context,
                                    )!.avatar_login_prompt, // Localized text
                                  ),
                                ),
                              );
                              return; // Stop functie
                            }
                            _showAvatarEditor(); // Toont avatar editor
                          },
                          child: CircleAvatar(
                            // Outer circle
                            radius: 54, // Straal 54
                            backgroundColor: accentColor.withOpacity(
                              0.3,
                            ), // Halftransparante achterglond
                            child: CircleAvatar(
                              // Inner circle
                              radius: 50, // Straal 50
                              backgroundColor: // Zet achtergrond kleur
                                  _avatarColor ??
                                  Colors
                                      .grey
                                      .shade200, // Gebruiker kleur of default
                              child: // Zet child content
                                  _avatarEmoji !=
                                          null && // Controleert emoji bestaat
                                      _avatarEmoji!
                                          .isNotEmpty // En niet leeg is
                                  ? Text(
                                      // Toont emoji als text
                                      _avatarEmoji!, // Emoji string
                                      style: const TextStyle(
                                        fontSize: 32,
                                      ), // Grote font
                                    )
                                  : (_displayName !=
                                            null && // Controleert naam bestaat
                                        _displayName!
                                            .isNotEmpty) // En niet leeg is
                                  ? Text(
                                      // Toont naamletter
                                      _displayName! // Displaynaam
                                          .substring(0, 1) // Eerste letter
                                          .toUpperCase(), // Omzetten naar hoofdletter
                                      style: const TextStyle(
                                        fontSize: 28, // Font grootte
                                        fontWeight: FontWeight.bold, // Bold
                                      ),
                                    )
                                  : const Icon(
                                      // Toont persoon icon
                                      Icons.person, // Icon type
                                      size: 40, // Grootte
                                      color: Colors.white54, // Kleur
                                    ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          // Click detector voor edit knop
                          onTap: () {
                            // Callback bij tik
                            if (!_isLoggedIn) {
                              // Controleert login status
                              ScaffoldMessenger.of(context).showSnackBar(
                                // Toont snackbar
                                SnackBar(
                                  // Snackbar widget
                                  content: Text(
                                    // Bericht
                                    AppLocalizations.of(
                                      context,
                                    )!.avatar_login_prompt, // Localized text
                                  ),
                                ),
                              );
                              return; // Stop functie
                            }
                            _showAvatarEditor(); // Toont avatar editor
                          },
                          child: Container(
                            // Container voor knop
                            padding: const EdgeInsets.all(4), // Padding
                            decoration: BoxDecoration(
                              // Styling
                              color: accentColor, // Achtergrond kleur
                              shape: BoxShape.circle, // Circulair
                            ),
                            child: const Icon(
                              // Icon
                              Icons.edit, // Edit icon
                              size: 20, // Grootte
                              color: Colors.black, // Kleur
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), // Verticale spacer
                    GestureDetector(
                      // Click detector voor naam
                      onTap: () {
                        // Callback bij tik
                        if (!_isLoggedIn) {
                          // Controleert login status
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Toont snackbar
                            SnackBar(
                              // Snackbar widget
                              content: Text(
                                // Bericht
                                AppLocalizations.of(
                                  context,
                                )!.avatar_login_prompt, // Localized text
                              ),
                            ),
                          );
                          return; // Stop functie
                        }
                        _showEditNameDialog(); // Toont naam edit dialoog
                      },
                      child: Text(
                        // Tekst widget
                        _displayName ??
                            AppLocalizations.of(
                              context,
                            )!.profile_default_name, // Displaynaam of default
                        style: TextStyle(
                          // Styling
                          color: primaryText, // Primaire kleur
                          fontSize: 24, // Grootte
                          fontWeight: FontWeight.bold, // Bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              // Sliver wrapper voor reguliere widget
              child: Padding(
                // Padding wrapper
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ), // Horizontale padding
                child: Column(
                  // Kolom layout
                  crossAxisAlignment: CrossAxisAlignment.start, // Align links
                  children: [
                    // Kinder widgets
                    Row(
                      // Rij layout
                      children: [
                        // Kinder widgets
                        _buildQuickStat(
                          // Roept quick stat builder aan
                          context, // Context
                          _isLoggedIn
                              ? _filmsCount.toString()
                              : '-', // Film teller of dash
                          AppLocalizations.of(context)!.films, // Label
                          accentColor, // Kleur
                        ),
                        _buildQuickStat(
                          // Roept quick stat builder aan
                          context, // Context
                          _isLoggedIn
                              ? _watchlistCount.toString()
                              : '-', // Watchlist teller of dash
                          AppLocalizations.of(
                            context,
                          )!.watchlist_label, // Label
                          Colors.blueAccent, // Kleur
                        ),
                      ],
                    ),
                    const SizedBox(height: 32), // Verticale spacer

                    Text(
                      // Badges sectie label
                      AppLocalizations.of(
                        context,
                      )!.your_badges, // Localized text
                      style: TextStyle(
                        // Styling
                        color: secondaryText, // Secundaire kleur
                        fontSize: 12, // Grootte
                        fontWeight: FontWeight.bold, // Bold
                        letterSpacing: 1.2, // Spatiering
                      ),
                    ),
                    const SizedBox(height: 12), // Verticale spacer
                    SizedBox(
                      // Sized container
                      height: 120, // Hoogte 120
                      child: ListView(
                        // Horizontale list view
                        scrollDirection:
                            Axis.horizontal, // Horizontaal scrollen
                        children: [
                          // Kinder widgets
                          _buildBadge(
                            // Roept badge builder aan
                            context, // Context
                            AppLocalizations.of(
                              context,
                            )!.badge_adventurer, // Label
                            Icons.explore, // Icon
                            Colors.greenAccent, // Kleur
                            count: _adventureCount, // Adventure teller
                            levelBase: 10, // Level basis
                          ),
                          _buildBadge(
                            // Roept badge builder aan
                            context, // Context
                            AppLocalizations.of(
                              context,
                            )!.badge_horror_king, // Label
                            Icons.auto_awesome, // Icon
                            Colors.purpleAccent, // Kleur
                            count: _horrorCount, // Horror teller
                            levelBase: 10, // Level basis
                          ),
                          _buildBadge(
                            // Roept badge builder aan
                            context, // Context
                            AppLocalizations.of(
                              context,
                            )!.badge_binge_watcher, // Label
                            Icons.bolt, // Icon
                            Colors.orangeAccent, // Kleur
                            count: _bingeCount, // Binge teller
                            levelBase: 10, // Level basis
                          ),
                          _buildBadge(
                            // Roept badge builder aan
                            context, // Context
                            AppLocalizations.of(
                              context,
                            )!.badge_early_bird, // Label
                            Icons.wb_sunny, // Icon
                            Colors.yellowAccent, // Kleur
                            count: _earlyBirdCount, // Early bird teller
                            levelBase: 10, // Level basis
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32), // Verticale spacer
                    Text(
                      // Account sectie label
                      AppLocalizations.of(
                        context,
                      )!.account_section, // Localized text
                      style: TextStyle(
                        // Styling
                        color: secondaryText, // Secundaire kleur
                        fontSize: 12, // Grootte
                        fontWeight: FontWeight.bold, // Bold
                        letterSpacing: 1.2, // Spatiering
                      ),
                    ),
                    const SizedBox(height: 12), // Verticale spacer
                    _buildMenuTile(
                      // Roept menu builder aan
                      context, // Context
                      Icons.settings_outlined, // Settings icon
                      AppLocalizations.of(context)!.settingsTitle, // Label
                      cardColor, // Achtergrond kleur
                      onTap: () {
                        // Callback bij tik
                        Navigator.of(context).push(
                          // Push route
                          MaterialPageRoute(
                            // Materiaal route
                            builder: (_) =>
                                const SettingsScreen(), // Settings screen
                          ),
                        );
                      },
                    ),
                    if (_isLoggedIn) // Controleert login status
                      _buildMenuTile(
                        // Roept menu builder aan
                        context, // Context
                        Icons.logout, // Logout icon
                        AppLocalizations.of(context)!.logout, // Label
                        cardColor, // Achtergrond kleur
                        isDestructive: true, // Destructief label
                        onTap: () async {
                          // Async callback
                          await FirebaseAuth.instance.signOut(); // Logout
                          if (!mounted)
                            return; // Controleert widget mount status
                          Navigator.of(context).pushReplacement(
                            // Push replacement route
                            MaterialPageRoute(
                              // Materiaal route
                              builder: (_) =>
                                  const LoginScreen(), // Login screen
                            ),
                          );
                        },
                      )
                    else // User is niet ingelogd
                      _buildMenuTile(
                        // Roept menu builder aan
                        context, // Context
                        Icons.login, // Login icon
                        AppLocalizations.of(context)!.loginIn, // Label
                        cardColor, // Achtergrond kleur
                        onTap: () {
                          // Callback bij tik
                          Navigator.of(context).push(
                            // Push route
                            MaterialPageRoute(
                              // Materiaal route
                              builder: (_) =>
                                  const LoginScreen(), // Login screen
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 30), // Verticale spacer
                    Center(
                      // Centered widget
                      child: Text(
                        // Versie tekst
                        AppLocalizations.of(
                          context,
                        )!.appVersion, // Localized text
                        style: TextStyle(
                          // Styling
                          color: primaryText.withOpacity(0.1), // Menu kleur
                          fontSize: 12, // Grootte
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Verticale spacer
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toont een bottom sheet voor avatar-aanpassing en slaat keuze op in Firestore.
  void _showAvatarEditor() {
    // Definieert de methode om de avatar-editor te openen.
    bool _isOnlyEmoji(String s) {
      // Controleert of een string uitsluitend emoji bevat.
      if (s.isEmpty)
        return false; // Retourneer false wanneer de invoer leeg is.
      final re = RegExp(
        // Maakt een reguliere expressie die emoji-range matcht.
        r'^[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}\u{FE0F}\u{200D}]+$',
        unicode: true, // Geeft aan dat de regex Unicode-escapes gebruikt.
      );
      try {
        return re.hasMatch(s); // Test of de string alleen uit emoji bestaat.
      } catch (_) {
        return false; // Bij fout in regex of matching: false teruggeven.
      }
    }

    final presetColors = [
      // Lijst met vooraf gekozen kleuren voor de avatar.
      Colors.redAccent, // Rode accentkleur toevoegen.
      Colors.orangeAccent, // Oranje accentkleur toevoegen.
      Colors.yellowAccent, // Gele accentkleur toevoegen.
      Colors.greenAccent, // Groene accentkleur toevoegen.
      Colors.blueAccent, // Blauwe accentkleur toevoegen.
      Colors.purpleAccent, // Paarse accentkleur toevoegen.
      Colors.brown, // Bruine kleur toevoegen.
      Colors.grey, // Grijze kleur toevoegen.
    ];
    final emojis = [
      // Lijst met beschikbare emoji's voor de avatar.
      '😀', // Emoji optie 1: glimlachend gezicht.
      '😎', // Emoji optie 2: cool gezicht.
      '🤓', // Emoji optie 3: nerd gezicht.
      '🥳', // Emoji optie 4: feestend gezicht.
      '🤠', // Emoji optie 5: cowboy gezicht.
      '😇', // Emoji optie 6: engelachtig gezicht.
      '🧐', // Emoji optie 7: onderzoekend gezicht.
      '🙂', // Emoji optie 8: neutraal glimlach.

      '🎬', // Emoji optie film 1.
      '🍿', // Emoji optie film 2.
      '🎥', // Emoji optie film 3.
      '📽️', // Emoji optie film 4.
      '🎞️', // Emoji optie film 5.
      '⭐️', // Emoji optie ster.
      '🎭', // Emoji optie theatermasker.
      '🎟️', // Emoji optie ticket.

      '😂', // Emoji optie lachend met tranen.
      '😍', // Emoji optie verliefd gezicht.
      '😅', // Emoji optie opgeluchte lach.
      '😭', // Emoji optie huilend gezicht.
      '🤩', // Emoji optie sterogen.
      '🤯', // Emoji optie mind-blown.
      '😴', // Emoji optie slaperig.
      '🤢', // Emoji optie misselijk.
      '🤕', // Emoji optie gewond/met verband.
      '🤡', // Emoji optie clown.

      '✨', // Emoji optie fonkeling.
      '💫', // Emoji optie duizeligheid.
      '🔥', // Emoji optie vuur.
      '🌟', // Emoji optie sterretje.
      '🎉', // Emoji optie confetti.
      '🎊', // Emoji optie feest.
      '🎵', // Emoji optie muzieknoot.
      '🎶', // Emoji optie meerdere noten.
    ];
    Color selectedColor =
        _avatarColor ??
        Colors.grey.shade300; // Initieer geselecteerde kleur of fallback.
    String? selectedEmoji =
        _avatarEmoji; // Initieer geselecteerde emoji van state.
    final TextEditingController emojiController = TextEditingController(
      text:
          selectedEmoji, // Zet controller-tekst naar huidige geselecteerde emoji.
    );

    final parentContext = context; // Bewaar parent context voor dialooggebruik.
    final rootMessenger = ScaffoldMessenger.of(
      parentContext,
    ); // Haal ScaffoldMessenger op voor notificaties.

    showModalBottomSheet<void>(
      // Open een modal bottom sheet.
      context: context, // Gebruik de huidige BuildContext.
      isScrollControlled: true, // Laat de sheet scroll-gevoelig gedrag toe.
      builder: (ctx) {
        return StatefulBuilder(
          // Gebruik StatefulBuilder om lokale state te kunnen bijwerken.
          builder: (BuildContext context, StateSetter setModalState) {
            final bottomInset = MediaQuery.of(
              ctx,
            ).viewInsets.bottom; // Bepaal toetsenbord-inset onderaan.
            return Padding(
              padding: EdgeInsets.only(
                bottom: bottomInset,
              ), // Voeg padding toe voor het toetsenbord.
              child: SingleChildScrollView(
                // Zorg dat inhoud scrollbaar is indien nodig.
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(ctx).size.height *
                        0.9, // Beperk maximale hoogte tot 90% van scherm.
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      16.0,
                    ), // Globale padding binnen de sheet.
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // Kolom neemt minimale hoogte in.
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align links binnen kolom.
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.edit_avatar_title, // Toont de titel uit lokalisatie.
                          style: const TextStyle(
                            fontSize: 16, // Zet lettergrootte op 16.
                            fontWeight:
                                FontWeight.bold, // Maak tekst vetgedrukt.
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Plaats verticale ruimte van 12.
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.choose_color, // Toont tekst voor kleurkeuze uit lokalisatie.
                          style: const TextStyle(
                            fontSize: 13,
                          ), // Zet fontgrootte op 13.
                        ),
                        const SizedBox(
                          height: 8,
                        ), // Plaats verticale ruimte van 8.
                        Wrap(
                          spacing:
                              8, // Horizontale ruimte tussen items in wrap.
                          runSpacing:
                              8, // Verticale ruimte tussen rijen in wrap.
                          children: [
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedColor = Colors
                                      .grey
                                      .shade200; // Reset kleur naar lichtgrijs bij tap.
                                });
                              },
                              child: Container(
                                width: 44, // Zet breedte van de reset-knop.
                                height: 44, // Zet hoogte van de reset-knop.
                                decoration: BoxDecoration(
                                  color: Colors.white, // Achtergrondkleur wit.
                                  shape:
                                      BoxShape.circle, // Maak container rond.
                                  border:
                                      selectedColor.value ==
                                          Colors.grey.shade200.value
                                      ? Border.all(
                                          color: Colors
                                              .black, // Zwarte rand wanneer geselecteerd.
                                          width: 2, // Randdikte 2.
                                        )
                                      : Border.all(
                                          color: Colors.grey.shade300,
                                        ), // Anders subtiele grijze rand.
                                ),
                                child: const Icon(
                                  Icons
                                      .refresh, // Toon refresh-icoon in de container.
                                  size: 20, // Icoongrootte 20.
                                  color: Colors.grey, // Icoon kleur grijs.
                                ),
                              ),
                            ),
                            ...presetColors.map((c) {
                              final isSelected =
                                  c.value ==
                                  selectedColor
                                      .value; // Check of deze kleur geselecteerd is.
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedColor =
                                        c; // Stel geselecteerde kleur in bij tap.
                                  });
                                },
                                child: Container(
                                  width: 44, // Breedte van kleurselectiecirkel.
                                  height: 44, // Hoogte van kleurselectiecirkel.
                                  decoration: BoxDecoration(
                                    color: c, // Vul de cirkel met deze kleur.
                                    shape:
                                        BoxShape.circle, // Maak de vorm rond.
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors
                                                .white, // Border wanneer geselecteerd.
                                            width: 3, // Borderdikte 3.
                                          )
                                        : null, // Geen border wanneer niet geselecteerd.
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Plaats verticale ruimte van 12.
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.choose_emoji_optional, // Toont lokalisatietekst voor emoji-keuze.
                          style: const TextStyle(
                            fontSize: 13,
                          ), // Stel fontgrootte 13 in.
                        ),
                        const SizedBox(
                          height: 8,
                        ), // Plaats verticale ruimte van 8.
                        // custom emoji input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller:
                                    emojiController, // Koppelt controller aan het tekstveld.
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.emoji_input_hint, // Hinttekst voor emoji-invoer.
                                  isDense:
                                      true, // Compacte weergave van het veld.
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal:
                                        12, // Horizontale padding in veld 12.
                                    vertical:
                                        10, // Verticale padding in veld 10.
                                  ),
                                ),
                                onChanged: (v) {
                                  // update preview inline but don't validate yet
                                  setModalState(() {
                                    selectedEmoji = v.trim().isEmpty
                                        ? null
                                        : v.trim(); // Werk geselecteerde emoji bij op invoer zonder validatie.
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Plaats horizontale ruimte van 8.
                            ElevatedButton(
                              onPressed: () {
                                final input = emojiController.text
                                    .trim(); // Lees en trim invoer van controller.
                                if (input.isEmpty) {
                                  setModalState(() {
                                    selectedEmoji =
                                        null; // Maak geselecteerde emoji leeg bij lege invoer.
                                    emojiController.text =
                                        ''; // Reset controller-tekst.
                                  });
                                  return; // Verlaat de knophandeling.
                                }
                                if (!_isOnlyEmoji(input)) {
                                  showDialog<void>(
                                    context:
                                        parentContext, // Gebruik parent context voor dialoog.
                                    builder: (dctx) => AlertDialog(
                                      title: Text(
                                        AppLocalizations.of(
                                          parentContext,
                                        )!.invalid_input,
                                      ), // Titel bij ongeldige invoer.
                                      content: Text(
                                        AppLocalizations.of(
                                          parentContext,
                                        )!.only_emoji_error,
                                      ), // Inhoudtekst met foutmelding.
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dctx,
                                          ).pop(), // Sluit de dialoog bij knopdruk.
                                          child: Text(
                                            AppLocalizations.of(
                                              parentContext,
                                            )!.ok,
                                          ), // Tekst van bevestigingsknop.
                                        ),
                                      ],
                                    ),
                                  );
                                  return; // Stop verdere verwerking bij fout.
                                }
                                setModalState(() {
                                  selectedEmoji =
                                      input; // Stel geselecteerde emoji in op gevalideerde invoer.
                                });
                              },
                              child: Text(
                                AppLocalizations.of(context)!.use,
                              ), // Label knop met lokalisatietekst 'use'.
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ), // Plaats verticale ruimte van 12.
                        Wrap(
                          spacing:
                              8, // Horizontale afstand tussen emoji-knoppen.
                          children: [
                            GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedEmoji =
                                      null; // Zet emoji selectie op null bij tap op close.
                                });
                              },
                              child: Container(
                                width:
                                    48, // Breedte van de 'verwijder emoji' knop.
                                height:
                                    48, // Hoogte van de 'verwijder emoji' knop.
                                alignment: Alignment
                                    .center, // Centreer inhoud binnen container.
                                decoration: BoxDecoration(
                                  color: selectedEmoji == null
                                      ? Colors.black12
                                      : Colors
                                            .transparent, // Achtergrond wanneer geen emoji geselecteerd.
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Afronding hoeken 8.
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(
                                      0.2,
                                    ), // Subtiele randkleur.
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close, // Toon close-icoon.
                                  size: 20, // Icoongrootte 20.
                                  color: Colors.grey, // Icoon kleur grijs.
                                ),
                              ),
                            ),
                            ...emojis.map((e) {
                              final isSelected =
                                  e ==
                                  selectedEmoji; // Check of deze emoji geselecteerd is.
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selectedEmoji =
                                        e; // Stel geselecteerde emoji in op deze waarde.
                                    emojiController.text =
                                        e; // Update controller-tekst met gekozen emoji.
                                  });
                                },
                                child: Container(
                                  width: 48, // Breedte van emoji-knop.
                                  height: 48, // Hoogte van emoji-knop.
                                  alignment: Alignment
                                      .center, // Centreer emoji in knop.
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black12
                                        : Colors
                                              .transparent, // Achtergrondkleur bij selectie.
                                    borderRadius: BorderRadius.circular(
                                      8,
                                    ), // Afrond hoeken.
                                  ),
                                  child: Text(
                                    e, // Toon de emoji-tekst zelf.
                                    style: const TextStyle(
                                      fontSize: 24,
                                    ), // Grote emoji-weergave.
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ), // Plaats verticale ruimte van 16.
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Plaats knoppen aan de rechterkant.
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(
                                ctx,
                              ).pop(), // Sluit de sheet bij annuleren.
                              child: Text(
                                AppLocalizations.of(ctx)!.cancel,
                              ), // Label knop 'cancel' uit lokalisatie.
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Plaats ruimte tussen knoppen.
                            ElevatedButton(
                              onPressed: () async {
                                final uid = FirebaseAuth
                                    .instance
                                    .currentUser
                                    ?.uid; // Haal huidige gebruikers-UID op.
                                if (uid == null)
                                  return; // Stop wanneer niet ingelogd.
                                final input = emojiController.text
                                    .trim(); // Lees en trim invoer opnieuw.
                                if (input.isNotEmpty && !_isOnlyEmoji(input)) {
                                  showDialog<void>(
                                    context:
                                        parentContext, // Toon fout-dialoog bij ongeldige invoer.
                                    builder: (dctx) => AlertDialog(
                                      title: Text(
                                        AppLocalizations.of(
                                          parentContext,
                                        )!.invalid_input,
                                      ), // Dialoog titel.
                                      content: Text(
                                        AppLocalizations.of(
                                          parentContext,
                                        )!.only_emoji_error,
                                      ), // Dialoog inhoud.
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(
                                            dctx,
                                          ).pop(), // Sluit fout-dialoog.
                                          child: Text(
                                            AppLocalizations.of(
                                              parentContext,
                                            )!.ok,
                                          ), // Bevestigingsknop tekst.
                                        ),
                                      ],
                                    ),
                                  );
                                  return; // Stop uitvoering bij fout.
                                }
                                final colorHex =
                                    '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Converteer kleur naar hex-string zonder alpha.
                                final docRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(
                                      uid,
                                    ); // Verwijzing naar gebruikersdocument in Firestore.
                                await docRef.set(
                                  {
                                    'profileAvatar': {
                                      'emoji': input.isEmpty
                                          ? (selectedEmoji ?? '')
                                          : input, // Sla emoji in: ingevoerde of geselecteerde waarde.
                                      'color': colorHex, // Sla hex-kleur op.
                                    },
                                  },
                                  SetOptions(merge: true),
                                ); // Merge met bestaand document in Firestore.
                                setState(() {
                                  _avatarColor =
                                      selectedColor; // Werk lokale state voor avatar-kleur bij.
                                  _avatarEmoji = input.isEmpty
                                      ? selectedEmoji
                                      : input; // Werk lokale state voor avatar-emoji bij.
                                });
                                if (mounted)
                                  Navigator.of(
                                    ctx,
                                  ).pop(); // Sluit sheet wanneer widget nog gemount is.
                              },
                              child: Text(
                                AppLocalizations.of(ctx)!.save,
                              ), // Label knop 'save' uit lokalisatie.
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ), // Plaats onderaan nog wat ruimte van 8.
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

  // Kleine stat-indicator bovenaan: toont korte statistiek in header.
  Widget _buildQuickStat(
    // Definieert een widget voor een compacte statistiek.
    BuildContext context, // BuildContext van de widget.
    String value, // De weergegeven waarde als string.
    String label, // Het bijbehorende label onder de waarde.
    Color color, // Kleur voor de indicator balkjes.
  ) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Bepaalt of theme donker is.
    final primaryText = isDark
        ? Colors.white
        : Colors.black87; // Hoofdtekstkleur afhankelijk van theme.
    final secondary = isDark
        ? Colors.white38
        : Colors.black45; // Secundaire tekstkleur afhankelijk van theme.
    return Expanded(
      // Maakt widget uitrekbaar binnen een rij.
      child: Column(
        // Rangschikt onderdelen verticaal.
        children: [
          // Begin lijst met child-widgets.
          Text(
            // Toont de waarde bovenaan.
            value, // De dynamische value-tekst.
            style: TextStyle(
              // Stijl voor de waarde-tekst.
              color: primaryText, // Gebruik de berekende primaire tekstkleur.
              fontSize: 20, // Lettergrootte 20 instellen.
              fontWeight: FontWeight.bold, // Vetgedrukte weergave.
            ),
          ),
          const SizedBox(height: 4), // Kleine verticale ruimte van 4 pixels.
          Container(
            // Smalle gekleurde indicator onder de waarde.
            height: 3, // Hoogte van de indicator 3.
            width: 20, // Breedte van de indicator 20.
            decoration: BoxDecoration(
              // Styling voor de indicator.
              color: color, // Kleur van de indicator gebaseerd op parameter.
              borderRadius: BorderRadius.circular(
                2,
              ), // Afgeronde hoeken radius 2.
            ),
          ),
          const SizedBox(height: 4), // Extra verticale ruimte van 4.
          Text(
            label,
            style: TextStyle(color: secondary, fontSize: 12),
          ), // Toont het label met secundaire kleur.
        ],
      ),
    );
  }

  // Badge Widget: maakt een badge met icon, progress en label.
  Widget _buildBadge(
    // Definieert een widget voor een badge met optionele progress.
    BuildContext context, // BuildContext voor lokalisatie en thema.
    String label, // Badge-tekst onderaan.
    IconData icon, // Icoon voor de badge.
    Color color, { // Kleuraccent voor de badge.
    double? progress, // Optionele voortgangswaarde 0..1.
    int? count, // Optionele teller voor badge-waarden.
    int levelBase = 10, // Basiswaarde per level.
    bool simpleCount = false, // Wanneer true toont alleen het aantal.
  }) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Check of theme donker is.
    final bg = isDark
        ? const Color(0xFF1D272F)
        : const Color(0xFFF2F4F6); // Achtergrondkleur van card.
    final primaryText = isDark
        ? Colors.white
        : Colors.black87; // Primaire tekstkleur.
    // Als een 'count' is opgegeven, bereken level en voortgangsfractie op basis van 'levelBase'
    int displayLevel = 1; // Initiele weergegeven level.
    int displayTotal = levelBase; // Initieel totaal voor huidige level.
    double fraction = progress ?? 0.0; // Gebruikte fractie voor progressbar.
    String counterText = ''; // Tekstweergave van de teller.
    if (count != null) {
      // Wanneer een count is meegegeven
      if (simpleCount) {
        // En simpleCount is true
        counterText = '$count'; // Simpele weergave van het aantal.
      } else {
        displayLevel =
            (count ~/ levelBase) + 1; // Bereken huidig level uit count.
        displayTotal =
            displayLevel * levelBase; // Bereken totaal voor huidige level.
        final currentLevelProgress =
            count -
            (displayLevel - 1) * levelBase; // Progress binnen huidig level.
        fraction = (currentLevelProgress / levelBase).clamp(
          0.0,
          1.0,
        ); // Normaliseer progress naar 0..1.
        counterText =
            '$count/$displayTotal'; // Formatteer teller als 'x/total'.
      }
    }

    return Container(
      // Hoofdcontainer voor de badge.
      width: 120, // Vaste breedte 120.
      margin: const EdgeInsets.only(right: 12), // Margin rechts 12.
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ), // Horizontale padding 8.
      decoration: BoxDecoration(
        // Styling van de container.
        color: bg, // Achtergrondkleur toepassen.
        borderRadius: BorderRadius.circular(16), // Randradius 16.
        border: Border.all(
          color: color.withOpacity(0.2),
        ), // Subtiele border in accentkleur.
      ),
      child: Column(
        // Plaatst badge-onderdelen verticaal.
        mainAxisAlignment: MainAxisAlignment.center, // Centreer verticaal.
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ), // Toont het icon met kleur en grootte.
          const SizedBox(height: 8), // Verticale ruimte 8.
          if (count != null) ...[
            // Wanneer count aanwezig is, toon teller/progress.
            if (simpleCount) ...[
              // Simpele tellerweergave
              Text(
                counterText, // Toont de tellertekst.
                style: TextStyle(
                  color: primaryText, // Tekstkleur instellen.
                  fontSize: 12, // Font grootte 12.
                  fontWeight: FontWeight.w800, // Dikke tekst.
                ),
              ),
              const SizedBox(height: 6), // Ruimte na simpele teller.
            ] else ...[
              // Geavanceerde weergave met progressbar
              SizedBox(
                height: 8, // Hoogte progressbar 8.
                width: 88, // Breedte progressbar 88.
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Afronding progressbar.
                  child: LinearProgressIndicator(
                    value: fraction, // Zet de progresswaarde.
                    backgroundColor: color.withOpacity(
                      0.12,
                    ), // Achtergrondkleur van bar.
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color,
                    ), // Kleur van voortgang.
                    minHeight: 8, // Minimale hoogte.
                  ),
                ),
              ),
              const SizedBox(height: 6), // Ruimte na progressbar.
              Row(
                // Rij voor teller en optioneel level-badge.
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centreer horizontaal.
                children: [
                  Text(
                    counterText, // Toont teller 'x/total'.
                    style: TextStyle(
                      color: primaryText, // Tekstkleur.
                      fontSize: 11, // Fontgrootte 11.
                      fontWeight:
                          FontWeight.w700, // Semi-gestructureerd gewicht.
                    ),
                  ),
                  if (displayLevel > 1) ...[
                    // Indien level >1, toon level-indicator.
                    const SizedBox(width: 6), // Kleine ruimte tussen elementen.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6, // Horizontale padding in level-badge.
                        vertical: 2, // Verticale padding in level-badge.
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(
                          0.12,
                        ), // Achtergrondkleur voor badge.
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Afronding badge.
                      ),
                      child: Text(
                        '${AppLocalizations.of(context)!.badge_level_prefix}$displayLevel', // Toont 'Level X' met lokalisatie.
                        style: TextStyle(
                          color: color, // Kleur van de level-tekst.
                          fontSize: 10, // Kleine tekstgrootte.
                          fontWeight:
                              FontWeight.w700, // Vetgedrukte level-tekst.
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6), // Ruimte onder de rij.
            ],
          ] else if (progress != null) ...[
            // Als geen count maar progress is gegeven
            SizedBox(
              height: 8, // Hoogte van progress-indicator.
              width: 80, // Breedte 80.
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Afronding progress.
                child: LinearProgressIndicator(
                  value: (progress.clamp(
                    0.0,
                    1.0,
                  )), // Gebruik gegeven progress binnen 0..1.
                  backgroundColor: color.withOpacity(0.12), // Achtergrondkleur.
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color,
                  ), // Voorgrondkleur van progress.
                  minHeight: 8, // Minimale hoogte.
                ),
              ),
            ),
            const SizedBox(height: 8), // Ruimte onder progress.
          ],
          Text(
            // Toont het label onderaan de badge.
            label, // De labeltekst.
            textAlign: TextAlign.center, // Centreer tekst.
            style: TextStyle(
              color: primaryText, // Gebruik primaire tekstkleur.
              fontSize: 10, // Kleine tekstgrootte 10.
              fontWeight: FontWeight.w600, // Lichte vetting.
            ),
          ),
        ],
      ),
    );
  }

  // Menu Items: bouwt een tappable menu-rij met icon en titel.
  Widget _buildMenuTile(
    // Definieert een menu-item met stijl en callback.
    BuildContext context, // Context voor thema en navigatie.
    IconData icon, // Het linkse icoon van de tile.
    String title, // Titeltekst van de tile.
    Color color, { // Achtergrondkleur van de tile.
    bool isDestructive = false, // Flag voor destructieve actie styling.
    VoidCallback? onTap, // Callback bij tikken op de tile.
  }) {
    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark; // Controleer dark mode.
    final primaryText = isDark
        ? Colors.white
        : Colors.black87; // Kies primaire tekstkleur.
    final iconColor = isDestructive
        ? Colors.redAccent
        : (isDark
              ? Colors.white70
              : Colors.black45); // Bepaal kleur van het icoon.
    final trailingColor = isDestructive
        ? Colors.redAccent.withOpacity(0.3)
        : (isDark
              ? Colors.white10
              : Colors.black12); // Kleur van trailing icoon.
    return Container(
      // Container rondom de ListTile voor styling.
      margin: const EdgeInsets.only(bottom: 8), // Onderste marge 8.
      decoration: BoxDecoration(
        // Styling achtergrond en radius.
        color: color, // Gebruik meegegeven kleur als achtergrond.
        borderRadius: BorderRadius.circular(16), // Afronding 16.
      ),
      child: ListTile(
        // Gebruik ListTile voor consistente layout.
        leading: Icon(icon, color: iconColor), // Linkericoon met kleur.
        title: Text(
          title, // Toon de titeltekst.
          style: TextStyle(
            color: isDestructive
                ? Colors.redAccent
                : primaryText, // Rood als destructief anders primair.
            fontSize: 15, // Fontgrootte 15.
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: trailingColor,
        ), // Rechterpijl als indicatie.
        onTap: onTap, // Verbindt de tap-callback.
      ),
    );
  }
}

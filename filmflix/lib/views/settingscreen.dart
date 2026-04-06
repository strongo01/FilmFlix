import 'dart:async'; // Importeer async/await en Stream functionaliteiten

import 'package:cinetrackr/utils/fcm_service.dart'; // Importeer FCM (Firebase Cloud Messaging) service
import 'package:flutter/material.dart'; // Importeer Flutter Material Design
import 'package:firebase_auth/firebase_auth.dart'; // Importeer Firebase authenticatie
import 'package:cloud_firestore/cloud_firestore.dart'; // Importeer Firestore database
import 'package:url_launcher/url_launcher.dart'; // Importeer URL launcher voor links openen
import 'package:cinetrackr/views/customer_service.dart'; // Importeer klantenservice scherm
import 'package:cinetrackr/main.dart'; // Importeer main app bestand
import 'package:cinetrackr/views/loginscreen.dart'; // Importeer login scherm
import 'package:cinetrackr/utils/notification_permissions.dart'; // Importeer notificatie permissie utility
import 'package:cinetrackr/l10n/l10n.dart'; // Importeer lokalisatie (vertalingen)
import 'package:cinetrackr/widgets/app_top_bar.dart'; // Importeer app top bar widget
import 'package:cinetrackr/widgets/app_background.dart'; // Importeer achtergrond widget

import 'package:permission_handler/permission_handler.dart'; // Importeer permission handler
import 'package:shared_preferences/shared_preferences.dart'; // Importeer shared preferences voor lokale opslag

class SettingsScreen extends StatefulWidget {
  // Definieer stateful widget voor instellingenscherm
  const SettingsScreen({super.key}); // Constructor met super.key

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(); // Maak state object aan
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State class voor SettingsScreen
  final Color movieBlue = const Color.fromRGBO(
    43,
    77,
    91,
    1,
  ); // Definieer MovieBlue kleur
  final Color goldAccent = const Color(
    0xFFD4AF37,
  ); // Definieer goud accentkleur
  bool _notificationsEnabled = true; // Boolean voor notificatie status
  StreamSubscription<User?>?
  _authSub; // Stream subscription voor auth wijzigingen
  User? _currentUser; // Huidige ingelogde gebruiker
  String? _displayName; // Weergavenaam van gebruiker
  String? _email; // Email van gebruiker
  int _cachedUnreadCustomerReplies =
      0; // Cache voor ongelezen klantenservice berichten
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _customerQuestionsSub; // Stream subscription voor klantvragen
  String _languageCode = 'nl'; // Standaard taalcode Nederlands

  @override
  void initState() {
    // Initialisatiemethode
    super.initState(); // Roep parent initState aan
    // Standaard naar apparaatlocale tenzij er een opgeslagen voorkeur is
    try {
      // Probeer apparaat locale in te stellen
      final deviceLang = WidgetsBinding
          .instance
          .platformDispatcher
          .locale
          .languageCode; // Haal apparaat taalcode op
      _languageCode = deviceLang; // Stel taalcode in op apparaat locale
    } catch (_) {
      // Als er een fout optreedt
      _languageCode = 'nl'; // Stel standaard Nederlands in
    }
    _currentUser =
        FirebaseAuth.instance.currentUser; // Haal huidige gebruiker op
    _displayName = _currentUser?.displayName; // Stel weergavenaam in
    _email = _currentUser?.email; // Stel email in
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Luister naar auth wijzigingen
      if (!mounted) return; // Stop als widget unmounted is
      setState(() {
        // Update state
        _currentUser = user; // Werk huidige gebruiker bij
        _displayName = user?.displayName; // Werk weergavenaam bij
        _email = user?.email; // Werk email bij
      });

      if (user != null) {
        // Als gebruiker ingelogd is
        _subscribeCustomerQuestions(user.uid); // Subscribe op klantvragen
        _fetchUnreadCustomerReplies().then((v) {
          // Haal ongelezen antwoorden op
          if (mounted)
            setState(() => _cachedUnreadCustomerReplies = v); // Update cache
        });

        // Initialiseer _notificationsEnabled op basis van of we een token hebben in firestore
        FirebaseFirestore.instance.collection('users').doc(user.uid).get().then(
          // Haal gebruiker document op
          (doc) {
            // Bij successful document ophalen
            if (mounted && doc.exists) {
              // Check of document bestaat en widget nog gemount is
              final data = doc.data() ?? {}; // Haal document data op
              setState(() {
                // Update state
                _notificationsEnabled =
                    data.containsKey('fcmToken') &&
                    (data['fcmToken']?.toString().isNotEmpty ??
                        false); // Controleer of FCM token aanwezig is
              });
            }
          },
        );
      } else {
        // Als gebruiker uitgelogd is
        _customerQuestionsSub?.cancel(); // Zet klantvragen subscription uit
        _customerQuestionsSub = null; // Stel op null
        if (mounted)
          setState(
            () => _cachedUnreadCustomerReplies = 0,
          ); // Reset ongelezen count
      }
    });

    // Laad opgeslagen taalvoorkeur voor weergave
    SharedPreferences.getInstance() // Haal shared preferences op
        .then((prefs) {
          // Bij success
          final lc =
              prefs.getString('app_locale') ??
              _languageCode; // Haal opgeslagen taal op of gebruik standaard
          if (mounted)
            setState(() => _languageCode = lc); // Update state met taal
        })
        .catchError((e) {
          // Bij fout
          debugPrint('Failed to load saved language: $e'); // Print fout
        });
  }

  @override
  void dispose() {
    // Dispose methode
    _authSub?.cancel(); // Zet auth subscription uit
    _customerQuestionsSub?.cancel(); // Zet klantvragen subscription uit
    super.dispose(); // Roep parent dispose aan
  }

  void _triggerMainTutorial() {
    try {
      final navState = MainNavigation.mainKey.currentState;
      if (navState != null) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        try {
          (navState as dynamic).startTutorial();
        } catch (e) {
          debugPrint('Failed to call startTutorial dynamically: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to trigger tutorial: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build methode
    final isDark =
        MediaQuery.of(context).platformBrightness ==
        Brightness.dark; // Check of dark mode actief is
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF1A1C1E); // Stel tekstkleur in op basis van mode
    final cardColor = isDark
        ? const Color(0xFF1C282E)
        : Colors.white; // Stel kaartkleur in op basis van mode

    return AppBackground(
      // Wrap in app background
      child: Scaffold(
        // Maak scaffold aan
        backgroundColor: Colors.transparent, // Stel transparante achtergrond in
        appBar: PreferredSize(
          // Definieer app bar
          preferredSize: const Size.fromHeight(56), // Stel hoogte in
          child: AppTopBar(
            // Maak custom top bar
            title:
                L10n.of(context)?.settingsTitle ??
                'Instellingen', // Stel titel in
            backgroundColor:
                Colors.transparent, // Stel transparante achtergrond in
          ),
        ),
        body: ListView(
          // Maak scrollbare list
          padding: const EdgeInsets.all(16.0), // Stel padding in
          children: [
            // Begin child lijst
            _buildSectionLabel(
              // Maak sectie label
              L10n.of(context)?.myDashboard ??
                  'Mijn Dashboard', // Stel label tekst in
            ),
            _buildAccountCard(cardColor, textColor), // Bouw account kaart

            const SizedBox(height: 24), // Voeg spacer toe

            _buildSectionLabel(
              L10n.of(context)?.preferences ?? 'Voorkeuren',
            ), // Maak voorkeur label
            _buildProfessionalCard(
              // Bouw voorkeur kaart
              cardColor,
              child: Column(
                // Maak kolom voor inhoud
                children: [
                  // Begin child lijst
                  SwitchListTile.adaptive(
                    // Maak adaptive switch
                    secondary: Icon(
                      Icons.notifications_none,
                      color: movieBlue,
                    ), // Voeg icon toe
                    title: Text(
                      L10n.of(context)?.notifications ?? 'Meldingen',
                    ), // Voeg titel toe
                    value: _notificationsEnabled, // Stel switch waarde in
                    activeColor: goldAccent, // Stel actieve kleur in
                    onChanged: (val) async {
                      // Bij switch wijziging
                      if (val == true) {
                        // Als ingeschakeld
                        final granted =
                            await requestNotificationPermission(); // Vraag permissie aan
                        if (!mounted) return; // Stop als unmounted

                        final ok = await registerFcmTokenForUser(
                          // Registreer FCM token
                          FirebaseAuth.instance.currentUser,
                        );

                        if (!mounted) return; // Stop als unmounted
                        setState(
                          () => _notificationsEnabled = true,
                        ); // Update state

                        if (granted && ok) {
                          // Als beide succesvol
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Toon succesmelding
                            SnackBar(
                              content: Text(
                                L10n.of(context)?.notifications_enabled ??
                                    'Meldingen ingeschakeld',
                              ),
                            ),
                          );
                        } else if (!granted) {
                          // Als permissie geweigerd
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Toon permissie melding
                            SnackBar(
                              content: Text(
                                L10n.of(context)?.notifications_check_system ??
                                    'Controleer de Systeem Instellingen om meldingen toe te laten.',
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else {
                          // Als registratie mislukt
                          ScaffoldMessenger.of(context).showSnackBar(
                            // Toon foutmelding
                            SnackBar(
                              content: Text(
                                L10n.of(
                                      context,
                                    )?.notifications_registration_failed ??
                                    'Aanmelden voor notificaties mislukt.',
                              ),
                            ),
                          );
                          setState(
                            () => _notificationsEnabled = false,
                          ); // Update state
                        }
                      } else {
                        // Als uitgeschakeld
                        await unregisterFcmTokenForUser(
                          // Unregister FCM token
                          FirebaseAuth.instance.currentUser,
                        );
                        if (!mounted) return; // Stop als unmounted
                        setState(
                          () => _notificationsEnabled = false,
                        ); // Update state
                      }
                    },
                  ),
                  _buildDivider(isDark), // Voeg scheidslijn toe
                  _buildSimpleTile(
                    // Bouw taal tile
                    Icons.language,
                    L10n.of(context)?.language ?? 'Taal',
                    _languageLabel(_languageCode, context), // Toon huidige taal
                    textColor,
                    () async {
                      // Bij tap
                      final prefs =
                          await SharedPreferences.getInstance(); // Haal preferences op
                      final current =
                          prefs.getString('app_locale') ??
                          _languageCode; // Haal huidige taal op

                      final langOptions = [
                        // Definieer taalopties
                        {
                          'code': 'nl',
                          'label': L10n.of(context)?.dutch ?? 'Nederlands',
                        },
                        {
                          'code': 'en',
                          'label': L10n.of(context)?.english ?? 'English',
                        },
                        {
                          'code': 'fr',
                          'label': L10n.of(context)?.french ?? 'Français',
                        },
                        {
                          'code': 'de',
                          'label': L10n.of(context)?.german ?? 'Deutsch',
                        },
                        {
                          'code': 'es',
                          'label': L10n.of(context)?.spanish ?? 'Español',
                        },
                        {
                          'code': 'tr',
                          'label': L10n.of(context)?.turkish ?? 'Türkçe',
                        },
                      ];

                      final choice = await showDialog<String>(
                        // Toon taal dialog
                        context: context,
                        builder: (ctx) => AlertDialog(
                          // Maak alert dialog
                          backgroundColor: cardColor,
                          title: Text(
                            // Voeg titel toe
                            L10n.of(context)?.language ?? 'Taal',
                            style: TextStyle(color: textColor),
                          ),
                          content: Column(
                            // Maak kolom voor opties
                            mainAxisSize: MainAxisSize.min,
                            children: langOptions.map((opt) {
                              // Map taalopties naar RadioListTiles
                              return RadioListTile<String>(
                                // Maak radio button
                                value: opt['code']!,
                                groupValue: current,
                                title: Text(
                                  // Toon taal naam
                                  opt['label']!,
                                  style: TextStyle(color: textColor),
                                ),
                                onChanged: (v) => Navigator.of(
                                  ctx,
                                ).pop(v), // Return gekozen taal
                              );
                            }).toList(),
                          ),
                          actions: [
                            // Voeg actions toe
                            TextButton(
                              // Maak close knop
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(
                                L10n.of(context)?.close ?? 'Close',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (choice != null) {
                        // Als taal gekozen
                        await prefs.setString(
                          'app_locale',
                          choice,
                        ); // Sla taal op
                        if (!mounted) return; // Stop als unmounted
                        setState(() => _languageCode = choice); // Update state
                        localeNotifier.value = Locale(
                          choice,
                        ); // Update global notifier
                      }
                    },
                  ),
                  _buildDivider(isDark),
                  _buildSimpleTile(
                    // Reset tutorial tile
                    Icons.school,
                    L10n.of(context)?.resetTutorial ?? 'Reset tutorial',
                    '',
                    textColor,
                    () async {
                      final l10n = L10n.of(context);
                      final prefs = await SharedPreferences.getInstance();
                      
                      if (!mounted) return;

                      await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: cardColor,
                          title: Text(
                            l10n?.resetTutorial ?? 'Reset tutorial',
                            style: TextStyle(color: textColor),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.navigation, color: Colors.blue),
                                title: const Text('Hoofd navigatie'),
                                subtitle: const Text('Uitleg over de balk en startscherm'),
                                onTap: () async {
                                  await prefs.setBool('tutorial_done_main_navigation', false);
                                  Navigator.pop(ctx);
                                  _triggerMainTutorial();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.home, color: Colors.green),
                                title: const Text('Home scherm'),
                                subtitle: const Text('Uitleg over de film slider'),
                                onTap: () async {
                                  await prefs.setBool('tutorial_done_home_screen', false);
                                  Navigator.pop(ctx);
                                  _triggerMainTutorial(); // Terug naar home om het te zien
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.refresh, color: Colors.orange),
                                title: const Text('Alles resetten'),
                                onTap: () async {
                                  final allKeys = prefs.getKeys().where((k) => k.startsWith('tutorial_done'));
                                  for (final key in allKeys) {
                                    await prefs.setBool(key, false);
                                  }
                                  await prefs.setBool('tutorial_done', false); // Oude key ook voor de zekerheid
                                  Navigator.pop(ctx);
                                  _triggerMainTutorial();
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n?.close ?? 'Sluiten'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24), // Voeg spacer toe

            _buildSectionLabel(
              L10n.of(context)?.support ?? 'Support',
            ), // Maak support label
            _buildProfessionalCard(
              // Bouw support kaart
              cardColor,
              child: Column(
                // Maak kolom
                children: [
                  // Begin child lijst
                  ListTile(
                    // Maak klantenservice tile
                    leading: Icon(
                      // Voeg icon toe
                      Icons.help_outline,
                      color: movieBlue.withOpacity(0.7),
                    ),
                    title: Text(
                      // Voeg titel toe
                      L10n.of(context)?.customerService_title ??
                          'Klantenservice',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      // Voeg trailing content toe
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Begin child lijst
                        if (_cachedUnreadCustomerReplies >
                            0) // Als er ongelezen berichten zijn
                          Container(
                            // Maak badge container
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              // Maak ronde rode badge
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              // Centreer content
                              child: Text(
                                // Toon nummer
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
                        const SizedBox(width: 8), // Voeg kleine spacer toe
                        const Icon(
                          // Voeg chevron icon toe
                          Icons.chevron_right,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Bij tile tap
                      Navigator.push(
                        // Navigate naar klantenservice
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomerServiceScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(isDark), // Voeg scheidslijn toe
                  _buildSimpleTile(
                    // Bouw over tile
                    Icons.info_outline,
                    L10n.of(context)?.aboutTitle ?? 'Over CineTrackr',
                    '',
                    textColor,
                    () {
                      // Bij tile tap
                      Navigator.of(context).push(
                        // Navigate naar about scherm
                        MaterialPageRoute(
                          builder: (_) => const AboutCineTrackrScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(isDark), // Voeg scheidslijn toe
                  _buildSimpleTile(
                    // Bouw disclaimer tile
                    Icons.description_outlined,
                    L10n.of(context)?.disclaimerTitle ?? 'Disclaimer',
                    '',
                    textColor,
                    () {
                      // Bij tile tap
                      Navigator.of(context).push(
                        // Navigate naar disclaimer scherm
                        MaterialPageRoute(
                          builder: (_) => const DisclaimerScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                  _buildDivider(isDark), // Voeg scheidslijn toe
                  _buildSimpleTile(
                    // Bouw privacy tile
                    Icons.lock_outline,
                    L10n.of(context)?.privacyPolicy ?? 'Privacybeleid',
                    '',
                    textColor,
                    () {
                      // Bij tile tap
                      _openPrivacyPolicy(); // Open privacy beleid
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40), // Voeg grote spacer toe
            Center(
              // Centreer logout/login knop
              child:
                  _currentUser !=
                      null // Als gebruiker ingelogd is
                  ? TextButton(
                      // Maak logout knop
                      onPressed: () async {
                        // Bij knop tap
                        await FirebaseAuth.instance.signOut(); // Log uit
                        if (!mounted) return; // Stop als unmounted
                        Navigator.of(context).pushReplacement(
                          // Ga naar main navigation
                          MaterialPageRoute(
                            builder: (_) => const MainNavigation(),
                          ),
                        );
                      },
                      child: Text(
                        // Voeg tekst toe
                        (L10n.of(context)?.logout ?? 'Uitloggen').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    )
                  : TextButton(
                      // Maak login knop
                      onPressed: () {
                        // Bij knop tap
                        Navigator.of(context).push(
                          // Navigate naar login
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        // Voeg tekst toe
                        (L10n.of(context)?.loginIn ?? 'Inloggen').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 10), // Voeg kleine spacer toe
            Center(
              // Centreer versie tekst
              child: Text(
                // Toon versie nummer
                'v1.0.4',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bouw account kaart met gebruikersinformatie en statistieken
  Widget _buildAccountCard(Color cardColor, Color textColor) {
    // Wrap de kaart in een professionele card container
    return _buildProfessionalCard(
      cardColor,
      // Maak de kaart aanklikbaar voor naam bewerking
      child: InkWell(
        // Bij tap: open dialog om naam te wijzigen
        onTap: () async {
          // Haal huidige ingelogde gebruiker op
          final user = FirebaseAuth.instance.currentUser;
          // Als geen gebruiker ingelogd, toon foutmelding
          if (user == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10n.of(context)?.mustBeLoggedIn ??
                      'Je moet ingelogd zijn om je naam te wijzigen',
                ),
              ),
            );
            return;
          }

          // Definieer form key voor validatie
          final formKey = GlobalKey<FormState>();
          // Maak text controller met huidige naam
          final ctrl = TextEditingController(text: _displayName ?? '');
          // Toon dialog en wacht op resultaat
          final result = await showDialog<bool>(
            context: context,
            // Bouw custom alert dialog
            builder: (ctx) => AlertDialog(
              // Zet dialog titel
              title: Text(
                L10n.of(context)?.changeNameTitle ?? 'Wijzig je naam',
              ),
              // Zet form met text input field
              content: Form(
                key: formKey,
                // Maak input veld voor naam
                child: TextFormField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: L10n.of(context)?.nameLabel ?? 'Je naam',
                  ),
                  // Valideer dat naam niet leeg is
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return L10n.of(context)?.nameValidation ??
                          'Vul je naam in';
                    return null;
                  },
                ),
              ),
              // Voeg annuleer en opslaan knoppen toe
              actions: [
                // Annuleer knop sluit dialog met false
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(L10n.of(context)?.cancel ?? 'Annuleer'),
                ),
                // Opslaan knop sluit dialog met true na validatie
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

          // Stop als gebruiker annuleerde
          if (result != true) return;
          if (!mounted) return;
          // Haal nieuwe naam op uit controller
          final newName = ctrl.text.trim();
          try {
            // Update Firebase Auth profiel met nieuwe naam
            await user.updateDisplayName(newName);
            // Herlaad gebruiker gegevens
            await user.reload();

            // Haal referentie naar Firestore user document
            final usersRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid);
            // Update Firestore document met nieuwe naam en timestamp
            await usersRef.set({
              'displayName': newName,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            if (!mounted) return;
            // Update state met nieuwe naam
            setState(() {
              _displayName = newName;
            });
            // Toon succesbericht
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10n.of(context)?.nameUpdated ?? 'Naam bijgewerkt',
                ),
              ),
            );
          } catch (e) {
            // Print fout naar console
            debugPrint('Failed to update displayName: $e');
            if (!mounted) return;
            // Toon foutbericht aan gebruiker
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10n.of(context)?.nameUpdateFailed ?? 'Bijwerken mislukt',
                ),
              ),
            );
          }
        },
        // Bouw zichtbare kaart inhoud
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Maak kolom voor profiel info
          child: Column(
            children: [
              // Bouw profielfoto en naamrij
              Row(
                children: [
                  // Maak blauwe container met persoon icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: movieBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Voeg persoon icon in container
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Maak tekstkolom voor naam en email
                  Expanded(
                    // Bouw naam en email labels
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Toon gebruikersnaam of standaard tekst
                        Text(
                          _displayName ??
                              L10n.of(context)?.profile_default_name ??
                              'Kevin le Goat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        // Toon gebruiker email of standaard tekst
                        Text(
                          _email ??
                              L10n.of(context)?.profile_default_email ??
                              'kevinlegoat@example.com',
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
                  // Voeg spacer voor rechteruitlijning
                  const Spacer(),
                  // Voeg chevron icon toe aan rechts
                  Icon(Icons.chevron_right, color: textColor.withOpacity(0.3)),
                ],
              ),
              // Voeg scheidslijn tussen profiel en stats
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              // Stream builder voor dynamische statistieken uit Firestore
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                // Luister naar documentveranderingen van huidige gebruiker
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                // Bouw UI op basis van stream status
                builder: (ctx, snap) {
                  // Toon placeholder als data nog niet geladen
                  if (!snap.hasData) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Toon placeholder voor films
                        _buildStatItem(
                          '—',
                          L10n.of(context)?.filmsDone ?? 'Films af',
                          textColor,
                        ),
                        // Toon placeholder voor watchlist
                        _buildStatItem(
                          '—',
                          L10n.of(context)?.watchlist_label ?? 'Watchlist',
                          textColor,
                        ),
                      ],
                    );
                  }

                  // Haal gebruiker data uit snapshot
                  final data = snap.data!.data() ?? {};

                  // Zet watchlist om naar String List
                  final watchlist = (data['watchlist'] is List)
                      ? List<String>.from(data['watchlist'])
                      : <String>[];

                  // Bouw map van alle gekeken episodes
                  final Map<String, dynamic> seenMap = {};
                  // Haal seenEpisodes object op
                  final seenRaw = data['seenEpisodes'];
                  // Merge seenEpisodes map in seenMap als het een Map is
                  if (seenRaw is Map)
                    seenRaw.forEach((k, v) => seenMap[k.toString()] = v);
                  // Voeg geflatteerde seenEpisodes-keys samen in seenMap
                  for (final k in data.keys) {
                    if (k.startsWith('seenEpisodes.')) {
                      final imdb = k.split('.').last;
                      seenMap[imdb] = data[k];
                    }
                  }

                  // Functie om te checken of waarde 'movie' marker bevat
                  bool seenIndicatesMovie(dynamic val) {
                    // Itereer door list waarden
                    if (val is List) {
                      for (final e in val) {
                        // Return true als 'movie' string gevonden
                        if (e != null && e.toString().toLowerCase() == 'movie')
                          return true;
                      }
                    }
                    return false;
                  }

                  // Tel alleen items met expliciete 'movie' marker
                  final watchingFilms = <String>[];
                  // Loop door alle entries in seenMap
                  for (final e in seenMap.entries) {
                    final val = e.value;
                    // Check of entry een list is
                    if (val is List) {
                      // Check of list 'movie' marker bevat
                      final hasMovieMarker = val.any(
                        (x) =>
                            x != null && x.toString().toLowerCase() == 'movie',
                      );
                      // Voeg ID toe als movie marker gevonden
                      if (hasMovieMarker) watchingFilms.add(e.key.toString());
                    }
                  }

                  // Filter watchlist items die ook 'movie' marker hebben
                  final savedFilmsMarkedMovie = watchlist.where((id) {
                    final val = seenMap[id];
                    return val is List && seenIndicatesMovie(val);
                  }).toList();

                  // Merge beide film lists en verwijder duplicaten met set
                  final filmIds = {...savedFilmsMarkedMovie, ...watchingFilms};

                  // Debug print voor watchlist inhoud
                  debugPrint('SettingsScreen: watchlist=${watchlist}');
                  // Debug print voor seenMap keys
                  debugPrint(
                    'SettingsScreen: seenMap_keys=${seenMap.keys.toList()}',
                  );
                  // Debug print voor saved films met movie marker
                  debugPrint(
                    'SettingsScreen: savedFilmsMarkedMovie=${savedFilmsMarkedMovie}',
                  );
                  // Debug print voor watching films
                  debugPrint('SettingsScreen: watchingFilms=${watchingFilms}');
                  // Debug print voor finale film IDs
                  debugPrint('SettingsScreen: filmIds=${filmIds}');

                  // Bouw rij met film en watchlist statistieken
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Toon aantal gekeken films
                      _buildStatItem(
                        filmIds.length.toString(),
                        L10n.of(context)?.filmsDone ?? 'Films af',
                        textColor,
                      ),
                      // Toon aantal items op watchlist
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

  // Bouw statistiek item met waarde en label
  Widget _buildStatItem(String value, String label, Color textColor) {
    return Column(
      children: [
        // Toon statistiekwaarde in groot bold font
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: movieBlue,
          ),
        ),
        // Toon statistiek label eronder
        Text(
          label,
          style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
        ),
      ],
    );
  }

  // Bouw stijlvolle kaart container met schaduw
  Widget _buildProfessionalCard(Color color, {required Widget child}) {
    return Container(
      // Maak cascade met rounded corners en schaduw
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      // Wrap child in Material met achtergrondkleur
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  // Bouw list tile met icon, titel en navigatie
  Widget _buildSimpleTile(
    IconData icon,
    String title,
    String trailing,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      // Zet icon links
      leading: Icon(icon, color: movieBlue.withOpacity(0.7)),
      // Zet titel met aangepaste stijl
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Zet trailing content rechts
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toon trailing text als niet leeg
          if (trailing.isNotEmpty)
            Text(
              trailing,
              style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14),
            ),
          const SizedBox(width: 4),
          // Voeg chevron icon toe
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
      // Voer callback uit bij tile tap
      onTap: onTap,
    );
  }

  // Open privacybeleid URL in browser
  Future<void> _openPrivacyPolicy() async {
    // Parse privacy policy URL
    final uri = Uri.parse('https://sites.google.com/view/cinetrackr/homepage');
    try {
      // Probeer URL in in-app webview te openen
      if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
        // Fall back naar externe browser als webview niet ondersteund
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Print fout als URL launch mislukt
      debugPrint('Could not launch privacy policy url: $e');
    }
  }

  // Zet taalcode om naar leesbare taalabel
  String _languageLabel(String code, BuildContext context) {
    // Check taalcode en return passende label
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
        // Return oorspronkelijkse code als geen match
        return code;
    }
  }

  // Bouw sectie header label uppercase
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      // Toon label in uppercase grijs
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

  // Bouw horizontale scheidslijn
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 55,
      endIndent: 10,
      // Stel kleur in op basis van dark mode
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  // Haal aantal ongelezen klantenservice replies op
  Future<int> _fetchUnreadCustomerReplies() async {
    try {
      // Haal huidige gebruiker op
      final user = FirebaseAuth.instance.currentUser;
      // Return 0 als geen gebruiker ingelogd
      if (user == null) return 0;
      // Haal user ID op
      final uid = user.uid;
      // Query alle klantvragen voor deze gebruiker
      final snap = await FirebaseFirestore.instance
          .collection('customerquestions')
          .where('userId', isEqualTo: uid)
          .get();
      // Initialiseer ongelezen counter
      int unread = 0;
      // Loop door alle klantvragen
      for (final d in snap.docs) {
        // Haal vraag data op
        final data = d.data();
        // Haal admin replies op uit vraag
        final adminReplies = (data['adminReplies'] as List?) ?? [];
        // Check of gebruiker vraag gelezen heeft
        final userRead = data['userRead'] == true;

        // Tel vraag als ongelezen als niet gelezen
        if (!userRead) {
          unread += 1;
          continue;
        }

        // Itereer door admin replies
        for (final ar in adminReplies) {
          // Check of reply een map is
          if (ar is Map) {
            // Haal seenBy list uit reply
            final seenBy =
                (ar['seenBy'] as List?)?.map((e) => e.toString()).toList() ??
                [];
            // Tel als ongelezen als user niet in seenBy lijst
            if (!seenBy.contains(uid)) {
              unread += 1;
              break;
            }
          }
        }
      }
      // Return totaal ongelezen count
      return unread;
    } catch (e) {
      // Print fout naar console
      debugPrint('Failed fetching unread customer replies (settings): $e');
      // Return 0 bij fout
      return 0;
    }
  }

  // Subscribe op klantvragen changes met realtime updates
  void _subscribeCustomerQuestions(String uid) {
    // Cancel vorige subscription
    _customerQuestionsSub?.cancel();
    // Maak neue stream listener
    _customerQuestionsSub = FirebaseFirestore.instance
        .collection('customerquestions')
        .where('userId', isEqualTo: uid)
        // Luister naar realtime snapshot updates
        .snapshots()
        .listen(
          (snap) {
            try {
              // Initialiseer ongelezen counter
              int unread = 0;
              // Loop door alle klantvragen
              for (final d in snap.docs) {
                // Haal vraag data op
                final data = d.data();
                // Haal admin replies op
                final adminReplies = (data['adminReplies'] as List?) ?? [];
                // Check of vraag gelezen is
                final userRead = data['userRead'] == true;

                // Tel als ongelezen als niet gelezen
                if (!userRead) {
                  unread += 1;
                  continue;
                }

                // Itereer door admin replies
                for (final ar in adminReplies) {
                  // Check of reply map is
                  if (ar is Map) {
                    // Haal seenBy list op
                    final seenBy =
                        (ar['seenBy'] as List?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        [];
                    // Tel als ongelezen als user niet in seenBy
                    if (!seenBy.contains(uid)) {
                      unread += 1;
                      break;
                    }
                  }
                }
              }
              // Update state met nieuwe ongelezen count als gemount
              if (mounted)
                setState(() => _cachedUnreadCustomerReplies = unread);
            } catch (e) {
              // Print fout naar console
              debugPrint(
                'Failed to compute unread count in SettingsScreen: $e',
              );
            }
          },
          // Handel streamfouten af
          onError: (e) {
            // Print stream fout naar console
            debugPrint('customerquestions listen error (settings): $e');
          },
        );
  }
}

// Scherm voor disclaimer tekst
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check of dark mode actief is
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    // Stel tekstkleur in op basis van thema
    final textColor = isDark ? Colors.white : Colors.black87;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Maak custom top bar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppTopBar(
            title: L10n.of(context)?.disclaimerTitle ?? 'Disclaimer',
            backgroundColor: Colors.transparent,
          ),
        ),
        // Scroll view voor lange content
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            // Maak tekstkolom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disclaimer hoofd titel
                Text(
                  L10n.of(context)?.disclaimerHeading ?? 'Derden & APIs',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Disclaimer hoofd tekst
                Text(
                  L10n.of(context)!.disclaimerText,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                // Disclaimer noot/voetnoot
                Text(
                  L10n.of(context)!.disclaimerNote,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Scherm met informatie over CineTrackr app
class AboutCineTrackrScreen extends StatelessWidget {
  const AboutCineTrackrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check of dark mode actief is
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    // Stel tekstkleur in op basis van thema
    final textColor = isDark ? Colors.white : Colors.black;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Maak custom top bar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AppTopBar(
            title: L10n.of(context)?.aboutTitle ?? 'Over CineTrackr',
            backgroundColor: Colors.transparent,
          ),
        ),
        // Scroll view voor lange content
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            // Toon about tekst met padding
            child: Text(
              L10n.of(context)?.aboutText ?? '',
              style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

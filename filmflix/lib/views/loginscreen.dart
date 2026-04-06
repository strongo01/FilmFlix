import 'dart:async'; // Asynchrone operaties en streams
import 'dart:convert'; // JSON en UTF-8 conversie
import 'dart:math'; // Wiskundige functies en random

import 'package:cinetrackr/main.dart'; // Hoofd app bestand
import 'package:email_validator/email_validator.dart'; // Email validatie
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authenticatie
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore database
import 'package:flutter/material.dart'; // Flutter UI widgets
import 'package:flutter/services.dart'; // Platform specifieke services
import 'package:fluttertoast/fluttertoast.dart'; // Toast notificaties
import 'package:crypto/crypto.dart'; // SHA256 hashing
import 'package:cinetrackr/l10n/app_localizations.dart'; // Lokalisatie/vertalingen
import 'package:flutter/foundation.dart'; // Flutter framework utiliteiten
import 'package:google_sign_in/google_sign_in.dart'; // Google inloggen
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Apple inloggen
import 'package:flutter_signin_button/flutter_signin_button.dart'; // Social login buttons

class LoginScreen extends StatefulWidget {
  // Login scherm widget met state
  final bool returnAfterLogin; // Property om terug te keren na login

  const LoginScreen({super.key, this.returnAfterLogin = false}); // Constructor

  @override
  State<LoginScreen> createState() => _LoginScreenState(); // Creëer state
}

class _LoginScreenState extends State<LoginScreen> {
  // State voor login scherm
  StreamSubscription<User?>? _authSub; // Abonnement op auth veranderingen
  final _formKey = GlobalKey<FormState>(); // Formulier validatie sleutel
  final _nameCtrl = TextEditingController(); // Naam input controller
  final _emailCtrl = TextEditingController(); // Email input controller
  final _passwordCtrl = TextEditingController(); // Wachtwoord input controller
  bool _isLoading = false; // Laad status indicator
  bool _obscure = true; // Wachtwoord verbergen toggle
  bool _isLogin = true; // Login/Register mode toggle

  @override
  void dispose() {
    // Opruimen bij verwijdering
    _authSub?.cancel(); // Stop auth abonnement
    _nameCtrl.dispose(); // Ruim naam controller op
    _emailCtrl.dispose(); // Ruim email controller op
    _passwordCtrl.dispose(); // Ruim wachtwoord controller op
    super.dispose(); // Roep parent dispose aan
  }

  @override
  void initState() {
    // Initialisatie
    super.initState(); // Roep parent initState aan
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Luister naar login veranderingen
      if (user != null && // Gebruiker is ingelogd
          mounted && // Widget bestaat nog
          ModalRoute.of(context)?.isCurrent == true) {
        // Dit scherm is actief
        if (widget.returnAfterLogin) {
          // Moet teruggaan
          Navigator.of(context).pop(true); // Ga terug naar vorige scherm
        } else {
          // Anders ga naar home
          Navigator.of(context).pushReplacement(
            // Vervang huidiig scherm
            MaterialPageRoute(
              builder: (_) => const MainNavigation(),
            ), // Met home scherm
          );
        }
      }
    });
  }

  Future<void> _submit() async {
    // Inlog/registratie formulier indienen
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    if (!_formKey.currentState!.validate()) return; // Valideer formulier
    setState(() => _isLoading = true); // Toon laad indicator
    try {
      // Probeer in te loggen
      final auth = FirebaseAuth.instance; // Haal Firebase auth op
      if (_isLogin) {
        // Inloggen
        await auth.signInWithEmailAndPassword(
          // Inloggen met email/wachtwoord
          email: _emailCtrl.text.trim(), // Email
          password: _passwordCtrl.text, // Wachtwoord
        );
      } else {
        // Registreren
        final cred = await auth.createUserWithEmailAndPassword(
          // Maak nieuw account
          email: _emailCtrl.text.trim(), // Email
          password: _passwordCtrl.text, // Wachtwoord
        );
        final user = cred.user; // Haal nieuwe gebruiker op
        if (user != null) {
          // Gebruiker bestaat
          await user.updateDisplayName(
            _nameCtrl.text.trim(),
          ); // Zet weergavenaam
          await user.reload(); // Herlaad gebruiker gegevens
          final updatedUser = auth.currentUser; // Haal bijgewerkte gebruiker op
          if (updatedUser != null) {
            // Gebruiker bestaat
            final usersRef = FirebaseFirestore
                .instance // Haal Firestore collectie op
                .collection('users')
                .doc(updatedUser.uid);
            await usersRef.set({
              // Sla gebruiker gegevens op
              'displayName': _nameCtrl.text.trim(), // Weergavenaam
              'email': updatedUser.email, // Email
              'createdAt': FieldValue.serverTimestamp(), // Aanmaakdatum
            }, SetOptions(merge: true)); // Merge met bestaande data
          }
        }
      }
      if (!mounted) return; // Stop als widget weg is
      if (!widget.returnAfterLogin) {
        // Niet teruggaan
        Navigator.of(context).pushReplacement(
          // Ga naar home
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Firebase auth fout
      final message = _localizedFirebaseAuthMessage(e); // Vertaal fout bericht
      Fluttertoast.showToast(msg: message); // Toon bericht
    } catch (e) {
      // Andere fout
      Fluttertoast.showToast(
        msg: loc.loginSomethingWentWrong,
      ); // Toon generieke fout
    } finally {
      // Ook als geen fouten
      if (mounted) setState(() => _isLoading = false); // Verberg laad indicator
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    // Inloggen met Google
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    if (kIsWeb) {
      // Web platform
      final googleProvider = GoogleAuthProvider(); // Creëer Google provider
      googleProvider.addScope('email'); // Voeg email scope toe
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      }); // Eis account selectie
      try {
        // Probeer in te loggen
        final userCred = await FirebaseAuth.instance.signInWithPopup(
          // Toon inlog popup
          googleProvider,
        );
        await _saveUserDoc(userCred.user); // Sla gebruiker op
        return userCred; // Geef credentials terug
      } on FirebaseAuthException catch (e) {
        // Firebase fout
        final message = _localizedFirebaseAuthMessage(e); // Vertaal fout
        Fluttertoast.showToast(msg: message); // Toon fout
        rethrow; // Gooi fout door
      }
    }

    try {
      // Mobiel platform
      final googleSignIn = GoogleSignIn.instance; // Haal Google signin op
      final googleUser = await googleSignIn
          .authenticate(); // Vraag authenticatie
      if (googleUser == null) {
        // Gebruiker geannuleerd
        throw FirebaseAuthException(
          // Gooi fout
          code: 'sign_in_cancelled',
          message: loc.googleSignInCancelled,
        );
      }
      final googleAuth = await googleUser.authentication; // Haal auth tokens op
      final idToken = googleAuth.idToken; // Haal ID token op
      if (idToken == null) {
        // Geen ID token
        throw FirebaseAuthException(
          // Gooi fout
          code: 'missing_id_token',
          message: loc.googleIdTokenError,
        );
      }

      String? accessToken; // Access token
      try {
        // Probeer access token te krijgen
        final scopes = <String>[
          'openid',
          'email',
          'profile',
        ]; // Gewenste scopes
        var authorization = await googleUser
            .authorizationClient // Vraag toestemming
            .authorizationForScopes(scopes);
        authorization ??= await googleUser.authorizationClient.authorizeScopes(
          // Of vraag opnieuw
          scopes,
        );
        accessToken = authorization.accessToken; // Haal access token op
      } catch (_) {
        // Fout bij ophalen
        accessToken = null; // Zet null
      }

      final credential = GoogleAuthProvider.credential(
        // Creëer credentials
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(
        // Inloggen met credentials
        credential,
      );
      await _saveUserDoc(userCred.user); // Sla gebruiker op
      return userCred; // Geef credentials terug
    } on FirebaseAuthException catch (e) {
      // Firebase fout
      _handleFirebaseAuthError(e); // Behandel fout
      rethrow; // Gooi door
    } on PlatformException catch (e) {
      // Platform fout
      if (e.code.toLowerCase().contains('cancel')) {
        // Gebruiker geannuleerd
        throw FirebaseAuthException(
          // Gooi fout
          code: 'sign_in_cancelled',
          message: loc.googleSignInCancelled,
        );
      }
      Fluttertoast.showToast(
        msg: e.message ?? loc.googleSignInFailed,
      ); // Toon fout
      rethrow; // Gooi door
    }
  }

  void _handleFirebaseAuthError(FirebaseAuthException e) {
    // Behandel Firebase auth fout
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    String message = e.message ?? loc.authenticationFailed; // Standaard bericht
    switch (e.code) {
      // Controleer fout code
      case 'invalid-credential': // Ongeldige credentials
      case 'malformed-jwt': // Ongeldige JWT
        message = loc.loginErrorCredentialMalformed; // Vertaal bericht
        break;
      case 'user-disabled': // Gebruiker uitgeschakeld
        message = loc.loginErrorUserDisabled;
        break;
      case 'too-many-requests': // Te veel aanvragen
        message = loc.loginErrorTooManyRequests;
        break;
      case 'account-exists-with-different-credential': // Account bestaat al
        message = loc.loginErrorAccountExists;
        break;
    }
    Fluttertoast.showToast(msg: message); // Toon bericht
  }

  String _localizedFirebaseAuthMessage(FirebaseAuthException e) {
    // Vertaal Firebase fout
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    String message = e.message ?? loc.authenticationFailed; // Standaard bericht
    switch (e.code) {
      // Controleer fout code
      case 'invalid-email': // Ongeldige email
        message = loc.loginErrorInvalidEmail;
        break;
      case 'user-disabled': // Gebruiker uitgeschakeld
        message = loc.loginErrorUserDisabled;
        break;
      case 'user-not-found': // Gebruiker niet gevonden
        message = loc.loginErrorUserNotFound;
        break;
      case 'wrong-password': // Fout wachtwoord
        message = loc.loginErrorWrongPassword;
        break;
      case 'too-many-requests': // Te veel aanvragen
        message = loc.loginErrorTooManyRequests;
        break;
      case 'invalid-credential': // Ongeldige credentials
      case 'malformed-jwt': // Ongeldige JWT
      case 'invalid-verification-code': // Ongeldige verificatie code
      case 'invalid-verification-id': // Ongeldige verificatie ID
        message = loc.loginErrorCredentialMalformed;
        break;
      case 'account-exists-with-different-credential': // Account bestaat al
      case 'email-already-in-use': // Email al in gebruik
        message = loc.loginErrorAccountExists;
        break;
      case 'weak-password': // Zwak wachtwoord
        message = loc.loginErrorWeakPassword;
        break;
      case 'network-request-failed': // Netwerk fout
        message = loc.loginErrorNetworkFailed;
        break;
      case 'user-token-expired': // Token verlopen
      case 'requires-recent-login': // Recente login vereist
        message = loc.loginErrorRequiresRecentLogin;
        break;
      default: // Onbekende fout
        message = e.message ?? loc.authenticationFailed;
    }
    return message; // Geef bericht terug
  }

  Future<void> _signInWithGitHub() async {
    // Inloggen met GitHub
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op

    setState(() => _isLoading = true); // Toon laad indicator
    try {
      // Probeer in te loggen
      final provider = GithubAuthProvider(); // Creëer GitHub provider
      provider.addScope('read:user'); // Voeg scope toe
      provider.addScope('user:email'); // Voeg email scope toe

      UserCredential? userCred; // Credentials variabele
      if (kIsWeb) {
        // Web platform
        userCred = await FirebaseAuth.instance.signInWithPopup(
          provider,
        ); // Toon popup
      } else {
        // Mobiel platform
        userCred = await FirebaseAuth.instance.signInWithProvider(
          provider,
        ); // Gebruik provider
      }

      if (userCred.user != null) {
        // Gebruiker bestaat
        await _saveUserDoc(userCred.user); // Sla gebruiker op
        if (mounted) {
          // Widget bestaat nog
          if (widget.returnAfterLogin) {
            // Moet teruggaan
            Navigator.of(context).pop(true); // Ga terug
          } else {
            // Anders ga naar home
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainNavigation()),
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase fout
      debugPrint(
        'GitHub Sign-In Error: ${e.code} - ${e.message}',
      ); // Debug print
      final message = _localizedFirebaseAuthMessage(e); // Vertaal fout
      Fluttertoast.showToast(msg: message); // Toon fout
    } catch (e) {
      // Andere fout
      debugPrint('GitHub Sign-In Unexpected Error: $e'); // Debug print
      Fluttertoast.showToast(
        msg: loc.loginSomethingWentWrong,
      ); // Toon generieke fout
    } finally {
      // Ook als geen fouten
      if (mounted) setState(() => _isLoading = false); // Verberg laad indicator
    }
  }

  String generateNonce([int length = 32]) {
    // Genereer willekeurige string
    const charset = // Beschikbare caractters
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure(); // Beveiligde random generator
    return List.generate(
      // Genereer lijst
      length,
      (_) => charset[rand.nextInt(charset.length)], // Willekeurig karakter
    ).join(); // Voeg samen
  }

  String sha256ofString(String input) {
    // Hash string met SHA256
    final bytes = utf8.encode(input); // Converteer naar bytes
    final digest = sha256.convert(bytes); // Hash met sha256
    return digest.toString(); // Converteer naar string
  }

  Future<UserCredential> signInWithApple() async {
    // Inloggen met Apple
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    final rawNonce = generateNonce(); // Genereer nonce
    final nonce = sha256ofString(rawNonce); // Hash nonce
    try {
      // Probeer in te loggen
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        // Vraag Apple login
        scopes: [
          // Gevraagde gegevens
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        // Geen token
        throw FirebaseAuthException(
          // Gooi fout
          code: 'null_identity_token',
          message: loc.appleSignInNoIdentityToken,
        );
      }
      final oauthCredential = OAuthProvider("apple.com").credential(
        // Creëer OAuth credentials
        idToken: appleCredential.identityToken!,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        // Inloggen met credentials
        oauthCredential,
      );
      if (mounted) {
        // Widget bestaat nog
        if (widget.returnAfterLogin) {
          // Moet teruggaan
          Navigator.of(context).pop(true); // Ga terug
        } else {
          // Anders ga naar home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
      }
      final userBefore =
          FirebaseAuth.instance.currentUser; // Haal huidge gebruiker op
      try {
        // Probeer displayName in te stellen
        final given = appleCredential.givenName; // Haal voornaam op
        if (userBefore != null && // Gebruiker bestaat
            given != null && // Voornaam bestaat
            given.trim().isNotEmpty && // Voornaam niet leeg
            (userBefore.displayName == null || // Geen displayName
                userBefore.displayName!.trim().isEmpty)) {
          // Of displayName leeg
          await userBefore.updateDisplayName(given.trim()); // Zet displayName
          await userBefore.reload(); // Herlaad gebruiker
        }
      } catch (e) {
        // Fout bij updaten
        debugPrint(
          'Apple sign-in: kon displayName niet updaten: $e',
        ); // Debug print
      }

      final userAfter =
          FirebaseAuth.instance.currentUser; // Haal huidge gebruiker op
      try {
        // Probeer gebruiker document op te slaan
        final uid = userAfter?.uid; // Haal UID op
        final given = appleCredential.givenName?.trim(); // Haal voornaam op
        if (uid != null && given != null && given.isNotEmpty) {
          // UID en voornaam bestaan
          final usersRef = FirebaseFirestore
              .instance // Haal Firestore collectie op
              .collection('users')
              .doc(uid);
          final doc = await usersRef.get(); // Haal huidiing document op
          final shouldSet = // Bepaal of document opgeslagen moet worden
              !doc.exists || // Document bestaat niet
              (doc.data()?['displayName'] == null || // Geen displayName
                  (doc.data()?['displayName'] as String)
                      .trim()
                      .isEmpty); // Of displayName leeg
          if (shouldSet) {
            // Moet opslaan
            await usersRef.set({
              // Sla gebruiker document op
              'displayName': given,
              'email': appleCredential.email ?? userAfter?.email,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true)); // Merge met bestaande data
          }
        }
      } catch (e) {
        // Fout bij opslaan
        debugPrint('AppleSignIn: failed to write user doc: $e'); // Debug print
      }

      return userCredential; // Geef credentials terug
    } on FirebaseAuthException catch (e) {
      // Firebase fout
      final message = _localizedFirebaseAuthMessage(e); // Vertaal fout
      Fluttertoast.showToast(msg: message); // Toon fout
      rethrow; // Gooi door
    }
  }

  Future<void> _resetPassword() async {
    // Wachtwoord reset
    final loc = AppLocalizations.of(context)!; // Haal vertalingen op
    final email = _emailCtrl.text.trim(); // Haal email op
    if (email.isEmpty || !EmailValidator.validate(email)) {
      // Email niet geldig
      ScaffoldMessenger.of(
        // Toon bericht
        context,
      ).showSnackBar(SnackBar(content: Text(loc.loginEnterValidEmail)));
      return; // Stop
    }
    try {
      // Probeer reset email te sturen
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      ); // Stuur reset email
      ScaffoldMessenger.of(
        // Toon succes bericht
        context,
      ).showSnackBar(SnackBar(content: Text(loc.loginPasswordResetEmailSent)));
    } on FirebaseAuthException catch (e) {
      // Firebase fout
      final message = _localizedFirebaseAuthMessage(e); // Vertaal fout
      ScaffoldMessenger.of(context).showSnackBar(
        // Toon fout bericht
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _saveUserDoc(User? user, {String? displayName}) async {
    // Sla gebruiker document op
    if (user == null) return; // Stop als geen gebruiker
    final name = (displayName ?? user.displayName)?.trim(); // Haal naam op
    try {
      // Probeer op te slaan
      final usersRef = FirebaseFirestore
          .instance // Haal Firestore collectie op
          .collection('users')
          .doc(user.uid);
      await usersRef.set({
        // Sla document op
        if (name != null && name.isNotEmpty)
          'displayName': name, // Als naam bestaat
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Merge met bestaande data
    } catch (e) {
      // Fout bij opslaan
      debugPrint('saveUserDoc failed: $e'); // Debug print
    }
  }

  Widget _buildCustomTextField({
    // Bouw aangepast invoer veld
    required TextEditingController controller, // Tekst controller
    required String label, // Labeltext
    required IconData icon, // Icoon
    bool obscureText = false, // Tekstverberging
    Widget? suffixIcon, // Achter icoon
    TextInputType? keyboardType, // Keyboard type
    String? Function(String?)? validator, // Validatie functie
  }) {
    return TextFormField(
      // Creëer formulier veld
      controller: controller, // Zet controller
      obscureText: obscureText, // Zet tekstverberging
      keyboardType: keyboardType, // Zet keyboard type
      style: const TextStyle(color: Colors.white), // Witte tekst
      decoration: InputDecoration(
        // Zet stijl
        labelText: label, // Zet label
        labelStyle: const TextStyle(color: Colors.white70), // Grijs label
        prefixIcon: Icon(icon, color: Colors.white70), // Voor icoon
        suffixIcon: suffixIcon, // Achter icoon
        filled: true, // Vul achtergrond
        fillColor: const Color(
          0xFF22404B,
        ).withOpacity(0.5), // Donker blauw achtergrond
        border: OutlineInputBorder(
          // Zet border
          borderRadius: BorderRadius.circular(15), // Ronde hoeken
          borderSide: BorderSide.none, // Geen border
        ),
        enabledBorder: OutlineInputBorder(
          // Border wanneer actief
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ), // Subtiele border
        ),
        focusedBorder: OutlineInputBorder(
          // Border wanneer gericht
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFFFC107),
            width: 1,
          ), // Gele border
        ),
      ),
      validator: validator, // Zet validator
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bouw de UI
    const Color scaffoldBgColor = Color(
      0xFF22404B,
    ); // Definieer achtergrondkleur
    const Color cardColor = Color(0xFF2C4E5B); // Definieer kaartkleur
    const Color accentColor = Color(0xFFFFC107); // Definieer accentkleur
    const Color textColor = Colors.white; // Definieer tekstkleur

    final loc = AppLocalizations.of(context)!; // Haal vertalingen op

    return Scaffold(
      // Creëer basis scherm
      backgroundColor: scaffoldBgColor, // Zet achtergrondkleur
      body: SafeArea(
        // Voeg veilige gebied toe
        child: Center(
          // Centreer inhoud
          child: SingleChildScrollView(
            // Maak scrollbaar
            padding: const EdgeInsets.all(24.0), // Voeg padding toe
            child: ConstrainedBox(
              // Beperk maximale breedte
              constraints: const BoxConstraints(
                maxWidth: 480,
              ), // Zet maximale breedte
              child: Card(
                // Creëer kaart widget
                shape: RoundedRectangleBorder(
                  // Zet afgeronde hoeken
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0, // Verwijder schaduw
                color: cardColor, // Zet kaartkleur
                child: Padding(
                  // Voeg binnenpadding toe
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    // Creëer formulier
                    key: _formKey, // Zet formuliersleutel
                    child: Column(
                      // Creëer verticale layout
                      mainAxisSize: MainAxisSize.min, // Minimale hoogte
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // Zet volle breedte
                      children: [
                        Center(
                          // Centreer icoon
                          child: Container(
                            // Creëer container
                            padding: const EdgeInsets.all(
                              16,
                            ), // Voeg padding toe
                            decoration: BoxDecoration(
                              // Zet stijl
                              color: Colors.white.withOpacity(
                                0.1,
                              ), // Subtiele achtergrond
                              shape: BoxShape.circle, // Maak cirkel
                            ),
                            child: const Icon(
                              // Creëer icoon
                              Icons.movie_filter_rounded,
                              size: 48,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Voeg verticale spatie toe
                        Text(
                          // Creëer titel tekst
                          _isLogin
                              ? loc.loginWelcome
                              : loc.loginCreateAccount, // Zet conditionele titel
                          textAlign: TextAlign.center, // Centreer tekst
                          style: const TextStyle(
                            // Zet tekststijl
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 32), // Voeg verticale spatie toe
                        if (!_isLogin) ...[
                          // Toon naam veld alleen bij registratie
                          _buildCustomTextField(
                            // Bouw naam invoerveld
                            controller: _nameCtrl,
                            label: loc.loginName,
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? loc.loginNameRequired
                                : null,
                          ),
                          const SizedBox(
                            height: 16,
                          ), // Voeg verticale spatie toe
                        ],
                        _buildCustomTextField(
                          // Bouw email invoerveld
                          controller: _emailCtrl,
                          label: loc.loginEmail,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            // Valideer email
                            if (v == null || v.trim().isEmpty)
                              return loc.loginEmailRequired;
                            if (!EmailValidator.validate(v.trim()))
                              return loc.loginInvalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16), // Voeg verticale spatie toe
                        _buildCustomTextField(
                          // Bouw wachtwoord invoerveld
                          controller: _passwordCtrl,
                          label: loc.loginPassword,
                          icon: Icons.lock_outline,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            // Voeg zichtbaarheid knop toe
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(
                              () => _obscure = !_obscure,
                            ), // Toggle wachtwoord zichtbaarheid
                          ),
                          validator: (v) {
                            // Valideer wachtwoord
                            if (v == null || v.isEmpty)
                              return loc.loginPasswordRequired;
                            if (v.length < 6) return loc.loginPasswordTooShort;
                            return null;
                          },
                        ),
                        const SizedBox(height: 30), // Voeg verticale spatie toe
                        ElevatedButton(
                          // Creëer inlog/registratie knop
                          onPressed: _isLoading
                              ? null
                              : _submit, // Zet onPress handler
                          style: ElevatedButton.styleFrom(
                            // Zet knopstijl
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF3B6372),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child:
                              _isLoading // Toon spinner of tekst
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? loc.loginIn : loc.loginRegister,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16), // Voeg verticale spatie toe
                        TextButton(
                          // Creëer toggle login/register knop
                          onPressed: _isLoading
                              ? null
                              : () => setState(
                                  () => _isLogin = !_isLogin,
                                ), // Toggle modus
                          child: Text(
                            // Zet knoptekst
                            _isLogin
                                ? loc.loginNoAccountRegister
                                : loc.loginHaveAccountLogin,
                            style: const TextStyle(color: accentColor),
                          ),
                        ),
                        if (_isLogin) // Toon wachtwoord reset knop alleen bij login
                          TextButton(
                            // Creëer wachtwoord reset knop
                            onPressed: _isLoading
                                ? null
                                : _resetPassword, // Zet onPress handler
                            child: Text(
                              // Zet knoptekst
                              loc.loginForgotPassword,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        if (_isLogin) // Toon gast login knop alleen bij login
                          TextButton(
                            // Creëer gast login knop
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    // Async handler voor navigatie
                                    setState(
                                      () => _isLoading = true,
                                    ); // Toon laad indicator
                                    try {
                                      // Probeer navigatie
                                      if (!mounted)
                                        return; // Stop als widget weg is
                                      if (widget.returnAfterLogin) {
                                        // Moet teruggaan
                                        Navigator.of(
                                          context,
                                        ).pop(true); // Pop navigatie
                                      } else {
                                        // Anders ga naar home
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MainNavigation(),
                                          ),
                                        );
                                      }
                                    } finally {
                                      // Ook als geen fouten
                                      if (mounted)
                                        setState(
                                          () => _isLoading = false,
                                        ); // Verberg laad indicator
                                    }
                                  },
                            child: Text(
                              // Zet knoptekst
                              loc.loginContinueAsGuest,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        const SizedBox(height: 20), // Voeg verticale spatie toe
                        Row(
                          // Creëer horizontale rij
                          children: [
                            // Voeg kinderen toe
                            const Expanded(
                              // Voeg expandeerbare divider toe
                              child: Divider(color: Colors.white24),
                            ),
                            Padding(
                              // Voeg voor/na padding toe
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                // Creëer scheidingstekst
                                loc.loginOrDivider,
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Expanded(
                              // Voeg expandeerbare divider toe
                              child: Divider(color: Colors.white24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20), // Voeg verticale spatie toe
                        SignInButton(
                          // Creëer Google inlog knop
                          Buttons.Google,
                          text: loc.loginSignInWithGoogle,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () =>
                                    _signInWithGoogle(), // Zet onPress handler
                        ),
                        if (!kIsWeb && // Toon Apple knop alleen op iOS/macOS
                            (defaultTargetPlatform == TargetPlatform.iOS ||
                                defaultTargetPlatform ==
                                    TargetPlatform.macOS)) ...[
                          const SizedBox(
                            height: 12,
                          ), // Voeg verticale spatie toe
                          SignInButton(
                            // Creëer Apple inlog knop
                            Buttons.Apple,
                            text: loc.loginSignInWithApple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: _isLoading
                                ? null
                                : () =>
                                      signInWithApple(), // Zet onPress handler
                          ),
                        ],
                        const SizedBox(height: 12), // Voeg verticale spatie toe
                        SignInButton(
                          // Creëer GitHub inlog knop
                          Buttons.GitHub,
                          text: loc.loginSignInWithGitHub,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () =>
                                    _signInWithGitHub(), // Zet onPress handler
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

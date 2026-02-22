import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'homescreen.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  // statefulwidget betekent dat deze pagina kan veranderen, zoals de inhoud van de tekstvelden, of of er een foutmelding is. De LoginScreen heeft ook een optionele parameter returnAfterLogin, die bepaalt of we na het inloggen terug willen gaan naar het vorige scherm (zoals MovieDetailScreen) in plaats van naar de HomeScreen. Dit is handig als we willen dat gebruikers kunnen inloggen vanuit een detailpagina zonder dat ze eerst naar de homepagina hoeven te gaan.
  final bool returnAfterLogin;

  const LoginScreen({
    super.key,
    this.returnAfterLogin = false,
  }); //deze constructor maakt een LoginScreen aan, waarbij je kunt aangeven of je na het inloggen terug wilt gaan naar het vorige scherm (zoals MovieDetailScreen) in plaats van naar de HomeScreen. Standaard is dit false, wat betekent dat we na het inloggen naar de HomeScreen gaan.

  @override
  State<LoginScreen> createState() => _LoginScreenState();
  // De createState functie maakt de state aan voor deze pagina, wat betekent dat we een _LoginScreenState klasse hebben die alle logica en UI van deze pagina bevat.
}

class _LoginScreenState extends State<LoginScreen> {
  //deze klasse bevat alle logica en UI van de LoginScreen. Hierin hebben we onder andere tekstcontrollers voor het e-mail en wachtwoord veld, een boolean om bij te houden of we aan het inloggen zijn, een boolean om bij te houden of het wachtwoord zichtbaar is, en een boolean om bij te houden of we in de login modus zijn (of registratie modus). We hebben ook een StreamSubscription om te luisteren naar veranderingen in de authenticatiestatus van de gebruiker, zodat we automatisch kunnen navigeren als de gebruiker succesvol inlogt.
  StreamSubscription<User?>?
  _authSub; // voor de auth state listener dat is om automatisch te navigeren als de gebruiker succesvol inlogt
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _isLogin = true;

  @override
  void dispose() {
    // dispose is een functie die wordt aangeroepen wanneer deze pagina wordt gesloten. Hierin zorgen we ervoor dat we de auth state listener annuleren, en dat we de tekstcontrollers opruimen om geheugen
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // initState is een functie die wordt aangeroepen wanneer deze pagina voor het eerst wordt gemaakt. Hierin zetten we een listener op de auth state van FirebaseAuth, zodat we kunnen reageren wanneer de gebruiker inlogt of uitlogt. Als er een gebruiker is (dus als user != null), en deze pagina is nog steeds zichtbaar (mounted en isCurrent), dan navigeren we automatisch naar de HomeScreen of poppen we terug naar het vorige scherm, afhankelijk van de returnAfterLogin parameter.
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null &&
          mounted &&
          ModalRoute.of(context)?.isCurrent == true) {
        //als er een gebruiker is (dus als user != null), en deze pagina is nog steeds zichtbaar (mounted en isCurrent), dan navigeren we automatisch naar de HomeScreen of poppen we terug naar het vorige scherm, afhankelijk van de returnAfterLogin parameter.
        if (widget.returnAfterLogin) {
          Navigator.of(context).pop(true); // terug naar MovieDetailScreen
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    });
  }

  Future<void> _submit() async {
    // deze functie wordt aangeroepen wanneer de gebruiker op de inloggen/registreren knop drukt. Hierin valideren we eerst het formulier, en als dat goed is, zetten we _isLoading op true om aan te geven dat we bezig zijn. Vervolgens proberen we in te loggen of te registreren met FirebaseAuth, afhankelijk van of we in login modus of registratie modus zijn. Als dat succesvol is, navigeren we naar de HomeScreen (of poppen we terug naar het vorige scherm). Als er een fout is, tonen we een toast met de foutmelding. Ten slotte zetten we _isLoading weer op false.
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ); //na succesvol inloggen of registreren, navigeren we naar de HomeScreen. Als returnAfterLogin true is, zal de auth state listener in initState automatisch terug poppen naar het vorige scherm (zoals MovieDetailScreen) in plaats van naar de HomeScreen.
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Authenticatie mislukt');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Er is iets misgegaan');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<UserCredential> _signInWithGoogle() async {
    // deze functie wordt aangeroepen wanneer de gebruiker op de "Inloggen met Google" knop drukt. Hierin controleren we eerst of we op het web zitten, omdat Google Sign-In op het web een andere flow heeft (met een popup) dan op mobiele platforms. Als we op het web zitten, maken we een GoogleAuthProvider aan, vragen we om de email scope, en loggen we in met signInWithPopup. Als we niet op het web zitten, gebruiken we de google_sign_in package om de gebruiker te laten inloggen, halen we de idToken en accessToken op, maken we een Firebase credential aan, en loggen we in met signInWithCredential. We hebben ook foutafhandeling voor platform exceptions, zoals wanneer de gebruiker het inloggen annuleert.
    if (kIsWeb) {
      // Google Sign-In op het web
      final googleProvider = GoogleAuthProvider(); //maak google provider aan
      googleProvider.addScope('email'); //vraag email scope aan
      googleProvider.setCustomParameters({
        'prompt': 'select_account',
      }); //vraag account selectie
      return await FirebaseAuth.instance.signInWithPopup(
        googleProvider,
      ); //inloggen met popup
    }

    try {
      // Google Sign-In op mobiele platforms
      final googleSignIn = GoogleSignIn.instance;

      final googleUser = await googleSignIn.authenticate(); //vraag om inloggen

      final googleAuth =
          await googleUser.authentication; //haal authenticatie tokens op
      final idToken = googleAuth.idToken; //haal id token op
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: "Error retrieving Google ID token",
        );
      }

      // Sommige implementaties van Google Sign-In geven geen access token terug, en dat is prima. We proberen het op te halen, maar als het niet lukt, gaan we gewoon verder zonder access token.
      String? accessToken;
      try {
        // Als er geen autorisatie bestaat, vraag het aan met authorizeScopes.
        final scopes = <String>['openid', 'email', 'profile'];

        /// scopes die we willen
        var authorization = await googleUser.authorizationClient
            .authorizationForScopes(scopes); // check bestaande autorisatie
        authorization ??= await googleUser.authorizationClient.authorizeScopes(
          scopes, // vraag autorisatie aan
        );
        accessToken = authorization.accessToken;
      } catch (_) {
        // als je geen access token nodig hebt, mag je dit negeren
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        //maak firebase credential aan
        idToken: idToken,
        accessToken: accessToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(
        credential,
      ); //log in met credential
    } on PlatformException catch (e, s) {
      //specifieke foutafhandeling voor platform exceptions
      if (e.code.toLowerCase().contains('cancel')) {
        throw FirebaseAuthException(
          code: 'sign_in_cancelled',
          message: "Google sign-in cancelled",
        );
      }
      debugPrint('Google sign-in error: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Future<void> _signInWithGitHub() async {
    debugPrint('GitHubSignIn: Starting GitHub Sign-In...');
    setState(() => _isLoading = true);
    try {
      final provider = GithubAuthProvider();
      provider.addScope('read:user');
      provider.addScope('user:email');

      debugPrint('GitHubSignIn: Requesting sign-in from Firebase...');
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }

      debugPrint('GitHubSignIn: Sign-in successful');
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      debugPrint('GitHubSignIn: FirebaseAuthException: ${e.code} - ${e.message}');
      Fluttertoast.showToast(msg: e.message ?? 'GitHub login mislukt');
    } catch (e) {
      debugPrint('GitHubSignIn: Unexpected error: $e');
      Fluttertoast.showToast(msg: 'GitHub login mislukt');
    } finally {
      debugPrint('GitHubSignIn: Process finished');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String generateNonce([int length = 32]) {
    debugPrint('AppleSignIn: Generating nonce...');
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    final nonce = List.generate(
      length,
      (_) => charset[rand.nextInt(charset.length)],
    ).join();
    debugPrint('AppleSignIn: Raw nonce generated');
    return nonce;
  }

  String sha256ofString(String input) {
    debugPrint('AppleSignIn: Hashing nonce...');
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    final hash = digest.toString();
    debugPrint('AppleSignIn: Nonce hashed successfully');
    return hash;
  }

Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce(); // genereer nonce
    final nonce = sha256ofString(rawNonce); // maak sha256 van nonce
    // vraag om apple id credential
    final appleCredential = await SignInWithApple.getAppleIDCredential( // vraag apple id credential aan
      scopes: [ // de scopes die we willen
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    debugPrint(
      'AppleSignIn: appleCredential identityToken: ${appleCredential.identityToken != null}',
    );
    debugPrint(
      'AppleSignIn: givenName=${appleCredential.givenName}, familyName=${appleCredential.familyName}, email=${appleCredential.email}',
    );

    if (appleCredential.identityToken == null) { 
      //als er geen identity token is
      throw FirebaseAuthException(
        code: 'null_identity_token',
        message: "Apple Sign-In failed: no identity token returned",
      );
    }
    //maakt een oauth credential aan voor firebase
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken!,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    //logt in met firebase
    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      oauthCredential,
    );

    // Log wat Firebase teruggeeft
    final userBefore = FirebaseAuth.instance.currentUser;
    debugPrint(
      'AppleSignIn: currentUser before update: uid=${userBefore?.uid}, displayName=${userBefore?.displayName}',
    );

    // Als Apple returned givenName, bewaar die als displayName in Firebase Auth
    try {
      final given = appleCredential.givenName;
      if (userBefore != null &&
          given != null &&
          given.trim().isNotEmpty &&
          (userBefore.displayName == null ||
              userBefore.displayName!.trim().isEmpty)) {
        debugPrint('AppleSignIn: updating displayName to: $given');
        await userBefore.updateDisplayName(given.trim());
        await userBefore.reload();
      }
    } catch (e) {
      debugPrint('Apple sign-in: kon displayName niet updaten: $e');
    }

    final userAfter = FirebaseAuth.instance.currentUser;
    debugPrint(
      'AppleSignIn: currentUser after update: uid=${userAfter?.uid}, displayName=${userAfter?.displayName}',
    );
    debugPrint(
      'AppleSignIn: providerData=${userAfter?.providerData.map((p) => "${p.providerId}:${p.displayName}").toList()}',
    );

    return userCredential;
  }

  @override
  Widget build(BuildContext context) { // deze functie bouwt de UI van de LoginScreen. We gebruiken een Scaffold met een witte achtergrond, en in het midden van het scherm hebben we een Card met een formulier. Het formulier bevat tekstvelden voor e-mail en wachtwoord, een knop om in te loggen of registreren, en knoppen voor Google, GitHub, en Apple Sign-In. We hebben ook validatie op de tekstvelden, en tonen een CircularProgressIndicator wanneer we aan het inloggen zijn. De UI is responsive en ziet er netjes uit.
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(
                            Icons.movie_filter,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isLogin ? 'Welkom terug' : 'Maak een account',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Vul je e-mailadres in';
                            if (!EmailValidator.validate(v.trim()))
                              return 'Ongeldig e-mailadres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Wachtwoord',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Vul je wachtwoord in';
                            if (v.length < 6)
                              return 'Wachtwoord moet minstens 6 tekens zijn';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLogin ? 'Inloggen' : 'Registreren',
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => setState(() {
                                  _isLogin = !_isLogin;
                                }),
                          child: Text(
                            _isLogin
                                ? 'Nog geen account? Registreer'
                                : 'Al een account? Log in',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        if (_isLogin)
                          TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: const Text(
                              'Wachtwoord vergeten?',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),

                        SignInButton(
                          Buttons.Google,
                          text: 'Inloggen met Google',
                          onPressed: _isLoading
                              ? null
                              : () => _signInWithGoogle(),
                        ),

                        const SizedBox(height: 10),

                        SignInButton(
                          Buttons.GitHub,
                          text: 'Inloggen met GitHub',
                          onPressed: _isLoading
                              ? null
                              : () => _signInWithGitHub(),
                        ),

                        const SizedBox(height: 10),

                        if (!kIsWeb &&
                            (defaultTargetPlatform == TargetPlatform.iOS ||
                                defaultTargetPlatform == TargetPlatform.macOS))
                          SignInButton(
                            Buttons.Apple,
                            text: 'Inloggen met Apple',
                            onPressed: _isLoading
                                ? null
                                : () => signInWithApple(),
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

  Future<void> _resetPassword() async { // deze functie wordt aangeroepen wanneer de gebruiker op "Wachtwoord vergeten?" klikt. Hierin vragen we om het e-mailadres, valideren we het, en als het geldig is, sturen we een wachtwoord-reset e-mail via FirebaseAuth. We tonen ook feedback aan de gebruiker via SnackBar, afhankelijk van of het succesvol was of dat er een fout optrad.
    final email = _emailCtrl.text.trim(); //haal e-mailadres op uit het tekstveld en trim spaties
    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul een geldig e-mailadres in')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email); //stuur wachtwoord-reset e-mail via FirebaseAuth
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wachtwoord-reset e-mail verzonden')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Kon geen reset-e-mail sturen')),
      );
    }
  }
}

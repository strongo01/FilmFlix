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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<User?>? _authSub;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _isLogin = true;

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });
  }

  Future<void> _submit() async {
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
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Authenticatie mislukt');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Er is iets misgegaan');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

    Future<UserCredential> _signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider(); //maak google provider aan
      googleProvider.addScope('email'); //vraag email scope aan
      googleProvider.setCustomParameters({'prompt': 'select_account'}); //vraag account selectie
      return await FirebaseAuth.instance.signInWithPopup(googleProvider); //inloggen met popup
    } 

    try {
      final googleSignIn = GoogleSignIn.instance;

      final googleUser = await googleSignIn.authenticate(); //vraag om inloggen

      final googleAuth = await googleUser.authentication; //haal authenticatie tokens op
      final idToken = googleAuth.idToken; //haal id token op 
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: "Error retrieving Google ID token",
        );
      }

      // Optioneel: als je een accessToken nodig hebt voor Firebase/platforms:
      String? accessToken;
      try {

        // Als er geen autorisatie bestaat, vraag het aan met authorizeScopes.
        final scopes = <String>[
          'openid',
          'email',
          'profile',
        ]; /// scopes die we willen
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

      final credential = GoogleAuthProvider.credential( //maak firebase credential aan
        idToken: idToken,
        accessToken: accessToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential); //log in met credential
    } on PlatformException catch (e, s) { //specifieke foutafhandeling voor platform exceptions
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
    setState(() => _isLoading = true);
    try {
      final provider = GithubAuthProvider();
      provider.addScope('read:user');
      provider.addScope('user:email');

      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'GitHub login mislukt');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => charset[rand.nextInt(charset.length)],
    ).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      if (appleCredential.identityToken == null) {
        Fluttertoast.showToast(msg: 'Apple login mislukt');
        return;
      }

      final oauthCredential = OAuthProvider(
        "apple.com",
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'Apple login mislukt');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          onPressed: _isLoading ? null : () => _signInWithGoogle(),
                        ),

                        const SizedBox(height: 10),

                        SignInButton(
                          Buttons.GitHub,
                          text: 'Inloggen met GitHub',
                          onPressed: _isLoading ? null : () => _signInWithGitHub(),
                        ),

                        const SizedBox(height: 10),

                        if (!kIsWeb &&
                            (defaultTargetPlatform == TargetPlatform.iOS ||
                                defaultTargetPlatform == TargetPlatform.macOS))
                          SignInButton(
                            Buttons.Apple,
                            text: 'Inloggen met Apple',
                            onPressed: _isLoading ? null : () => _signInWithApple(),
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

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul een geldig e-mailadres in')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
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

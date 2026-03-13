import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cinetrackr/main.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:crypto/crypto.dart';

class LoginScreen extends StatefulWidget {
  final bool returnAfterLogin;

  const LoginScreen({
    super.key,
    this.returnAfterLogin = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<User?>? _authSub;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _isLogin = true;

  @override
  void dispose() {
    _authSub?.cancel();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null &&
          mounted &&
          ModalRoute.of(context)?.isCurrent == true) {
        if (widget.returnAfterLogin) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
        }
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
        final cred = await auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
        final user = cred.user;
        if (user != null) {
          await user.updateDisplayName(_nameCtrl.text.trim());
          await user.reload();
          // After reload, user is a new object from the SDK for safety
          final updatedUser = auth.currentUser;
          if (updatedUser != null) {
            final usersRef = FirebaseFirestore.instance.collection('users').doc(updatedUser.uid);
            await usersRef.set({
              'displayName': _nameCtrl.text.trim(),
              'email': updatedUser.email,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }
      if (!mounted) return;
      if (!widget.returnAfterLogin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
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
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.setCustomParameters({'prompt': 'select_account'});
      final userCred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      await _saveUserDoc(userCred.user);
      return userCred;
    }

    try {
      final googleSignIn = GoogleSignIn.instance;
      final googleUser = await googleSignIn.authenticate();
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing_id_token',
          message: "Error retrieving Google ID token",
        );
      }

      String? accessToken;
      try {
        final scopes = <String>['openid', 'email', 'profile'];
        var authorization = await googleUser.authorizationClient.authorizationForScopes(scopes);
        authorization ??= await googleUser.authorizationClient.authorizeScopes(scopes);
        accessToken = authorization.accessToken;
      } catch (_) {
        accessToken = null;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      await _saveUserDoc(userCred.user);
      return userCred;
    } on PlatformException catch (e) {
      if (e.code.toLowerCase().contains('cancel')) {
        throw FirebaseAuthException(
          code: 'sign_in_cancelled',
          message: "Google sign-in cancelled",
        );
      }
      rethrow;
    }
  }

  Future<void> _signInWithGitHub() async {
    setState(() => _isLoading = true);
    try {
      final provider = GithubAuthProvider();
      provider.addScope('read:user');
      provider.addScope('user:email');

      UserCredential? userCred;
      if (kIsWeb) {
        userCred = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        userCred = await FirebaseAuth.instance.signInWithProvider(provider);
      }

      await _saveUserDoc(userCred.user);
      if (!mounted) return;
      if (!widget.returnAfterLogin) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigation()));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'GitHub login mislukt');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)]).join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
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
      throw FirebaseAuthException(
        code: 'null_identity_token',
        message: "Apple Sign-In failed: no identity token returned",
      );
    }
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken!,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

    final userBefore = FirebaseAuth.instance.currentUser;
    try {
      final given = appleCredential.givenName;
      if (userBefore != null && given != null && given.trim().isNotEmpty &&
          (userBefore.displayName == null || userBefore.displayName!.trim().isEmpty)) {
        await userBefore.updateDisplayName(given.trim());
        await userBefore.reload();
      }
    } catch (e) {
      debugPrint('Apple sign-in: kon displayName niet updaten: $e');
    }

    final userAfter = FirebaseAuth.instance.currentUser;
    try {
      final uid = userAfter?.uid;
      final given = appleCredential.givenName?.trim();
      if (uid != null && given != null && given.isNotEmpty) {
        final usersRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final doc = await usersRef.get();
        final shouldSet = !doc.exists || (doc.data()?['displayName'] == null || (doc.data()?['displayName'] as String).trim().isEmpty);
        if (shouldSet) {
          await usersRef.set({
            'displayName': given,
            'email': appleCredential.email ?? userAfter?.email,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      debugPrint('AppleSignIn: failed to write user doc: $e');
    }

    return userCredential;
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vul een geldig e-mailadres in')));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wachtwoord-reset e-mail verzonden')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Kon geen reset-e-mail sturen')));
    }
  }

  Future<void> _saveUserDoc(User? user, {String? displayName}) async {
    if (user == null) return;
    final name = (displayName ?? user.displayName)?.trim();
    try {
      final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await usersRef.set({
        if (name != null && name.isNotEmpty) 'displayName': name,
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveUserDoc failed: $e');
    }
  }

  // --- STYLING METHODS ---

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF22404B).withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFF22404B);
    const Color cardColor = Color(0xFF2C4E5B);
    const Color accentColor = Color(0xFFFFC107);
    const Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.movie_filter_rounded, size: 48, color: accentColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isLogin ? 'Welkom bij CineTrackr' : 'Maak een account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(height: 32),
                        if (!_isLogin) ...[
                          _buildCustomTextField(
                            controller: _nameCtrl,
                            label: 'Naam',
                            icon: Icons.person_outline,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vul je naam in' : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildCustomTextField(
                          controller: _emailCtrl,
                          label: 'E-mail',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Vul je e-mailadres in';
                            if (!EmailValidator.validate(v.trim())) return 'Ongeldig e-mailadres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: _passwordCtrl,
                          label: 'Wachtwoord',
                          icon: Icons.lock_outline,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Vul je wachtwoord in';
                            if (v.length < 6) return 'Wachtwoord moet minstens 6 tekens zijn';
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF3B6372),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(_isLogin ? 'Inloggen' : 'Registreren', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _isLoading ? null : () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin ? 'Nog geen account? Registreer' : 'Al een account? Log in', style: const TextStyle(color: accentColor)),
                        ),
                        if (_isLogin)
                          TextButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: const Text('Wachtwoord vergeten?', style: TextStyle(color: Colors.white60, fontSize: 13)),
                          ),
                        const SizedBox(height: 20),
                        Row(children: [
                          const Expanded(child: Divider(color: Colors.white24)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("OF", style: TextStyle(color: Colors.white38, fontSize: 12))),
                          const Expanded(child: Divider(color: Colors.white24)),
                        ]),
                        const SizedBox(height: 20),
                        SignInButton(
                          Buttons.Google,
                          text: 'Inloggen met Google',
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onPressed: _isLoading ? null : () => _signInWithGoogle(),
                        ),
                        const SizedBox(height: 12),
                        SignInButton(
                          Buttons.GitHub,
                          text: 'Inloggen met GitHub',
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onPressed: _isLoading ? null : () => _signInWithGitHub(),
                        ),
                        if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS)) ...[
                          const SizedBox(height: 12),
                          SignInButton(
                            Buttons.Apple,
                            text: 'Inloggen met Apple',
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: _isLoading ? null : () => signInWithApple(),
                          ),
                        ],
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
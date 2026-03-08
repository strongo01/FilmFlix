import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

bool _tokenListenerAttached = false;

/// Register the current device FCM token for the given user in Firestore.
Future<void> registerFcmTokenForUser(User? user) async {
  if (user == null) return;
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (!_tokenListenerAttached) {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        final u = FirebaseAuth.instance.currentUser;
        if (u != null && newToken != null) {
          await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
            'fcmToken': newToken,
            'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
      _tokenListenerAttached = true;
    }
  } catch (e) {
    // ignore errors; token registration is best-effort
  }
}

/// Remove the stored FCM token for the given user.
Future<void> unregisterFcmTokenForUser(User? user) async {
  if (user == null) return;
  try {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await ref.set({
      'fcmToken': FieldValue.delete(),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  } catch (e) {
    // ignore
  }
}

import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

bool _tokenListenerAttached = false;

Future<bool> registerFcmTokenForUser(User? user) async {
  if (user == null) return false;
  try {
    // Request FCM permissions on platforms that require it.
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      debugPrint('FCM: requestPermission failed: $e');
    }

    // On iOS we need to ensure the APNs token has been received by the OS
    // before calling getToken(). If not present, wait briefly for token refresh.
    if (Platform.isIOS) {
      try {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        debugPrint('FCM: current APNS token = $apns');
        if (apns == null) {
          // wait up to 5s for onTokenRefresh to fire with a token
          final completer = Completer<void>();
          StreamSubscription<String?>? sub;
          sub = FirebaseMessaging.instance.onTokenRefresh.listen((_) {
            completer.complete();
            sub?.cancel();
          });
          try {
            await completer.future.timeout(const Duration(seconds: 5));
          } catch (_) {
            debugPrint('FCM: timeout waiting for APNS token');
          }
        }
      } catch (e) {
        debugPrint('FCM: error checking APNS token: $e');
      }
    }

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM: obtained token=$token for uid=${user.uid}');
    if (token != null) {
      final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await ref.set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('FCM: token written to users/${user.uid}');
    } else {
      debugPrint('FCM: getToken returned null for uid=${user.uid}');
      return false;
    }

    if (!_tokenListenerAttached) {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          final u = FirebaseAuth.instance.currentUser;
          debugPrint('FCM: onTokenRefresh newToken=$newToken for uid=${u?.uid}');
          if (u != null && newToken != null) {
            await FirebaseFirestore.instance.collection('users').doc(u.uid).set({
              'fcmToken': newToken,
              'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            debugPrint('FCM: refreshed token written to users/${u.uid}');
          }
        } catch (e) {
          debugPrint('FCM: error during onTokenRefresh handling: $e');
        }
      });
      _tokenListenerAttached = true;
    }

    return true;
  } catch (e) {
    debugPrint('FCM: registerFcmTokenForUser error: $e');
    return false;
  }
}

/// Remove the stored FCM token for the given user.
Future<bool> unregisterFcmTokenForUser(User? user) async {
  if (user == null) return false;
  try {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await ref.set({
      'fcmToken': FieldValue.delete(),
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    debugPrint('FCM: token removed for users/${user.uid}');
    return true;
  } catch (e) {
    debugPrint('FCM: unregisterFcmTokenForUser error: $e');
    return false;
  }
}

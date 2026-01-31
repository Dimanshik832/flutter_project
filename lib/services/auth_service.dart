import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'push_token_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> logout() async {
    try {
      await PushTokenService.clearFcmTokenAndUnsubscribe();
    } catch (e, stack) {
      debugPrint('AuthService.logout: failed to clear FCM token: $e');
      debugPrintStack(stackTrace: stack);
    }

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e, stack) {
      debugPrint('AuthService.logout: sign out failed: $e');
      debugPrintStack(stackTrace: stack);
    }
  }
}

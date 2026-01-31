import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'firestore_paths.dart';

class PushTokenService {
  static Future<void> saveFcmToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(
      {
        FirestoreUserFields.fcmToken: token,
        FirestoreUserFields.updatedAt: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> clearFcmToken(String uid) async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(uid)
        .update({
      FirestoreUserFields.fcmToken: FieldValue.delete(),
      FirestoreUserFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unsubscribeFromAllTopics() async {
    final messaging = FirebaseMessaging.instance;

    const topics = <String>[
      'admin',
      'user',
      'usernau',
      'firm_owner',
      'firmworker',
    ];

    await Future.wait(topics.map(messaging.unsubscribeFromTopic));
  }

  
  static Future<void> clearFcmTokenAndUnsubscribe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await clearFcmToken(uid);
    } catch (e, stack) {
      debugPrint('PushTokenService: failed to clear FCM token: $e');
      debugPrintStack(stackTrace: stack);
    }

    
    unawaited(() async {
      try {
        await unsubscribeFromAllTopics();
      } catch (e, stack) {
        debugPrint('PushTokenService: unsubscribe failed: $e');
        debugPrintStack(stackTrace: stack);
      }
    }());
  }
}



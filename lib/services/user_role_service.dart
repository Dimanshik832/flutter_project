import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_paths.dart';

class UserRoleService {
  static String? _cachedUid;
  static String? _cachedRole;
  static DateTime? _cachedAt;

  static const Duration _ttl = Duration(minutes: 5);

  static String normalizeRole(String? role) {
    final raw = (role ?? 'user')
        .toString()
        .trim()
        .replaceAll(' ', '')
        .toLowerCase();
    if (raw == 'firmowner') return 'firm_owner';
    return raw;
  }

  static void clearCache() {
    _cachedUid = null;
    _cachedRole = null;
    _cachedAt = null;
  }

  static Future<String?> getCurrentUserRole({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearCache();
      return null;
    }

    if (_cachedUid != user.uid) {
      clearCache();
      _cachedUid = user.uid;
    }

    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedRole != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) <= _ttl) {
      return _cachedRole;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      final role = normalizeRole(data?[FirestoreUserFields.role]?.toString());
      _cachedRole = role;
      _cachedAt = now;
      return role;
    } catch (e, stack) {
      debugPrint('UserRoleService: failed to fetch role: $e');
      debugPrintStack(stackTrace: stack);
      return _cachedRole;
    }
  }
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akademik_app/widgets/primary_button.dart';
import 'package:akademik_app/widgets/secondary_button.dart';
import 'package:akademik_app/l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AdminWhitelistScreen extends StatelessWidget {
  const AdminWhitelistScreen({super.key});

  Future<bool> _confirm(BuildContext context, String text) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.confirm),
        content: Text(text),
        actions: [
          SecondaryButton(
            text: l10n.cancel,
            onPressed: () => Navigator.pop(context, false),
          ),
          PrimaryButton(
            text: l10n.yes,
            onPressed: () => Navigator.pop(context, true),
            width: 80,
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _approve(
      BuildContext context,
      String uid,
      String requestId,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _confirm(context, l10n.approveThisUserQuestion);
    if (!ok) return;

    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).update({
        FirestoreUserFields.role: "user",
        FirestoreUserFields.applicationStatus: "approved",
      });

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.whitelistApplications)
          .doc(requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userApproved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorApprovingUser)),
      );
    }
  }

  Future<void> _reject(
      BuildContext context,
      String uid,
      String requestId,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await _confirm(context, l10n.rejectThisUserQuestion);
    if (!ok) return;

    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).update({
        FirestoreUserFields.applicationStatus: "rejected",
      });

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.whitelistApplications)
          .doc(requestId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userRejected)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorRejectingUser)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.whitelistApplications,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.whitelistApplications)
            .orderBy(FirestoreWhitelistApplicationFields.createdAt, descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text(
                l10n.errorWithDetails(snap.error.toString()),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                l10n.noPendingApplications,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54, 
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final entry = docs[i];
              final data = entry.data() as Map<String, dynamic>;

              final uid = data[FirestoreWhitelistApplicationFields.uid];
              final email = data[FirestoreUserFields.email] ?? "--";
              final fullName = data[FirestoreUserFields.fullName] ?? "--";
              final album = data[FirestoreUserFields.album] ?? "--";
              final createdAt =
                  (data[FirestoreWhitelistApplicationFields.createdAt] as Timestamp)
                      .toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${l10n.email}: $email",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    Text(
                      "${l10n.album}: $album",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.requestedAt(createdAt.toString().substring(0, 16)),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            text: l10n.approve,
                            onPressed: () =>
                                _approve(context, uid, entry.id),
                            backgroundColor: Colors.green,
                            fontSize: 15,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            text: l10n.reject,
                            onPressed: () =>
                                _reject(context, uid, entry.id),
                            backgroundColor: Colors.red,
                            fontSize: 15,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

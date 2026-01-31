import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class FirmMembersScreen extends StatelessWidget {
  const FirmMembersScreen({super.key});

  
  
  
  Stream<DocumentSnapshot<Map<String, dynamic>>?> _firmStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection(FirestoreCollections.firms)
        .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first);
  }

  
  
  
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _employeesStream(
      List<String> workerIds,
      ) {
    if (workerIds.isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .where(FieldPath.documentId, whereIn: workerIds)
        .snapshots()
        .map((snap) => snap.docs);
  }

  
  
  
  Future<void> _addEmployeeDialog(
      BuildContext context,
      String firmId,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.addEmployee),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.employeeEmail),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.addEmployeeAction),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invalidEmail),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _addEmployee(context, firmId, email);
  }

  
  
  
  Future<void> _addEmployee(
      BuildContext context,
      String firmId,
      String email,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final userSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .where(FirestoreUserFields.email, isEqualTo: email)
          .limit(1)
          .get();

      
      if (userSnap.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noUserWithThisEmailFound),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userDoc = userSnap.docs.first;
      final userId = userDoc.id;
      final role = (userDoc[FirestoreUserFields.role] ?? '').toString().toLowerCase();

      
      if (role != 'user' && role != 'usernau') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.firmMemberRoleNotAllowed),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      
      if (userDoc.data().containsKey('firmId')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.userAlreadyInFirm),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.runTransaction((txn) async {
        final firmRef =
        FirebaseFirestore.instance.collection(FirestoreCollections.firms).doc(firmId);
        final userRef =
        FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(userId);

        final firmData = (await txn.get(firmRef)).data()!;
        final workerIds =
        List<String>.from(firmData[FirestoreFirmFields.workerIds] ?? []);

        if (!workerIds.contains(userId)) {
          workerIds.add(userId);
        }

        txn.update(firmRef, {FirestoreFirmFields.workerIds: workerIds});
        txn.update(userRef, {
          FirestoreUserFields.role: 'firmworker',
          'firmId': firmId,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.employeeAdded),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorAddingEmployee),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
  
  
  Future<void> _removeEmployee(
      BuildContext context,
      String firmId,
      String uid,
      String email,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeEmployee),
        content: Text(l10n.removeEmployeeConfirm(email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final firmRef =
      FirebaseFirestore.instance.collection(FirestoreCollections.firms).doc(firmId);
      final userRef =
      FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid);

      final firmData = (await txn.get(firmRef)).data()!;
      final workerIds =
      List<String>.from(firmData[FirestoreFirmFields.workerIds] ?? []);

      workerIds.remove(uid);

      txn.update(firmRef, {FirestoreFirmFields.workerIds: workerIds});
      txn.update(userRef, {
        FirestoreUserFields.role: 'user',
        'firmId': FieldValue.delete(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.employeeRemoved)),
    );
  }

  
  
  
  Widget _employeeCard(
      BuildContext context,
      String firmId,
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final name = data[FirestoreUserFields.name] ?? '';
    final email = data[FirestoreUserFields.email] ?? '';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.withOpacity(0.15),
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                return Text(
              (name.isNotEmpty ? name[0] : email[0]).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final l10n = AppLocalizations.of(context)!;
                    return Text(
                  name.isEmpty ? l10n.noName : name,
                      style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                  ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                _removeEmployee(context, firmId, doc.id, email),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person_remove,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.firmMembers,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        stream: _firmStream(),
        builder: (context, firmSnap) {
          if (!firmSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final firmDoc = firmSnap.data;
          if (firmDoc == null) {
            return Center(child: Text(AppLocalizations.of(context)!.firmNotFound));
          }

          final firmId = firmDoc.id;
          final workerIds =
          List<String>.from(firmDoc[FirestoreFirmFields.workerIds] ?? []);

          return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: _employeesStream(workerIds),
            builder: (context, empSnap) {
              if (!empSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final employees = empSnap.data!;

              return Padding(
                padding: const EdgeInsets.all(20),
                child: employees.isEmpty
                    ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMembers,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView(
                  children: employees
                      .map((e) =>
                      _employeeCard(context, firmId, e))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        stream: _firmStream(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data == null) return const SizedBox();
          return FloatingActionButton(
            onPressed: () =>
                _addEmployeeDialog(context, snap.data!.id),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.person_add),
          );
        },
      ),
    );
  }
}

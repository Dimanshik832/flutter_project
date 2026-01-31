import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class FirmAssignWorkersScreen extends StatefulWidget {
  final String reportId;

  const FirmAssignWorkersScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<FirmAssignWorkersScreen> createState() =>
      _FirmAssignWorkersScreenState();
}

class _FirmAssignWorkersScreenState extends State<FirmAssignWorkersScreen> {
  bool _isLoading = true;
  String? _firmId;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _workers = [];

  
  final Set<String> _alreadyAssigned = {};

  
  final Set<String> _selectedNew = {};

  
  final Set<String> _removedWorkers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  
  
  
  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      
      final firmSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.firms)
          .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
          .limit(1)
          .get();

      if (firmSnap.docs.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final firmDoc = firmSnap.docs.first;
      _firmId = firmDoc.id;

      final workerIds =
      List<String>.from(firmDoc.data()[FirestoreFirmFields.workerIds] ?? const <String>[]);

      
      final reportSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .doc(widget.reportId)
          .get();

      final assigned = List<String>.from(
        reportSnap.data()?[FirestoreReportFields.assignedWorkerIds] ?? [],
      );

      _alreadyAssigned.addAll(assigned);

      
      if (workerIds.isNotEmpty) {
        final usersSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .where(FieldPath.documentId, whereIn: workerIds)
            .get();

        setState(() {
          _workers = usersSnap.docs;
          _isLoading = false;
        });
      } else {
        setState(() {
          _workers = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);

      _showDialog(
        title: AppLocalizations.of(context)!.error,
        message: AppLocalizations.of(context)!.errorWithDetails(e.toString()),
      );
    }
  }

  
  
  
  Future<void> _assignWorkers() async {
    try {
      final updatedAssigned = <String>{
        ..._alreadyAssigned,
        ..._selectedNew,
      };

      
      updatedAssigned.removeWhere((id) => _removedWorkers.contains(id));

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .doc(widget.reportId)
          .update({
        FirestoreReportFields.assignedWorkerIds: updatedAssigned.toList(),
        'assignedAt': Timestamp.now(),
      });

      await _showDialog(
        title: AppLocalizations.of(context)!.success,
        message: AppLocalizations.of(context)!.assignmentsUpdated,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showDialog(
        title: AppLocalizations.of(context)!.error,
        message: e.toString(),
      );
    }
  }

  
  
  
  Future<void> _showDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.ok),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _workerTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final id = doc.id;

    final name = data[FirestoreUserFields.name] ?? "";
    final email = data[FirestoreUserFields.email] ?? "";

    bool wasAssigned = _alreadyAssigned.contains(id);
    bool isRemoved = _removedWorkers.contains(id);
    bool isNew = _selectedNew.contains(id);

    bool isChecked = false;

    if (wasAssigned && !isRemoved) {
      isChecked = true; 
    } else if (isNew) {
      isChecked = true; 
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: isChecked,
        onChanged: (val) {
          setState(() {
            if (val == true) {
              
              if (wasAssigned) {
                _removedWorkers.remove(id); 
              } else {
                _selectedNew.add(id); 
              }
            } else {
              
              if (wasAssigned) {
                _removedWorkers.add(id); 
              } else {
                _selectedNew.remove(id);
              }
            }
          });
        },
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Text(
          name.isNotEmpty ? name : email,
              style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
          ),
            );
          },
        ),
        subtitle: Text(
          wasAssigned
              ? (isRemoved ? l10n.workerWillBeRemoved : l10n.workerAlreadyAssigned)
              : email,
          style: TextStyle(
            fontSize: 13,
            color: wasAssigned
                ? (isRemoved ? Colors.red : Colors.green)
                : (isDark ? Colors.grey[400] : Colors.black54),
            fontStyle: wasAssigned ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        secondary: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.withOpacity(0.12),
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Text(
            (name.isNotEmpty ? name[0] : email[0]).toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
              );
            },
          ),
        ),
      ),
    );
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
          l10n.assignWorkers,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
        child: _workers.isEmpty
            ? Center(
          child: Text(
            l10n.noWorkersFound,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.black54, 
              fontSize: 16
            ),
          ),
        )
            : ListView(
          children: _workers.map(_workerTile).toList(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _assignWorkers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                l10n.saveChanges,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

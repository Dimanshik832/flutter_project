import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firm_assign_workers_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AssignedReportsScreen extends StatefulWidget {
  const AssignedReportsScreen({super.key});

  @override
  State<AssignedReportsScreen> createState() => _AssignedReportsScreenState();
}

class _AssignedReportsScreenState extends State<AssignedReportsScreen> {
  String? _firmId;

  
  String _sortMode = "newest";

  
  final Map<String, DateTime> _deadlineMap = {};

  @override
  void initState() {
    super.initState();
    _loadFirmId();
  }

  
  
  
  Future<void> _loadFirmId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firms)
        .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return;

    setState(() {
      _firmId = snap.docs.first.id;
    });
  }

  
  
  
  Stream<List<DocumentSnapshot>> _assignedReportsStream(String firmId) {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .where(FirestoreReportFields.selectedApplicationId, isGreaterThan: '')
        .snapshots()
        .asyncMap((snap) async {
      _deadlineMap.clear();
      final List<DocumentSnapshot> assigned = [];

      for (final doc in snap.docs) {
        final String appId = doc[FirestoreReportFields.selectedApplicationId];

        final appSnap = await FirebaseFirestore.instance
            .collection(FirestoreCollections.firmApplications)
            .doc(appId)
            .get();

        if (!appSnap.exists) continue;

        if (appSnap['firmId'] == firmId && doc['status'] == 'In Progress') {
          assigned.add(doc);

          if (appSnap.data()?[FirestoreFirmApplicationFields.deadline] != null) {
            final ts = appSnap[FirestoreFirmApplicationFields.deadline] as Timestamp;
            _deadlineMap[doc.id] = ts.toDate();
          }
        }
      }

      _applySorting(assigned);
      return assigned;
    });
  }

  
  
  
  void _applySorting(List<DocumentSnapshot> list) {
    switch (_sortMode) {
      case "newest":
        list.sort((a, b) {
          final aDate =
              (a[FirestoreReportFields.createdAt] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bDate =
              (b[FirestoreReportFields.createdAt] as Timestamp?)?.toDate() ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });
        break;

      case FirestoreFirmApplicationFields.deadline:
        list.sort((a, b) {
          final da = _deadlineMap[a.id] ?? DateTime(2100);
          final db = _deadlineMap[b.id] ?? DateTime(2100);
          return da.compareTo(db);
        });
        break;

      case "alphabetic":
        list.sort((a, b) {
          final ta = (a[FirestoreReportFields.title] ?? "").toString().toLowerCase();
          final tb = (b[FirestoreReportFields.title] ?? "").toString().toLowerCase();
          return ta.compareTo(tb);
        });
        break;
    }
  }

  
  
  
  Future<void> _updateHistoryType({
    required String reportId,
    required String firmId,
    required String newType, 
  }) async {
    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firmHistory)
        .where('reportId', isEqualTo: reportId)
        .where('firmId', isEqualTo: firmId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return;

    await FirebaseFirestore.instance
        .collection(FirestoreCollections.firmHistory)
        .doc(snap.docs.first.id)
        .update({
      FirestoreFirmHistoryFields.type: newType,
      FirestoreFirmHistoryFields.timestamp: Timestamp.now(),
    });
  }

  
  
  
  Future<void> _cancelWork(String reportId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await _confirmDialog(
      title: l10n.cancelWork,
      text: l10n.cancelWorkConfirm,
    );
    if (!confirm) return;

    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(reportId).update({
      FirestoreReportFields.selectedApplicationId: null,
      'status': 'Review',
      FirestoreReportFields.sentToFirms: true,
      'cancelledAt': Timestamp.now(),
    });

    await _updateHistoryType(
      reportId: reportId,
      firmId: _firmId!,
      newType: 'cancelled',
    );

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.workCancelled)),
    );
  }

  
  
  
  Future<void> _markDone(String reportId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await _confirmDialog(
      title: l10n.markAsCompleted,
      text: l10n.markAsCompletedConfirm,
    );
    if (!confirm) return;

    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(reportId).update({
      'status': 'Completed',
      'completedAt': Timestamp.now(),
    });

    await _updateHistoryType(
      reportId: reportId,
      firmId: _firmId!,
      newType: 'completed',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.markedAsCompleted)),
    );
  }

  
  
  
  Future<bool> _confirmDialog({
    required String title,
    required String text,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  
  
  
  Widget _statusBadge(String status) {
    final l10n = AppLocalizations.of(context)!;
    Color color = Colors.grey;

    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'In Progress':
        color = Colors.orange;
        break;
      case 'Review':
        color = Colors.blue;
        break;
    }

    final label = switch (status) {
      'Completed' => l10n.completed,
      'In Progress' => l10n.inProgress,
      'Review' => l10n.review,
      _ => status,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  
  
  
  Widget _reportCard(DocumentSnapshot doc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final data = doc.data() as Map<String, dynamic>;
    final reportId = doc.id;

    final DateTime? deadline = _deadlineMap[reportId];
    final status = data['status'] ?? l10n.unknown;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data[FirestoreReportFields.title] ?? l10n.untitled,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${l10n.category}: ${data['category'] ?? ''}",
            style: TextStyle(
              fontSize: 14, 
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
          ),
          if (deadline != null) ...[
            const SizedBox(height: 6),
            Text(
              "${l10n.deadline}: ${deadline.day}.${deadline.month}.${deadline.year}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _actionButton(
              icon: Icons.group_add,
              label: l10n.assignWorkers,
              color: Colors.blue,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FirmAssignWorkersScreen(reportId: reportId),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.cancel,
                  label: l10n.cancel,
                  color: Colors.red,
                  onTap: () => _cancelWork(reportId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  icon: Icons.check_circle,
                  label: l10n.markAsCompleted,
                  color: Colors.green,
                  onTap: () => _markDone(reportId),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.assignedReports,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _firmId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<DocumentSnapshot>>(
        stream: _assignedReportsStream(_firmId!),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snap.data!;
          if (reports.isEmpty) {
            return Center(
              child: Text(
                l10n.noAssignedReports,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black54, 
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: reports.map(_reportCard).toList(),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_report_detail_screen.dart';

class FirmWonReportsScreen extends StatefulWidget {
  const FirmWonReportsScreen({super.key});

  @override
  State<FirmWonReportsScreen> createState() => _FirmWonReportsScreenState();
}

class _FirmWonReportsScreenState extends State<FirmWonReportsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadWonReports();
  }

  Future<void> _loadWonReports() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firmSnap = await FirebaseFirestore.instance
        .collection('firms')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (firmSnap.docs.isEmpty) return;
    final firmId = firmSnap.docs.first.id;

    final reportsSnap = await FirebaseFirestore.instance
        .collection('reports')
        .where('selectedApplicationId', isGreaterThan: '')
        .get();

    final firmReports = <DocumentSnapshot>[];

    for (final report in reportsSnap.docs) {
      final appId = report['selectedApplicationId'];
      final appSnap = await FirebaseFirestore.instance.collection('firmApplications').doc(appId).get();
      if (appSnap.exists && appSnap['firmId'] == firmId) {
        firmReports.add(report);
      }
    }

    setState(() {
      _reports = firmReports;
      _isLoading = false;
    });
  }

  void _openReportDetails(String reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminReportDetailScreen(
          reportId: reportId,
          isAdmin: false,
        ),
      ),
    );
  }

  Future<void> _cancelWork(String reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text('Are you sure you want to cancel this job?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'selectedApplicationId': null,
      'status': 'Review',
      'sentToFirms': true,
      'cancelledAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work has been cancelled and sent back to admin.')),
    );

    await _loadWonReports();
  }

  Future<void> _markAsCompleted(String reportId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Completed'),
        content: const Text('Are you sure the work has been completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'status': 'Completed',
      'completedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work marked as completed.')),
    );

    await _loadWonReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Won Reports')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
          ? const Center(child: Text('No won reports found.'))
          : ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final doc = _reports[index];
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'];
          final reportId = doc.id;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(data['title'] ?? 'No Title'),
                  subtitle: Text('Category: ${data['category']}\nStatus: $status'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _openReportDetails(reportId),
                ),
                if (status == 'In Progress')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _cancelWork(reportId),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel Work'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _markAsCompleted(reportId),
                          icon: const Icon(Icons.check),
                          label: const Text('Mark as Done'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

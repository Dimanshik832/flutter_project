import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'submit_application_screen.dart';
import 'firm_owner_panel_screen.dart';

class AvailableReportsScreen extends StatefulWidget {
  const AvailableReportsScreen({super.key});

  @override
  State<AvailableReportsScreen> createState() => _AvailableReportsScreenState();
}

class _AvailableReportsScreenState extends State<AvailableReportsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> _reports = [];
  String? _firmId;
  List<String> _firmCategories = [];
  Set<String> _appliedReportIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final firmSnap = await FirebaseFirestore.instance
        .collection('firms')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (firmSnap.docs.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final firm = firmSnap.docs.first;
    final firmId = firm.id;
    final categories = List<String>.from(firm['categories']);

    final applicationsSnap = await FirebaseFirestore.instance
        .collection('firmApplications')
        .where('firmId', isEqualTo: firmId)
        .get();

    _appliedReportIds = applicationsSnap.docs.map((e) => e['reportId'] as String).toSet();

    final reportsSnap = await FirebaseFirestore.instance
        .collection('reports')
        .where('sentToFirms', isEqualTo: true)
        .where('status', isEqualTo: 'Review')
        .get();

    final filteredReports = reportsSnap.docs.where((doc) {
      final category = doc['category'];
      return categories.contains(category);
    }).toList();

    setState(() {
      _firmId = firmId;
      _firmCategories = categories;
      _reports = filteredReports;
      _isLoading = false;
    });
  }

  void _openSubmitApplication(String reportId) async {
    if (_firmId == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubmitApplicationScreen(
          reportId: reportId,
          firmId: _firmId!,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FirmOwnerPanelScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Available Reports')),
      body: _reports.isEmpty
          ? const Center(child: Text('No reports available for your categories'))
          : ListView.builder(
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final report = _reports[index];
          final alreadyApplied = _appliedReportIds.contains(report.id);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(report['title'] ?? 'No Title'),
              subtitle: Text('Category: ${report['category']}'),
              trailing: alreadyApplied
                  ? const Icon(Icons.check_circle, color: Colors.grey)
                  : const Icon(Icons.arrow_forward_ios),
              onTap: alreadyApplied
                  ? null
                  : () => _openSubmitApplication(report.id),
            ),
          );
        },
      ),
    );
  }
}

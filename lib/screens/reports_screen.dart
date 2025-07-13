import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:akademik_app/models/report.dart';
import 'package:akademik_app/screens/edit_report_screen.dart';
import 'package:akademik_app/screens/admin_report_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  String selectedStatus = 'All';
  int selectedDays = 0; // 0 = All time
  int _limit = 10;

  final ScrollController _scrollController = ScrollController();
  List<Report> _allReports = [];
  List<Report> _filteredReports = [];
  String searchQuery = '';
  bool _hasMore = true;
  bool _isFetchingMore = false;
  bool _isLoading = false;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchInitialReports();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !_isFetchingMore &&
        _hasMore &&
        searchQuery.isEmpty) {
      _fetchMoreReports();
    }
  }

  Future<void> _fetchInitialReports() async {
    setState(() {
      _isLoading = true;
      _allReports = [];
      _filteredReports = [];
      _hasMore = true;
      _lastDoc = null;
    });
    await _fetchMoreReports(initial: true);
  }

  Future<void> _fetchMoreReports({bool initial = false}) async {
    _isFetchingMore = true;

    Query query = FirebaseFirestore.instance
        .collection('reports')
        .where('userEmail', isEqualTo: currentUserEmail)
        .orderBy('createdAt', descending: true);

    if (selectedStatus != 'All') {
      query = query.where('status', isEqualTo: selectedStatus);
    }

    if (selectedDays > 0) {
      final dateLimit = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: selectedDays)),
      );
      query = query.where('createdAt', isGreaterThanOrEqualTo: dateLimit);
    }

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.limit(_limit).get();
    final docs = snapshot.docs;

    if (docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      _isFetchingMore = false;
      return;
    }

    _lastDoc = docs.last;

    final reports = docs
        .map((doc) => Report.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    setState(() {
      _allReports.addAll(reports);
      _applySearchFilter();
      _isLoading = false;
    });

    _isFetchingMore = false;
  }

  void _applySearchFilter() {
    if (searchQuery.isEmpty) {
      _filteredReports = List.from(_allReports);
    } else {
      _filteredReports = _allReports.where((report) {
        return report.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            report.roomNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
            report.category.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
    });
    _applySearchFilter();
  }

  Future<void> _deleteReport(String reportId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('reports').doc(reportId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report deleted')));
      _fetchInitialReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting report: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedStatus,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                        _fetchInitialReports();
                      },
                      items: ['All', 'Submitted', 'Review', 'In Progress', 'Completed', 'Archived']
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: selectedDays,
                      onChanged: (value) {
                        setState(() {
                          selectedDays = value!;
                        });
                        _fetchInitialReports();
                      },
                      items: [0, 7, 30, 90]
                          .map((days) => DropdownMenuItem(
                        value: days,
                        child: Text(days == 0 ? 'All time' : 'Last $days days'),
                      ))
                          .toList(),
                    ),
                  ],
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Search by title, room, category'),
                  onChanged: _onSearchChanged,
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _filteredReports.length + (_isFetchingMore && _hasMore && searchQuery.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filteredReports.length) {
                    return const Padding(
                      padding: EdgeInsets.all(10),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final report = _filteredReports[index];
                  final hasImage = report.imageUrls.isNotEmpty;

                  return ListTile(
                    leading: hasImage
                        ? Image.network(
                      report.imageUrls.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                        : const Icon(Icons.image_not_supported),
                    title: Text('${report.title} (${report.category})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.description),
                        Text('Status: ${report.status}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: report.status == 'Submitted'
                          ? () => _deleteReport(report.id!, context)
                          : null,
                    ),
                    onTap: () {
                      if (report.status == 'Submitted') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditReportScreen(report: report),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminReportDetailScreen(reportId: report.id!, isAdmin: false),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

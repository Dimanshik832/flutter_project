import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_report_detail_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<DocumentSnapshot> _reports = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String selectedStatus = 'All';
  int selectedDays = 0; // 0 = All time
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchReports();
      }
    });
  }

  Future<void> _fetchReports() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(10);

    if (selectedDays > 0) {
      final dateLimit = Timestamp.fromDate(DateTime.now().subtract(Duration(days: selectedDays)));
      query = query.where('createdAt', isGreaterThanOrEqualTo: dateLimit);
    }

    if (selectedStatus != 'All') {
      query = query.where('status', isEqualTo: selectedStatus);
    }

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _reports.addAll(snapshot.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  void _updateStatus(String reportId, String newStatus, BuildContext context) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    setState(() {
      _reports.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _fetchReports();
  }

  void _archiveReport(String reportId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'status': 'Archived'});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report archived')));
    setState(() {
      _reports.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _fetchReports();
  }

  List<DocumentSnapshot> get _filteredReports {
    if (_searchQuery.isEmpty) return _reports;
    return _reports.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title']?.toString().toLowerCase() ?? '';
      final room = data['room']?.toString().toLowerCase() ?? '';
      final category = data['category']?.toString().toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return title.contains(q) || room.contains(q) || category.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Reports (Admin)')),
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
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedStatus = val;
                            _reports.clear();
                            _lastDocument = null;
                            _hasMore = true;
                          });
                          _fetchReports();
                        }
                      },
                      items: ['All', 'Submitted', 'Review', 'In Progress', 'Completed', 'Archived']
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: selectedDays,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedDays = val;
                            _reports.clear();
                            _lastDocument = null;
                            _hasMore = true;
                          });
                          _fetchReports();
                        }
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
                  controller: _searchController,
                  decoration: const InputDecoration(labelText: 'Search by title, room, category'),
                  onChanged: (val) => setState(() => _searchQuery = val),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _filteredReports.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredReports.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }

                final doc = _filteredReports[index];
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? '';
                final description = data['description'] ?? '';
                final email = data['userEmail'] ?? 'No Email';
                final status = data['status'] ?? 'Review';

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminReportDetailScreen(reportId: doc.id, isAdmin: true),
                        ),
                      );
                    },
                    title: Text(title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(description),
                        Text('User: $email', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        DropdownButton<String>(
                          value: status,
                          items: ['Submitted', 'Review', 'In Progress', 'Completed', 'Archived']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _updateStatus(doc.id, val, context);
                            }
                          },
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: () => _archiveReport(doc.id, context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

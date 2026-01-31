import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:akademik_app/models/report.dart';
import 'package:akademik_app/screens/student/edit_report_screen.dart';
import 'package:akademik_app/screens/admin/admin_report_detail_screen.dart';
import '../../main.dart';   
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with RouteAware {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  String selectedStatus = 'All';
  int selectedDays = 0;
  String searchQuery = '';

  int _limit = 10;
  bool _hasMore = true;
  bool _isFetching = false;
  bool _isLoading = false;

  DocumentSnapshot? _lastDoc;
  final ScrollController _scrollController = ScrollController();

  List<Report> _all = [];
  List<Report> _filtered = [];

  
  
  

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadFirstBatch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.unsubscribe(this);
    }

    _scrollController.dispose();
    super.dispose();
  }

  
  @override
  void didPopNext() {
    _loadFirstBatch();
  }

  
  
  

  void _scrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 140 &&
        !_isFetching &&
        _hasMore &&
        searchQuery.isEmpty) {
      _loadMore();
    }
  }

  Future<void> _loadFirstBatch() async {
    setState(() {
      _isLoading = true;
      _hasMore = true;
      _all.clear();
      _filtered.clear();
      _lastDoc = null;
    });

    await _loadMore();
  }

  Future<void> _loadMore() async {
    _isFetching = true;

    Query q = FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .where(FirestoreReportFields.userEmail, isEqualTo: currentUserEmail)
        .orderBy(FirestoreReportFields.createdAt, descending: true);

    if (selectedStatus != 'All') {
      q = q.where("status", isEqualTo: selectedStatus);
    }

    if (selectedDays > 0) {
      final limitDate = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: selectedDays)),
      );
      q = q.where(FirestoreReportFields.createdAt, isGreaterThanOrEqualTo: limitDate);
    }

    if (_lastDoc != null) q = q.startAfterDocument(_lastDoc!);

    final snap = await q.limit(_limit).get();

    if (snap.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
      _isFetching = false;
      return;
    }

    _lastDoc = snap.docs.last;

    final newData = snap.docs
        .map((d) => Report.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    setState(() {
      _all.addAll(newData);
      _applySearch();
      _isLoading = false;
    });

    _isFetching = false;
  }

  
  
  

  void _applySearch() {
    if (searchQuery.isEmpty) {
      _filtered = List.from(_all);
    } else {
      _filtered = _all.where((r) {
        final q = searchQuery.toLowerCase();
        return r.title.toLowerCase().contains(q) ||
            r.room.toLowerCase().contains(q) ||
            r.category.toLowerCase().contains(q);
      }).toList();
    }
  }

  
  
  

  Future<void> _deleteReport(String id) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(id).delete();
    _loadFirstBatch();
  }

  
  
  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.myReports,
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),

      body: Column(
        children: [
          _buildFilters(),

          _isLoading
              ? const Expanded(
              child: Center(child: CircularProgressIndicator()))
              : Expanded(child: _buildList()),
        ],
      ),
    );
  }

  
  
  

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              _dropdownStatus(),
              const SizedBox(width: 16),
              _dropdownDays(),
            ],
          ),
          const SizedBox(height: 6),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return TextField(
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchByTitleRoomCategory,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  filled: true,
                  fillColor: isDark ? theme.cardColor : Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  searchQuery = v.trim();
                  setState(() => _applySearch());
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dropdownStatus() {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        final statusLabels = {
          "All": l10n.all,
          "Submitted": l10n.submitted,
          "Review": l10n.review,
          "In Progress": l10n.inProgress,
          "Completed": l10n.completed,
          "Archived": l10n.archived,
        };
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButton<String>(
            value: selectedStatus,
            underline: const SizedBox(),
            style: TextStyle(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
            dropdownColor: isDark ? theme.cardColor : Colors.white,
            items: ["All", "Submitted", "Review", "In Progress", "Completed", "Archived"]
                .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(
                    statusLabels[v] ?? v,
                    style: TextStyle(
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ))
                .toList(),
            onChanged: (v) {
              selectedStatus = v!;
              _loadFirstBatch();
            },
          ),
        );
      },
    );
  }

  Widget _dropdownDays() {
    final l10n = AppLocalizations.of(context)!;
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButton<int>(
            value: selectedDays,
            underline: const SizedBox(),
            style: TextStyle(
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
            dropdownColor: isDark ? theme.cardColor : Colors.white,
            items: [
              DropdownMenuItem(
                value: 0,
                child: Text(
                  l10n.allTime,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 7,
                child: Text(
                  l10n.last7Days,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text(
                  l10n.last30Days,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: 90,
                child: Text(
                  l10n.last90Days,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
            onChanged: (v) {
              selectedDays = v!;
              _loadFirstBatch();
            },
          ),
        );
      },
    );
  }

  
  
  

  Widget _buildList() {
    final l10n = AppLocalizations.of(context)!;
    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          l10n.noReportsFound,
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length + (_isFetching && searchQuery.isEmpty ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _filtered.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _reportCard(_filtered[i]);
      },
    );
  }

  
  
  
  
  String _getLocalizedStatus(String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case "All":
        return l10n.all;
      case "Submitted":
        return l10n.submitted;
      case "Review":
        return l10n.review;
      case "In Progress":
        return l10n.inProgress;
      case "Completed":
        return l10n.completed;
      case "Archived":
        return l10n.archived;
      default:
        return status;
    }
  }

  Widget _reportCard(Report r) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        if (r.status == "Submitted") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditReportScreen(report: r)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AdminReportDetailScreen(reportId: r.id!, isAdmin: false),
            ),
          );
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: r.imageUrls.isNotEmpty
                  ? Image.network(
                r.imageUrls.first,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 70,
                height: 70,
                    color: isDark ? Colors.grey[800] : Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported, 
                      size: 32,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                        style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${l10n.status} ${_getLocalizedStatus(r.status)}",
                    style: TextStyle(
                      color: r.status == "Completed"
                          ? Colors.green
                          : Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Icon(
                Icons.delete,
                color: r.status == "Submitted"
                    ? Colors.red
                    : Colors.grey.shade400,
              ),
              onPressed:
              r.status == "Submitted" ? () => _deleteReport(r.id!) : null,
            ),
          ],
        ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_report_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AdminReportsScreen extends StatefulWidget {
  final String? initialStatus;

  const AdminReportsScreen({
    super.key,
    this.initialStatus,
  });

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<DocumentSnapshot> _reports = [];
  List<DocumentSnapshot> _searchResults = [];

  bool _loading = false;
  bool _hasMore = true;
  bool _searching = false;

  bool _allLoaded = false;
  bool _loadingAll = false;

  DocumentSnapshot? _last;

  String statusFilter = "All";
  int daysFilter = 0;
  String searchQuery = "";

  final statusOptions = [
    "Submitted",
    "Review",
    "In Progress",
    "Completed",
    "Archived",
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialStatus != null) {
      statusFilter = widget.initialStatus!;
    }

    _fetch();

    _scroll.addListener(() {
      if (!_searching &&
          !_loading &&
          _hasMore &&
          _scroll.position.pixels >
              _scroll.position.maxScrollExtent - 200) {
        _fetch();
      }
    });
  }

  
  
  
  Future<void> _fetch() async {
    if (_loading || !_hasMore) return;

    setState(() => _loading = true);

    Query q = FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .orderBy(FirestoreReportFields.createdAt, descending: true)
        .limit(15);

    if (statusFilter != "All") {
      q = q.where("status", isEqualTo: statusFilter);
    }

    if (daysFilter > 0) {
      final limit = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: daysFilter)),
      );
      q = q.where(FirestoreReportFields.createdAt, isGreaterThanOrEqualTo: limit);
    }

    if (_last != null) q = q.startAfterDocument(_last!);

    final snap = await q.get();

    if (snap.docs.isNotEmpty) {
      _last = snap.docs.last;
      _reports.addAll(snap.docs);
    } else {
      _hasMore = false;
    }

    setState(() => _loading = false);
  }

  
  
  
  Future<void> _loadAllForSearch() async {
    if (_allLoaded || _loadingAll) return;

    setState(() => _loadingAll = true);

    Query q = FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .orderBy(FirestoreReportFields.createdAt, descending: true);

    if (statusFilter != "All") {
      q = q.where("status", isEqualTo: statusFilter);
    }

    if (daysFilter > 0) {
      final limit = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: daysFilter)),
      );
      q = q.where(FirestoreReportFields.createdAt, isGreaterThanOrEqualTo: limit);
    }

    final snap = await q.get();

    setState(() {
      _reports = snap.docs;
      _allLoaded = true;
      _loadingAll = false;
    });
  }

  
  
  
  void _performSearch(String query) async {
    query = query.trim().toLowerCase();
    searchQuery = query;

    if (query.isEmpty) {
      setState(() {
        _searching = false;
        _searchResults = [];
      });
      return;
    }

    await _loadAllForSearch();

    final res = _reports.where((doc) {
      final d = doc.data() as Map<String, dynamic>;

      final title = (d[FirestoreReportFields.title] ?? '').toString().toLowerCase();
      final cat = (d['category'] ?? '').toString().toLowerCase();
      final room =
      (d['room'] ?? d[FirestoreReportFields.roomNumber] ?? '').toString().toLowerCase();

      return title.contains(query) ||
          cat.contains(query) ||
          room.contains(query);
    }).toList();

    setState(() {
      _searching = true;
      _searchResults = res;
    });
  }

  
  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(id).update({
      "status": status,
    });
    _reload();
  }

  Future<void> _archive(String id) async {
    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).doc(id).update({
      "status": "Archived",
    });
    _reload();
  }

  void _reload() {
    setState(() {
      _reports.clear();
      _searchResults.clear();
      _searching = false;
      _hasMore = true;
      _loading = false;
      _last = null;
      _allLoaded = false;
      _loadingAll = false;
    });
    _fetch();
  }

  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = _searching ? _searchResults : _reports;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
        title: Text(
          l10n.adminReports,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          _filters(),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text(l10n.noReportsFound))
                : ListView.builder(
              controller: _searching ? null : _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: list.length + (_loading && !_searching ? 1 : 0),
              itemBuilder: (_, i) {
                if (!_searching && i == list.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final doc = list[i];
                final data = doc.data() as Map<String, dynamic>;
                return _card(doc.id, data);
              },
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              _statusDropdown(),
              const SizedBox(width: 12),
              _daysDropdown(),
            ],
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;

              return TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: l10n.searchByTitleRoomCategory,
                  filled: true,
                  fillColor: isDark ? theme.cardColor : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onChanged: _performSearch,
              );
            },
          ),
        ],
      ),
    );
  }

  
  Widget _statusDropdown() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButton<String>(
            value: statusFilter,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: "All", child: Text(l10n.all)),
              ...statusOptions.map((v) {
                String label;
                switch (v) {
                  case "Submitted":
                    label = l10n.submitted;
                    break;
                  case "Review":
                    label = l10n.review;
                    break;
                  case "In Progress":
                    label = l10n.inProgress;
                    break;
                  case "Completed":
                    label = l10n.completed;
                    break;
                  case "Archived":
                    label = l10n.archived;
                    break;
                  default:
                    label = v;
                }
                return DropdownMenuItem(value: v, child: Text(label));
              }),
            ],
            onChanged: (v) {
              statusFilter = v!;
              _reload();
            },
          ),
        );
      },
    );
  }

  Widget _daysDropdown() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButton<int>(
            value: daysFilter,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(value: 0, child: Text(l10n.allTime)),
              DropdownMenuItem(value: 7, child: Text(l10n.last7Days)),
              DropdownMenuItem(value: 30, child: Text(l10n.last30Days)),
              DropdownMenuItem(value: 90, child: Text(l10n.last90Days)),
            ],
            onChanged: (v) {
              daysFilter = v!;
              _reload();
            },
          ),
        );
      },
    );
  }

  
  Widget _card(String id, Map<String, dynamic> d) {
    final l10n = AppLocalizations.of(context)!;

    final imgs = (d[FirestoreReportFields.images] ?? []).cast<String>();
    final title = d[FirestoreReportFields.title] ?? "";
    final status = d["status"] ?? "";
    final category = d["category"] ?? "";
    final room = d["room"] ?? d[FirestoreReportFields.roomNumber] ?? "";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminReportDetailScreen(reportId: id, isAdmin: true),
          ),
        );
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
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imgs.isNotEmpty
                      ? Image.network(
                    imgs.first,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$room • $category",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: status,
                          isDense: true,
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: statusOptions.map((s) {
                            String label;
                            switch (s) {
                              case "Submitted":
                                label = l10n.submitted;
                                break;
                              case "Review":
                                label = l10n.review;
                                break;
                              case "In Progress":
                                label = l10n.inProgress;
                                break;
                              case "Completed":
                                label = l10n.completed;
                                break;
                              case "Archived":
                                label = l10n.archived;
                                break;
                              default:
                                label = s;
                            }

                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: _statusColor(s),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) _updateStatus(id, v);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _archive(id),
                    icon: const Icon(
                      Icons.archive_rounded,
                      color: Colors.red,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Color _statusColor(String v) {
    switch (v) {
      case "Submitted":
        return Colors.blue;
      case "Review":
        return Colors.orange;
      case "In Progress":
        return Colors.indigo;
      case "Completed":
        return Colors.green;
      case "Archived":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

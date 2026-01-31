import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'submit_application_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';




class ReportDetailScreen extends StatelessWidget {
  final DocumentSnapshot doc;
  const ReportDetailScreen({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> imagesDynamic = (data[FirestoreReportFields.images] as List?) ?? [];
    final List<String> images =
    imagesDynamic.map((e) => e.toString()).toList();

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
          "${l10n.report} ${l10n.details}",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    data[FirestoreReportFields.title] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            
            _detailCard(
              context: context,
              title: l10n.description,
              child: Text(
                data['description'] ?? l10n.noDescription,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 18),

            
            _detailCard(
              context: context,
              title: l10n.category,
              child: Row(
                children: [
                  const Icon(Icons.category, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    data['category'] ?? "-",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            
            _detailCard(
              context: context,
              title: l10n.room,
              child: Row(
                children: [
                  const Icon(Icons.meeting_room, size: 20, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    data['room']?.toString() ?? "-",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            
            if (images.isNotEmpty)
              _detailCard(
                context: context,
                title: l10n.photos,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: images.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    final img = images[i];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                _ZoomNetworkImageScreen(imageUrl: img),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          img,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}




class _ZoomNetworkImageScreen extends StatelessWidget {
  final String imageUrl;

  const _ZoomNetworkImageScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.5,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}




class AvailableReportsScreen extends StatefulWidget {
  const AvailableReportsScreen({super.key});

  @override
  State<AvailableReportsScreen> createState() =>
      _AvailableReportsScreenState();
}

class _AvailableReportsScreenState extends State<AvailableReportsScreen> {
  String? _firmId;

  List<String> _firmCategories = ["All"];
  Set<String> _applied = {};

  String _search = "";
  String _selectedCategory = "All";
  String _sort = "Newest";

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirmData();
  }

  
  Future<void> _loadFirmData() async {
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

      _firmId = firmSnap.docs.first.id;

      final categories =
      List<String>.from(firmSnap.docs.first['categories'] ?? []);
      _firmCategories = ["All", ...categories];

      await _reloadApplied();

      setState(() => _isLoading = false);
    } catch (e, stack) {
      debugPrint('AvailableReportsScreen: failed to load data: $e');
      debugPrintStack(stackTrace: stack);
      setState(() => _isLoading = false);
    }
  }

  
  Future<void> _reloadApplied() async {
    if (_firmId == null) return;

    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firmApplications)
        .where('firmId', isEqualTo: _firmId)
        .get();

    setState(() {
      _applied = snap.docs.map((d) => d['reportId'] as String).toSet();
    });
  }

  
  Stream<List<DocumentSnapshot>> _availableReportsStream() {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .where(FirestoreReportFields.sentToFirms, isEqualTo: true)
        .where('status', isEqualTo: 'Review')
        .snapshots()
        .map((snap) => snap.docs);
  }

  
  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> input) {
    final out = <DocumentSnapshot>[];

    for (final doc in input) {
      final data = doc.data() as Map<String, dynamic>;
      final id = doc.id;

      if (_applied.contains(id)) continue;

      if (_selectedCategory != "All" &&
          data["category"] != _selectedCategory) {
        continue;
      }

      final title = (data[FirestoreReportFields.title] ?? "").toString();

      if (_search.isNotEmpty &&
          !title.toLowerCase().contains(_search.toLowerCase())) {
        continue;
      }

      out.add(doc);
    }

    out.sort((a, b) {
      final ad = (a[FirestoreReportFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bd = (b[FirestoreReportFields.createdAt] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0);

      if (_sort == "Newest") return bd.compareTo(ad);
      if (_sort == "Oldest") return ad.compareTo(bd);

      final at = (a[FirestoreReportFields.title] ?? '').toString().toLowerCase();
      final bt = (b[FirestoreReportFields.title] ?? '').toString().toLowerCase();
      return at.compareTo(bt);
    });

    return out;
  }

  
  Future<void> _openApplication(String reportId) async {
    if (_firmId == null) return;

    final ok = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SubmitApplicationScreen(reportId: reportId, firmId: _firmId!),
      ),
    );

    if (ok == true) {
      await _reloadApplied();
    }
  }

  
  Widget _reportCard(DocumentSnapshot doc) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final data = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(doc: doc),
        ),
      ),
      child: Container(
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
        child: Row(
          children: [
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data[FirestoreReportFields.title] ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['category'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _openApplication(doc.id),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.apply,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.availableReports,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _availableReportsStream(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final filtered = _applyFilters(snap.data!);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: l10n.searchReports,
                      hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                      border: InputBorder.none,
                      icon: const Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                    ),
                    onChanged: (v) {
                      _search = v;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 14),

                
                Row(
                  children: [
                    Flexible(
                      flex: 6,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? theme.cardColor : Colors.white,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(14),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: _firmCategories
                            .map(
                              (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              c == "All" ? l10n.all : c,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: (v) {
                          _selectedCategory = v ?? "All";
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 4,
                      child: DropdownButtonFormField<String>(
                        value: _sort,
                        isExpanded: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? theme.cardColor : Colors.white,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(14),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: "Newest",
                            child: Text(l10n.sortNewest),
                          ),
                          DropdownMenuItem(
                            value: "Oldest",
                            child: Text(l10n.sortOldest),
                          ),
                          DropdownMenuItem(
                            value: "Alphabetical",
                            child: Text(l10n.sortAz),
                          ),
                        ],
                        onChanged: (v) {
                          _sort = v ?? "Newest";
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                
                Expanded(
                  child: filtered.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: isDark ? Colors.grey[700] : Colors.black26,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.noAvailableReports,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[400] : Colors.black45,
                        ),
                      ),
                    ],
                  )
                      : ListView(
                    children: filtered.map(_reportCard).toList(),
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

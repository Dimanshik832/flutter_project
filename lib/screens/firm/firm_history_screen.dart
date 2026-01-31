import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../admin/admin_report_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class FirmHistoryScreen extends StatefulWidget {
  final String firmId;

  const FirmHistoryScreen({super.key, required this.firmId});

  @override
  State<FirmHistoryScreen> createState() => _FirmHistoryScreenState();
}

class _FirmHistoryScreenState extends State<FirmHistoryScreen> {
  String _filterStatus = "All";
  String _sortOrder = "Newest";

  
  
  
  Stream<List<DocumentSnapshot>> _historyStream() {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.firmHistory)
        .where('firmId', isEqualTo: widget.firmId)
        .snapshots()
        .map((snap) => snap.docs);
  }

  
  
  
  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> input) {
    var list = List<DocumentSnapshot>.from(input);

    if (_filterStatus != "All") {
      list = list.where((doc) {
        final type = (doc[FirestoreFirmHistoryFields.type] ?? '').toString();
        return type == _filterStatus.toLowerCase();
      }).toList();
    }

    list.sort((a, b) {
      final at =
          (a[FirestoreFirmHistoryFields.timestamp] as Timestamp?)?.toDate() ?? DateTime(2000);
      final bt =
          (b[FirestoreFirmHistoryFields.timestamp] as Timestamp?)?.toDate() ?? DateTime(2000);

      return _sortOrder == "Newest"
          ? bt.compareTo(at)
          : at.compareTo(bt);
    });

    return list;
  }

  
  
  
  Widget _statusBadge(String type) {
    final l10n = AppLocalizations.of(context)!;
    Color color;

    switch (type) {
      case "completed":
        color = Colors.green;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      case "assigned":
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }

    final label = switch (type) {
      "completed" => l10n.completed,
      "cancelled" => l10n.cancelled,
      "assigned" => l10n.assigned,
      _ => type,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  
  
  
  Widget _historyCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final l10n = AppLocalizations.of(context)!;

    final String title =
    (data[FirestoreFirmHistoryFields.title] ?? '').toString().isNotEmpty
        ? data[FirestoreFirmHistoryFields.title]
        : l10n.report;

    final String category =
    (data[FirestoreFirmHistoryFields.category] ?? '').toString().isNotEmpty
        ? data[FirestoreFirmHistoryFields.category]
        : l10n.unknown;

    final String type =
    (data[FirestoreFirmHistoryFields.type] ?? 'assigned').toString();

    final DateTime timestamp =
        (data[FirestoreFirmHistoryFields.timestamp] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);

    final readableDate =
        "${timestamp.day.toString().padLeft(2, '0')}"
        ".${timestamp.month.toString().padLeft(2, '0')}"
        ".${timestamp.year} "
        "${timestamp.hour.toString().padLeft(2, '0')}"
        ":${timestamp.minute.toString().padLeft(2, '0')}";

    return GestureDetector(
      onTap: () {
        if (data['reportId'] == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminReportDetailScreen(
              reportId: data['reportId'],
              isAdmin: false,
            ),
          ),
        );
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                _statusBadge(type),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              "${l10n.category}: $category",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              readableDate,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.black45,
              ),
            ),
          ],
        ),
          );
        },
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
          l10n.firmHistory,
          style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
                iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _filterStatus,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? theme.cardColor : Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: "All", child: Text(l10n.all)),
                      DropdownMenuItem(value: "Completed", child: Text(l10n.completed)),
                      DropdownMenuItem(value: "Cancelled", child: Text(l10n.cancelled)),
                      DropdownMenuItem(value: "Assigned", child: Text(l10n.assigned)),
                    ],
                    onChanged: (v) {
                      setState(() => _filterStatus = v!);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortOrder,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? theme.cardColor : Colors.white,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: "Newest", child: Text(l10n.sortNewest)),
                      DropdownMenuItem(value: "Oldest", child: Text(l10n.sortOldest)),
                    ],
                    onChanged: (v) {
                      setState(() => _sortOrder = v!);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _historyStream(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  final filtered = _applyFilters(snap.data!);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noHistoryRecords,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black45,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children:
                    filtered.map(_historyCard).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/admin_report_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class WorkerTaskCalendarScreen extends StatefulWidget {
  const WorkerTaskCalendarScreen({super.key});

  @override
  State<WorkerTaskCalendarScreen> createState() =>
      _WorkerTaskCalendarScreenState();
}

class _WorkerTaskCalendarScreenState extends State<WorkerTaskCalendarScreen> {
  bool _isLoading = true;

  
  Map<String, List<Map<String, dynamic>>> _grouped = {};

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  
  
  
  Future<void> _loadCalendar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .where(FirestoreReportFields.assignedWorkerIds, arrayContains: uid)
          .get();

      Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var doc in snap.docs) {
        final data = doc.data();
        final String? selectedAppId = data[FirestoreReportFields.selectedApplicationId];

        
        final DateTime start =
        (data["assignedAt"] ?? data[FirestoreReportFields.createdAt] ?? Timestamp.now())
            .toDate();

        
        DateTime deadline;

        if (selectedAppId != null) {
          final appDoc = await FirebaseFirestore.instance
              .collection(FirestoreCollections.firmApplications)
              .doc(selectedAppId)
              .get();

          if (appDoc.exists && appDoc.data()![FirestoreFirmApplicationFields.deadline] != null) {
            deadline = (appDoc.data()![FirestoreFirmApplicationFields.deadline] as Timestamp).toDate();
          } else {
            deadline = start.add(const Duration(days: 3));
          }
        } else {
          deadline = start.add(const Duration(days: 3));
        }

        final key =
            "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";

        grouped[key] ??= [];
        grouped[key]!.add({
          "id": doc.id,
          "data": data,
          "start": start,
          FirestoreFirmApplicationFields.deadline: deadline,
        });
      }

      
      final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

      Map<String, List<Map<String, dynamic>>> sorted = {};
      for (var k in sortedKeys) {
        grouped[k]!.sort((a, b) => a[FirestoreFirmApplicationFields.deadline].compareTo(b[FirestoreFirmApplicationFields.deadline]));
        sorted[k] = grouped[k]!;
      }

      setState(() {
        _grouped = sorted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorWithDetails(e.toString()))));
    }
  }

  
  
  
  Color _deadlineColor(DateTime deadline) {
    final now = DateTime.now();
    if (deadline.isBefore(now)) return Colors.red;
    if (deadline.difference(now).inDays <= 2) return Colors.orange;
    return Colors.green;
  }

  
  
  
  Widget _taskItem(Map<String, dynamic> task) {
    final l10n = AppLocalizations.of(context)!;
    final data = task["data"];
    final String id = task["id"];
    final DateTime start = task["start"];
    final DateTime deadline = task[FirestoreFirmApplicationFields.deadline];

    final String statusRaw = data["status"] ?? "Unknown";
    final String status = switch (statusRaw) {
      "Completed" => l10n.completed,
      "In Progress" => l10n.inProgress,
      "Review" => l10n.review,
      _ => l10n.unknown,
    };

    Color statusColor;
    switch (statusRaw) {
      case "Completed":
        statusColor = Colors.green;
        break;
      case "In Progress":
        statusColor = Colors.orange;
        break;
      case "Review":
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdminReportDetailScreen(reportId: id, isAdmin: false),
          ),
        );
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          
          return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(26),
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
            
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Row(
              children: [
                    CircleAvatar(
                  radius: 24,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                      child: const Icon(Icons.work, color: Colors.blue),
                ),
                const SizedBox(width: 14),

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

                
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
                );
              },
            ),

            const SizedBox(height: 16),

            
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
              "${l10n.startDate}: ${start.day}.${start.month}.${start.year}",
                  style: TextStyle(
                fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.black54,
              ),
                );
              },
            ),
            Text(
              "${l10n.deadline}: ${deadline.day}.${deadline.month}.${deadline.year}",
              style: TextStyle(
                fontSize: 14,
                color: _deadlineColor(deadline),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
          );
        },
      ),
    );
  }

  
  
  
  Widget _daySection(String date, List<Map<String, dynamic>> tasks) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
              style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        ...tasks.map(_taskItem),
        const SizedBox(height: 26),
      ],
        );
      },
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
          l10n.taskCalendar,
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
          : _grouped.isEmpty
          ? Center(
        child: Text(
          l10n.noTasksYet,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.black54, 
            fontSize: 16
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: _grouped.entries
              .map((e) => _daySection(e.key, e.value))
              .toList(),
        ),
      ),
    );
  }
}

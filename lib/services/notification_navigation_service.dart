import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/admin/admin_report_detail_screen.dart';
import '../screens/admin/admin_whitelist_screen.dart';
import '../screens/firm/assigned_reports_screen.dart';
import '../screens/firm/available_reports_screen.dart';
import '../screens/worker/worker_task_calendar_screen.dart';
import '../screens/student/announcement_detail_screen.dart';
import '../screens/shared/home_screen.dart';
import 'user_role_service.dart';
import 'firestore_paths.dart';

class NotificationNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> handleNotificationTap(Map<String, dynamic> data) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final type = data['type'] as String?;
    if (type == null) return;

    final role = await UserRoleService.getCurrentUserRole();
    final isAdmin = role == 'admin';
    final isFirmOwner = role == 'firm_owner' || role == 'firmowner';

    bool openDetail = false;
    try {
      final raw = (data['open'] ?? data['target'] ?? '').toString().trim().toLowerCase();
      openDetail = raw == 'detail';
    } catch (e, stack) {
      debugPrint('NotificationNavigationService: invalid open/target: $e');
      debugPrintStack(stackTrace: stack);
    }

    switch (type) {
      case 'DEBUG_PUSH':
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        break;

      case 'REPORT_CREATED':
        final reportId = data['reportId'] as String?;
        if (reportId != null) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: true,
              ),
            ),
          );
        }
        break;

      case 'REPORT_STATUS_CHANGED':
        final reportId = data['reportId'] as String?;
        if (reportId != null) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
        break;

      case 'REPORT_SENT_TO_FIRMS':
        final reportId = data['reportId'] as String?;
        if (isFirmOwner) {
          if (openDetail && reportId != null) {
            final ok = await _navigateToFirmReportDetail(reportId, navigator);
            if (!ok) {
              navigator.push(
                MaterialPageRoute(builder: (_) => const AvailableReportsScreen()),
              );
            }
          } else {
            navigator.push(
              MaterialPageRoute(builder: (_) => const AvailableReportsScreen()),
            );
          }
          break;
        }

        if (reportId != null) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
        break;

      case 'FIRM_APPLIED_TO_REPORT':
        final reportId = data['reportId'] as String?;
        if (reportId != null && isAdmin) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: true,
              ),
            ),
          );
        }
        break;

      case 'FIRM_SELECTED':
        if (isFirmOwner) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => const AssignedReportsScreen(),
            ),
          );
        } else {
          final reportId = data['reportId'] as String?;
          if (reportId != null) {
            navigator.push(
              MaterialPageRoute(
                builder: (_) => AdminReportDetailScreen(
                  reportId: reportId,
                  isAdmin: isAdmin,
                ),
              ),
            );
          }
        }
        break;

      case 'WORKER_ASSIGNED':
        if (role == 'firmworker') {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => const WorkerTaskCalendarScreen(),
            ),
          );
        }
        break;

      case 'WORK_CANCELLED':
        final reportId = data['reportId'] as String?;
        if (reportId != null && isAdmin) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: true,
              ),
            ),
          );
        }
        break;

      case 'WORK_COMPLETED':
        final reportId = data['reportId'] as String?;
        if (reportId != null) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => AdminReportDetailScreen(
                reportId: reportId,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
        break;

      case 'ANNOUNCEMENT':
        final announcementId = data['announcementId'] as String?;
        if (announcementId != null) {
          await _navigateToAnnouncement(announcementId, navigator);
        }
        break;

      case 'WHITELIST_REQUEST':
        if (isAdmin) {
          navigator.push(
            MaterialPageRoute(
              builder: (_) => const AdminWhitelistScreen(),
            ),
          );
        }
        break;

      case 'WHITELIST_APPROVED':
      case 'WHITELIST_REJECTED':
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
          (route) => false,
        );
        break;
    }
  }

  static Future<bool> _navigateToFirmReportDetail(
      String reportId, NavigatorState navigator) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .doc(reportId)
          .get();
      if (!doc.exists) return false;

      navigator.push(
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(doc: doc),
        ),
      );
      return true;
    } catch (e, stack) {
      debugPrint('NotificationNavigationService: failed to open firm report: $e');
      debugPrintStack(stackTrace: stack);
      return false;
    }
  }

  static Future<void> _navigateToAnnouncement(
      String announcementId, NavigatorState navigator) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.announcements)
          .doc(announcementId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final title = (data[FirestoreAnnouncementFields.title] ?? '') as String;
      final text = (data[FirestoreAnnouncementFields.text] ?? '') as String;
      final type = data[FirestoreAnnouncementFields.type] as String?;
      final authorEmail = data[FirestoreAnnouncementFields.authorEmail] as String?;
      final images = data[FirestoreAnnouncementFields.images] as List<dynamic>?;

      DateTime? createdAt;
      if (data[FirestoreAnnouncementFields.createdAt] != null) {
        try {
          createdAt = (data[FirestoreAnnouncementFields.createdAt] as Timestamp).toDate();
        } catch (e, stack) {
          debugPrint('NotificationNavigationService: invalid createdAt: $e');
          debugPrintStack(stackTrace: stack);
        }
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => AnnouncementDetailScreen(
            title: title,
            text: text,
            type: type,
            createdAt: createdAt,
            authorEmail: authorEmail,
            images: images?.map((e) => e.toString()).toList(),
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('NotificationNavigationService: failed to open announcement: $e');
      debugPrintStack(stackTrace: stack);
    }
  }
}


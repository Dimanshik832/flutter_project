import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:akademik_app/l10n/app_localizations.dart';

import 'package:akademik_app/screens/shared/home_screen.dart';
import 'package:akademik_app/screens/student/reports_screen.dart';
import 'package:akademik_app/screens/student/add_report_screen.dart';
import 'package:akademik_app/screens/shared/profile_screen.dart';
import 'package:akademik_app/screens/shared/settings_screen.dart';
import 'package:akademik_app/screens/shared/edit_profile_screen.dart';
import 'package:akademik_app/screens/shared/auth_screen.dart';
import 'package:akademik_app/screens/shared/verify_email_screen.dart';

import 'package:akademik_app/screens/admin/admin_reports_screen.dart';
import 'package:akademik_app/screens/admin/admin_dashboard_screen.dart';
import 'package:akademik_app/screens/admin/add_announcement_screen.dart';
import 'package:akademik_app/screens/admin/manage_categories_screen.dart';
import 'package:akademik_app/screens/admin/manage_participants_screen.dart';
import 'package:akademik_app/screens/admin/admin_whitelist_screen.dart';
import 'package:akademik_app/screens/admin/admin_report_detail_screen.dart';

import 'package:akademik_app/screens/firm/firm_owner_panel_screen.dart';
import 'package:akademik_app/screens/firm/assigned_reports_screen.dart';
import 'package:akademik_app/screens/firm/available_reports_screen.dart';
import 'package:akademik_app/screens/firm/firm_members_screen.dart';
import 'package:akademik_app/screens/firm/firm_history_screen.dart';
import 'package:akademik_app/screens/firm/firm_statistics_screen.dart';
import 'package:akademik_app/screens/firm/register_firm_screen.dart';
import 'package:akademik_app/screens/firm/firm_assign_workers_screen.dart';
import 'package:akademik_app/screens/firm/submit_application_screen.dart';

import 'package:akademik_app/screens/worker/worker_task_calendar_screen.dart';

import 'package:akademik_app/screens/student/edit_report_screen.dart';
import 'package:akademik_app/screens/student/announcements_screen.dart';
import 'package:akademik_app/screens/student/announcement_detail_screen.dart';
import '../../services/firestore_paths.dart';

class DebugToolsScreen extends StatefulWidget {
  const DebugToolsScreen({super.key});

  @override
  State<DebugToolsScreen> createState() => _DebugToolsScreenState();
}

class _DebugToolsScreenState extends State<DebugToolsScreen> {
  final Random rand = Random();

  final List<String> _categories = [
    "Plumbing",
    "Electrical",
    "Heating",
    "Water Leak",
    "Internet",
    "Furniture",
    "Security",
    "Cleaning",
    "Windows",
    "Doors",
    "Lighting",
    "Fire Safety",
    "Bathroom",
    "Kitchen",
    "Walls & Ceiling",
    "Floor Damage",
    "Appliances",
    "HVAC",
    "Noise Issue",
    "General Maintenance",
  ];

  final List<String> _descriptions = [
    "Water is leaking heavily and creating a puddle. Needs immediate attention.",
    "Lights are flickering and sometimes turning off completely.",
    "Strange noise coming from the heating system.",
    "Internet keeps disconnecting every 5 minutes.",
    "Door lock seems broken, hard to open or close.",
    "Furniture leg is broken and the chair is unstable.",
    "Ceiling shows signs of water damage and discoloration.",
    "Window does not close properly, cold air comes in.",
    "Fire alarm keeps beeping randomly during the night.",
    "Bad smell coming from the bathroom drainage.",
    "Kitchen sink is clogged and drains very slowly.",
    "HVAC system is blowing warm air instead of cold.",
    "Floor tiles are cracked and need replacement.",
    "There is mold forming behind the wardrobe.",
    "Security camera is offline and not recording.",
    "Noise complaint: neighbour drilling loudly at night.",
    "Strong humidity in room, walls feel wet.",
    "Washing machine makes loud banging noises.",
    "Electrical outlet sparked when plugging a device.",
    "General maintenance needed in this area.",
  ];

  final List<String> _names = [
    "Alex Johnson",
    "Maria Lopez",
    "David Kim",
    "Sofia Petrova",
    "Liam Brown",
    "Emma Wilson",
    "Noah Anderson",
    "Olivia Carter",
    "James Lee",
    "Mia Chen",
    "Benjamin Clark",
    "Ava Lewis",
    "Lucas Walker",
    "Isabella Young",
  ];

  final List<String> _statuses = [
    "Submitted",
    "Review",
    "In Progress",
    "Completed",
    "Archived",
  ];

  bool _loading = false;

  Timestamp _randomCreatedAt({int startYear = 2019}) {
    final now = DateTime.now();
    final year = rand.nextInt(now.year - startYear + 1) + startYear;
    final month = rand.nextInt(12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = rand.nextInt(lastDay) + 1;

    return Timestamp.fromDate(
      DateTime(
        year,
        month,
        day,
        rand.nextInt(24),
        rand.nextInt(60),
        rand.nextInt(60),
      ),
    );
  }

  List<String> _generateRandomImages() {
    final count = rand.nextInt(4);
    return List.generate(
      count,
      (_) => "https://picsum.photos/seed/${rand.nextInt(9999)}/800/600",
    );
  }

  Future<void> _deleteAllReports() async {
    setState(() => _loading = true);

    final snap =
    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).get();

    for (final doc in snap.docs) {
      await doc.reference.delete();
    }

    if (!mounted) return;
    setState(() => _loading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.devAllReportsDeleted)),
    );
  }

  Future<void> _generateReports(int count) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);

    for (int i = 0; i < count; i++) {
      final category = _categories[rand.nextInt(_categories.length)];
      final description =
      _descriptions[rand.nextInt(_descriptions.length)];
      final name = _names[rand.nextInt(_names.length)];
      final email =
          name.toLowerCase().replaceAll(" ", ".") + "@example.com";
      final status = _statuses[rand.nextInt(_statuses.length)];

      await FirebaseFirestore.instance.collection(FirestoreCollections.reports).add({
        FirestoreReportFields.title: l10n.testReportTitle(i),
        "description": description,
        "category": category,
        "room": (rand.nextInt(400) + 100).toString(),
        FirestoreReportFields.images: _generateRandomImages(),
        "userName": name,
        FirestoreReportFields.userEmail: email,
        FirestoreReportFields.userId: "testUser",
        FirestoreReportFields.createdAt: _randomCreatedAt(),
        "status": status,
        FirestoreReportFields.sentToFirms: status != "Submitted",
        "isTestData": true,
      });
    }

    if (!mounted) return;
    setState(() => _loading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.devCreatedTestReports(count))),
    );
  }

  Future<void> _sendAllToFirms() async {
    setState(() => _loading = true);

    final snap =
    await FirebaseFirestore.instance.collection(FirestoreCollections.reports).get();

    for (final doc in snap.docs) {
      await doc.reference.update({
        FirestoreReportFields.sentToFirms: true,
        "status": "Review",
      });
    }

    if (!mounted) return;
    setState(() => _loading = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.devAllReportsSentToFirms)),
    );
  }

  Future<void> _sendTestPush() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection(FirestoreCollections.debugPushQueue).add({
      FirestoreDebugPushFields.userId: user.uid,
      FirestoreDebugPushFields.title: l10n.testNotificationTitle,
      FirestoreDebugPushFields.body: l10n.testNotificationBody,
      FirestoreDebugPushFields.createdAt: FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.devTestPushEnqueued)),
    );
  }


  Widget _actionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: _loading ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.developerTools,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(l10n.devNavigation),
                  _actionCard(
                    title: l10n.devViewAllScreens,
                    icon: Icons.apps_rounded,
                    iconColor: Colors.blue,
                    subtitle: l10n.devBrowseAllScreens,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllScreensScreen(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _sectionTitle(l10n.devDataUtils),
                  _actionCard(
                    title: l10n.devDeleteAllReports,
                    icon: Icons.delete_forever_rounded,
                    iconColor: Colors.red,
                    subtitle: l10n.devRemoveAllReportsSubtitle,
                    onTap: _deleteAllReports,
                  ),
                  _actionCard(
                    title: l10n.devGenerateTestReports,
                    icon: Icons.add_circle_outline_rounded,
                    iconColor: Colors.green,
                    subtitle: l10n.devCreate500TestReports,
                    onTap: () => _generateReports(500),
                  ),
                  _actionCard(
                    title: l10n.sendToFirms,
                    icon: Icons.send_rounded,
                    iconColor: Colors.orange,
                    subtitle: l10n.devAllReportsSentToFirms,
                    onTap: _sendAllToFirms,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _sectionTitle(l10n.notifications),
                  _actionCard(
                    title: l10n.devSendTestPush,
                    icon: Icons.notifications_active_rounded,
                    iconColor: Colors.purple,
                    subtitle: l10n.devQueueTestNotification,
                    onTap: _sendTestPush,
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class AllScreensScreen extends StatelessWidget {
  const AllScreensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    final screens = [
      _ScreenItem(l10n.home, Icons.home_rounded, const HomeScreen()),
      _ScreenItem(l10n.reports, Icons.list_alt_rounded, const ReportsScreen()),
      _ScreenItem(l10n.addReport, Icons.add_circle_rounded, const AddReportScreen()),
      _ScreenItem(l10n.profile, Icons.person_rounded, const ProfileScreen()),
      _ScreenItem(l10n.settings, Icons.settings_rounded, const SettingsScreen()),
      _ScreenItem(l10n.editProfile, Icons.edit_rounded, const EditProfileScreen()),
      _ScreenItem(l10n.auth, Icons.login_rounded, const AuthScreen()),
      _ScreenItem(l10n.verifyYourEmail, Icons.email_rounded, const VerifyEmailScreen()),
      _ScreenItem(l10n.adminReports, Icons.admin_panel_settings_rounded, const AdminReportsScreen()),
      _ScreenItem(l10n.adminDashboard, Icons.dashboard_rounded, const AdminDashboardScreen()),
      _ScreenItem(l10n.addAnnouncement, Icons.announcement_rounded, const AddAnnouncementScreen()),
      _ScreenItem(l10n.manageCategories, Icons.category_rounded, const ManageCategoriesScreen()),
      _ScreenItem(l10n.manageParticipants, Icons.people_rounded, const ManageParticipantsScreen()),
      _ScreenItem(l10n.whitelistApplications, Icons.verified_user_rounded, const AdminWhitelistScreen()),
      _ScreenItem(l10n.firmPanel, Icons.business_rounded, const FirmOwnerPanelScreen()),
      _ScreenItem(l10n.availableReports, Icons.description_rounded, const AvailableReportsScreen()),
      _ScreenItem(l10n.firmStatistics, Icons.bar_chart_rounded, const FirmStatisticsScreen()),
      _ScreenItem(l10n.firmMembers, Icons.group_rounded, const FirmMembersScreen()),
      _ScreenItem(l10n.registerFirm, Icons.business_center_rounded, const RegisterFirmScreen()),
      _ScreenItem(l10n.taskCalendar, Icons.calendar_today_rounded, const WorkerTaskCalendarScreen()),
      _ScreenItem(l10n.announcements, Icons.campaign_rounded, const AnnouncementsScreen()),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.devAllScreens,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final screen = screens[index];
          return _screenCard(screen, context, theme, isDark);
        },
      ),
    );
  }

  Widget _screenCard(_ScreenItem item, BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenItem {
  final String name;
  final IconData icon;
  final Widget screen;

  _ScreenItem(this.name, this.icon, this.screen);
}

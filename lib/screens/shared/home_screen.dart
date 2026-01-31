import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/confirm_dialog.dart';
import '../../services/firestore_paths.dart';
import '../../services/user_role_service.dart';
import '../../widgets/app_card.dart';


import '../admin/admin_reports_screen.dart';
import '../student/announcements_screen.dart';
import '../admin/add_announcement_screen.dart';
import '../student/announcement_detail_screen.dart';
import '../admin/manage_categories_screen.dart';
import '../admin/manage_participants_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_whitelist_screen.dart';


import '../firm/firm_owner_panel_screen.dart';
import '../firm/assigned_reports_screen.dart';
import '../firm/available_reports_screen.dart';
import '../firm/firm_members_screen.dart';
import '../firm/firm_history_screen.dart';
import '../firm/firm_statistics_screen.dart';
import '../firm/register_firm_screen.dart';


import '../worker/worker_task_calendar_screen.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastSyncedRole;

  
  
  
  Future<void> _syncRoleTopics(String role) async {
    if (_lastSyncedRole == role) return;

    const allTopics = [
      'admin',
      'user',
      'usernau',
      'firm_owner',
      'firmworker',
    ];


    final messaging = FirebaseMessaging.instance;

    
    for (final topic in allTopics) {
      await messaging.unsubscribeFromTopic(topic);
    }

    
    await messaging.subscribeToTopic(role);


    _lastSyncedRole = role;
  }

  
  
  
  Future<void> _confirmLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.logoutConfirm,
      message: l10n.areYouSureLogout,
      confirmText: l10n.logout,
      cancelText: l10n.cancel,
    );

    if (confirmed) {
      await AuthService.logout();
    }
  }

  
  
  
  Future<String?> _loadFirmId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firms)
        .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final l10n = AppLocalizations.of(context)!;
    
    if (user == null) {
      return Scaffold(
        body: Center(child: Text(l10n.noUserFound)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final normalizedRole =
            UserRoleService.normalizeRole(data[FirestoreUserFields.role]?.toString());

        
        _syncRoleTopics(normalizedRole);

        final bool isAdmin = normalizedRole == "admin";
        final bool isFirmOwner = normalizedRole == "firm_owner";
        final bool isWorker = normalizedRole == "firmworker";
        final bool isUser = normalizedRole == "user";
        final bool isUserNAU = normalizedRole == "usernau";

        final String userName =
            data[FirestoreUserFields.name] ?? user.email?.split('@').first ?? 'User';

        final String applicationStatus =
            (data[FirestoreUserFields.applicationStatus] ?? '').toString();

        final String roleLabel =
        isUser ? "" : normalizedRole.replaceAll("_", " ");

        if (isUserNAU) {
          return _WhitelistPendingContent(
            userName: userName,
            applicationStatus: applicationStatus,
            onLogout: _confirmLogout,
          );
        }

        return _buildMainUI(
          userName,
          roleLabel,
          isAdmin: isAdmin,
          isFirmOwner: isFirmOwner,
          isWorker: isWorker,
          isUser: isUser,
        );
      },
    );
  }

  
  
  
  Widget _buildMainUI(
      String userName,
      String roleLabel, {
        required bool isAdmin,
        required bool isFirmOwner,
        required bool isWorker,
        required bool isUser,
      }) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.helloUser(userName),
          style: TextStyle(
            fontSize: 26,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 28),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (roleLabel.isNotEmpty)
              Text(
                "${l10n.role} $roleLabel",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (roleLabel.isNotEmpty) const SizedBox(height: 24),

            if (isUser) _buildAnnouncementsPreview(),
            if (isWorker) _buildWorkerPanel(),
            if (isFirmOwner) _buildFirmOwnerPanel(),
            if (isAdmin) _buildAdminPanel(),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }


  
  
  Widget _buildFirmOwnerPanel() {
    return FutureBuilder<String?>(
      future: _loadFirmId(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return AppCard(
            radius: 26,
            padding: const EdgeInsets.all(20),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final firmId = snap.data;

        if (firmId == null) {
          return _buildFirmCreateBlock();
        }

        return _buildFirmOwnerPanelWithData(firmId);
      },
    );
  }

  Widget _buildFirmCreateBlock() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.firmPanel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.youHaveNoFirmYet,
            style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[400] : Colors.black54),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterFirmScreen(),
                  ),
                );
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                l10n.createFirm,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirmOwnerPanelWithData(String firmId) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.firmPanel,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              _menuButton(l10n.myFirmPanel, Icons.business_rounded,
                  const FirmOwnerPanelScreen()),
              _menuButton(l10n.assignedReportsHome, Icons.check_circle_outline,
                  const AssignedReportsScreen()),
              _menuButton(l10n.availableReportsHome, Icons.assignment_rounded,
                  const AvailableReportsScreen()),
              _menuButton(l10n.firmParticipants, Icons.group_rounded,
                  const FirmMembersScreen()),
              _menuButton(l10n.firmStatistics, Icons.bar_chart,
                  const FirmStatisticsScreen()),
              _menuButton(l10n.reportsHistory, Icons.history_rounded,
                  FirmHistoryScreen(firmId: firmId)),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildWorkerPanel() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 54,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.workerPanel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkerTaskCalendarScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(
                l10n.taskCalendar,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildAdminPanel() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.adminTools,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              _menuButton(l10n.adminReports, Icons.list_alt_rounded,
                  const AdminReportsScreen()),
              _menuButton(l10n.adminDashboard, Icons.bar_chart,
                  const AdminDashboardScreen()),
              _menuButton(l10n.addAnnouncement, Icons.add_circle_rounded,
                  const AddAnnouncementScreen()),
              _menuButton(l10n.manageCategories, Icons.category_rounded,
                  const ManageCategoriesScreen()),
              _menuButton(l10n.manageParticipants, Icons.people_alt_rounded,
                  const ManageParticipantsScreen()),
              _menuButton(l10n.whitelistApplications, Icons.admin_panel_settings,
                  const AdminWhitelistScreen()),
            ],
          ),
        ],
      ),
    );
  }

  


  Widget _buildAnnouncementsPreview() {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      radius: 26,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.announcements,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen(),
                    ),
                  );
                },
                child: Text(
                  l10n.seeAll,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(FirestoreCollections.announcements)
                .orderBy(FirestoreAnnouncementFields.createdAt, descending: true)
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              final l10n = AppLocalizations.of(context)!;
              
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                return Text(
                  l10n.noAnnouncements,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                );
              }

              return Column(
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final color = _colorByType(data[FirestoreAnnouncementFields.type]);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailScreen(
                            title: data[FirestoreAnnouncementFields.title] ?? "",
                            text: data[FirestoreAnnouncementFields.text] ?? "",
                            type: data[FirestoreAnnouncementFields.type],
                            createdAt: data[FirestoreAnnouncementFields.createdAt] != null
                                ? (data[FirestoreAnnouncementFields.createdAt] as Timestamp).toDate()
                                : null,
                            authorEmail: data[FirestoreAnnouncementFields.authorEmail],
                            images: data[FirestoreAnnouncementFields.images] != null
                                ? List<String>.from(data[FirestoreAnnouncementFields.images])
                                : null,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(Icons.notifications, color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data[FirestoreAnnouncementFields.title] ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.white 
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data[FirestoreAnnouncementFields.text] ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: Theme.of(context).brightness == Brightness.dark 
                                        ? Colors.grey[400] 
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _menuButton(String label, IconData icon, Widget screen) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: AppCard(
        radius: 20,
        padding: const EdgeInsets.symmetric(vertical: 22),
        color: isDark ? theme.cardColor : Colors.grey.shade100,
        boxShadow: const [],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: Colors.blue),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorByType(String? t) {
    switch (t) {
      case "important":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}




class _WhitelistPendingContent extends StatefulWidget {
  final String userName;
  final String applicationStatus;
  final Future<void> Function() onLogout;

  const _WhitelistPendingContent({
    required this.userName,
    required this.applicationStatus,
    required this.onLogout,
  });

  @override
  State<_WhitelistPendingContent> createState() =>
      _WhitelistPendingContentState();
}

class _WhitelistPendingContentState extends State<_WhitelistPendingContent> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _albumController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _albumController.dispose();
    super.dispose();
  }





Future<void> _submitRequest() async {
    if (_isSubmitting) return;

    final fullName = _fullNameController.text.trim();
    final album = _albumController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    
    if (fullName.isEmpty || album.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillFullNameAndAlbum),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final uid = user.uid;
      final email = user.email;

      await FirebaseFirestore.instance
          .collection(FirestoreCollections.whitelistApplications)
          .doc(uid)
          .set({
        FirestoreWhitelistApplicationFields.uid: uid,
        FirestoreUserFields.fullName: fullName,
        FirestoreUserFields.album: album,
        FirestoreUserFields.email: email,
        FirestoreWhitelistApplicationFields.status: "pending",
        FirestoreWhitelistApplicationFields.createdAt: Timestamp.now(),
      });

      await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).update({
        FirestoreUserFields.applicationStatus: "pending",
        FirestoreUserFields.name: fullName,
      });

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requestSubmitted)),
      );

      FocusScope.of(context).unfocus();
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSubmittingRequest)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isPending = widget.applicationStatus == "pending";
    final bool isRejected = widget.applicationStatus == "rejected";
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.helloUser(widget.userName),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 28),
            onPressed: () => widget.onLogout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  isPending
                      ? l10n.applicationBeingReviewed
                      : l10n.accountPendingApproval,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.grey[400] : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isRejected) ...[
                  const SizedBox(height: 10),
                  Text(
                    l10n.previousApplicationRejected,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 26),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.fullName,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _fullNameController,
                  enabled: !isPending,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.nameAndSurname,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black54,
                    ),
                    filled: true,
                    fillColor: isDark ? theme.cardColor : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.album,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _albumController,
                  enabled: !isPending,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.studentAlbumNumber,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.black54,
                    ),
                    filled: true,
                    fillColor: isDark ? theme.cardColor : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    (isPending || _isSubmitting) ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isPending
                          ? l10n.requestSent
                          : (_isSubmitting ? l10n.sending : l10n.submitRequest),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

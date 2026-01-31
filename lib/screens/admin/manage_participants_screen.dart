import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:akademik_app/l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class ManageParticipantsScreen extends StatefulWidget {
  const ManageParticipantsScreen({super.key});

  @override
  State<ManageParticipantsScreen> createState() => _ManageParticipantsScreenState();
}

class _ManageParticipantsScreenState extends State<ManageParticipantsScreen> {
  final List<String> roles = ['user', 'firmowner', 'firmworker', 'admin', 'banned'];
  String searchQuery = "";

  String? currentAdminUid;

  @override
  void initState() {
    super.initState();
    currentAdminUid = FirebaseAuth.instance.currentUser?.uid;
  }

  
  
  
  Future<void> _updateRole(String uid, String newRole) async {
    final l10n = AppLocalizations.of(context)!;
    if (uid == currentAdminUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotChangeOwnRole)),
      );
      return;
    }

    await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(uid).update({
      FirestoreUserFields.role: newRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.roleUpdatedTo(newRole))),
    );
  }

  
  
  
  Future<void> _banUser(String uid, String email) async {
    final l10n = AppLocalizations.of(context)!;
    if (uid == currentAdminUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotBanYourself)),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmBanTitle),
        content: Text(l10n.banThisUserPrompt(email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.ban),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _updateRole(uid, "banned");
    }
  }

  
  
  
  Future<void> _unbanUser(String uid, String email) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmUnbanTitle),
        content: Text(l10n.unbanThisUserPrompt(email)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.unban),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _updateRole(uid, "user");
    }
  }

  String _roleLabel(String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role) {
      case "admin":
        return l10n.roleAdmin;
      case "firmowner":
        return l10n.roleFirmOwner;
      case "firmworker":
        return l10n.roleFirmWorker;
      case "banned":
        return l10n.roleBanned;
      default:
        return l10n.roleUser;
    }
  }

  
  
  
  Widget _roleBadge(String role) {
    Color color;

    switch (role) {
      case "admin":
        color = Colors.red;
        break;
      case "firmowner":
        color = Colors.blue;
        break;
      case "firmworker":
        color = Colors.green;
        break;
      case "banned":
        color = Colors.black;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _roleLabel(role),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  
  
  
  Widget _userCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = doc.id;
    final name = data[FirestoreUserFields.name] ?? "";
    final email = data[FirestoreUserFields.email] ?? "";
    final role = data[FirestoreUserFields.role] ?? "user";

    final bool isSelf = uid == currentAdminUid;

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  
                  return CircleAvatar(
                radius: 24,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.blue.shade50,
                    child: const Icon(Icons.person, color: Colors.blue),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _roleBadge(role),
            ],
          ),

          const SizedBox(height: 16),

          
          if (role != "banned")
            AbsorbPointer(
              absorbing: isSelf, 
              child: Opacity(
                opacity: isSelf ? 0.4 : 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButton<String>(
                    value: role,
                    underline: const SizedBox(),
                    isExpanded: true,
                    items: roles.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(_roleLabel(r)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) _updateRole(uid, v);
                    },
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          
          if (role != "banned")
            AbsorbPointer(
              absorbing: isSelf,
              child: Opacity(
                opacity: isSelf ? 0.4 : 1,
                child: GestureDetector(
                  onTap: () => _banUser(uid, email),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.block, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(AppLocalizations.of(context)!.banUser,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          
          if (role == "banned")
            GestureDetector(
              onTap: () => _unbanUser(uid, email),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.unbanUser,
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
        ],
      ),
        );
      },
    );
  }

  
  
  
  Widget _section(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        "$title ($count)",
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.manageParticipants,
          style: TextStyle(
            fontWeight: FontWeight.w700, 
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: "${l10n.search}...",
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  setState(() => searchQuery = v.toLowerCase());
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirestoreCollections.users)
                    .orderBy(FirestoreUserFields.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  final filtered = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final email = (data[FirestoreUserFields.email] ?? "").toLowerCase();
                    final name = (data[FirestoreUserFields.name] ?? "").toLowerCase();

                    return searchQuery.isEmpty ||
                        email.contains(searchQuery) ||
                        name.contains(searchQuery);
                  }).toList();

                  final admins = filtered.where((u) => (u[FirestoreUserFields.role] ?? "").toLowerCase() == "admin").toList();
                  final owners = filtered.where((u) => (u[FirestoreUserFields.role] ?? "").toLowerCase() == "firmowner").toList();
                  final workers = filtered.where((u) => (u[FirestoreUserFields.role] ?? "").toLowerCase() == "firmworker").toList();
                  final users = filtered.where((u) => (u[FirestoreUserFields.role] ?? "").toLowerCase() == "user").toList();
                  final banned = filtered.where((u) => (u[FirestoreUserFields.role] ?? "").toLowerCase() == "banned").toList();

                  return ListView(
                    children: [
                      if (admins.isNotEmpty) _section(l10n.admins, admins.length),
                      ...admins.map(_userCard),

                      if (owners.isNotEmpty) _section(l10n.firmOwners, owners.length),
                      ...owners.map(_userCard),

                      if (workers.isNotEmpty) _section(l10n.firmWorkers, workers.length),
                      ...workers.map(_userCard),

                      if (users.isNotEmpty) _section(l10n.users, users.length),
                      ...users.map(_userCard),

                      if (banned.isNotEmpty) _section(l10n.banned, banned.length),
                      ...banned.map(_userCard),
                    ],
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

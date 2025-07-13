import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:akademik_app/screens/add_report_screen.dart';
import 'package:akademik_app/screens/reports_screen.dart';
import 'package:akademik_app/screens/admin_reports_screen.dart';
import 'package:akademik_app/screens/admin_panel_screen.dart';
import 'package:akademik_app/screens/firm_owner_panel_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user found')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // если документ юзера удалён из Firestore — авто logout
        if (!snapshot.hasData || !snapshot.data!.exists) {
          FirebaseAuth.instance.signOut(); // 🔥 auto logout
          return const Scaffold(
            body: Center(child: Text('User not found in database. Logging out...')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'] ?? 'user';
        final email = user.email ?? 'Unknown';

        debugPrint("👤 User logged in: $email | Role: $role");

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to Akademik App!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Role: $role', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddReportScreen()),
                      );
                    },
                    child: const Text('Add Report'),
                  ),
                  const SizedBox(height: 20),

                  if (role == 'admin')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                        );
                      },
                      child: const Text('Admin Reports'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportsScreen()),
                        );
                      },
                      child: const Text('My Reports'),
                    ),

                  if (role == 'admin') ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
                        );
                      },
                      child: const Text('Admin Panel'),
                    ),
                  ],

                  if (role == 'firmOwner') ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FirmOwnerPanelScreen()),
                        );
                      },
                      child: const Text('My Firm'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

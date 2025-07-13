import 'package:flutter/material.dart';
import 'manage_roles_screen.dart';
import 'manage_categories_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRolesScreen()),
                );
              },
              child: const Text('Manage Roles'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
                );
              },
              child: const Text('Manage Categories'),
            ),
          ],
        ),
      ),
    );
  }
}

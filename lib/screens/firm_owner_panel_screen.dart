import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'register_firm_screen.dart';
import 'available_reports_screen.dart';
import 'firm_won_reports_screen.dart';

class FirmOwnerPanelScreen extends StatefulWidget {
  const FirmOwnerPanelScreen({super.key});

  @override
  State<FirmOwnerPanelScreen> createState() => _FirmOwnerPanelScreenState();
}

class _FirmOwnerPanelScreenState extends State<FirmOwnerPanelScreen> {
  bool _isLoading = true;
  DocumentSnapshot? _firmDoc;
  List<DocumentSnapshot> _employees = [];
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFirm();
  }

  Future<void> _loadFirm() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('firms')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final firm = snapshot.docs.first;
      final workerIds = List<String>.from(firm['workerIds'] ?? []);

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: workerIds.isEmpty ? ['_'] : workerIds)
          .get();

      setState(() {
        _firmDoc = firm;
        _employees = usersSnapshot.docs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _firmDoc = null;
        _employees = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addEmployeeByEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _firmDoc == null) return;

    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found')));
      return;
    }

    final userDoc = userSnap.docs.first;
    final uid = userDoc.id;

    final firmRef = _firmDoc!.reference;

    await FirebaseFirestore.instance.runTransaction((txn) async {
      txn.update(userDoc.reference, {'role': 'firmWorker'});
      txn.update(firmRef, {
        'workerIds': FieldValue.arrayUnion([uid])
      });
    });

    _emailController.clear();
    await _loadFirm();
  }

  void _openEditDialog() async {
    final nameController = TextEditingController(text: _firmDoc!['name']);
    final currentCategories = List<String>.from(_firmDoc!['categories']);
    final allCats = await FirebaseFirestore.instance.collection('categories').get();
    final allCategories = allCats.docs.map((e) => e['name'] as String).toList();
    final selected = Set<String>.from(currentCategories);

    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Firm'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Firm Name'),
              ),
              const SizedBox(height: 10),
              const Align(alignment: Alignment.centerLeft, child: Text('Categories:')),
              ...allCategories.map((cat) => StatefulBuilder(
                builder: (context, setState) => CheckboxListTile(
                  title: Text(cat),
                  value: selected.contains(cat),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selected.add(cat);
                      } else {
                        selected.remove(cat);
                      }
                    });
                  },
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty || selected.isEmpty) return;
              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'categories': selected.toList(),
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null) {
      await _firmDoc!.reference.update(updated);
      await _loadFirm();
    }
  }

  void _openAvailableReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AvailableReportsScreen()),
    );
  }

  void _openWonReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FirmWonReportsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Firm Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _firmDoc == null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('You haven\'t registered your firm yet.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterFirmScreen()),
                ).then((_) => _loadFirm());
              },
              child: const Text('Register Firm'),
            ),
          ],
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Firm: ${_firmDoc!['name']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Categories: ${(List.from(_firmDoc!['categories'])).join(', ')}'),
              const SizedBox(height: 20),
              const Text('Employees:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_employees.isEmpty)
                const Text('No employees yet.')
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _employees.map((e) => Text('- ${e['email']}')).toList(),
                ),
              const Divider(height: 40),
              const Text('Add Employee by Email:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addEmployeeByEmail,
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment),
                label: const Text('Available Reports'),
                onPressed: _openAvailableReports,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.star),
                label: const Text('View Won Reports'),
                onPressed: _openWonReports,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Firm'),
                onPressed: _openEditDialog,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

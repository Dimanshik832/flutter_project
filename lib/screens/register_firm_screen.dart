import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterFirmScreen extends StatefulWidget {
  const RegisterFirmScreen({super.key});

  @override
  State<RegisterFirmScreen> createState() => _RegisterFirmScreenState();
}

class _RegisterFirmScreenState extends State<RegisterFirmScreen> {
  final _nameController = TextEditingController();
  final List<String> _allCategories = [];
  final List<String> _selectedCategories = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _allCategories.addAll(snapshot.docs.map((doc) => doc['name'].toString()));
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (name.isEmpty || _selectedCategories.isEmpty || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter firm name and select at least one category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('firms').add({
        'name': name,
        'ownerId': uid,
        'categories': _selectedCategories,
        'workerIds': [],
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pop(context); // Вернёмся назад в FirmOwnerPanel
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firm registered successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Your Firm')),
      body: _allCategories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Firm Name'),
            ),
            const SizedBox(height: 20),
            const Text('Select Categories (at least one):'),
            Expanded(
              child: ListView(
                children: _allCategories.map((category) {
                  final isSelected = _selectedCategories.contains(category);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(category),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedCategories.add(category);
                        } else {
                          _selectedCategories.remove(category);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'Registering...' : 'Register Firm'),
            ),
          ],
        ),
      ),
    );
  }
}

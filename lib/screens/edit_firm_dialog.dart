import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditFirmDialog extends StatefulWidget {
  final String initialName;
  final List<String> initialCategories;

  const EditFirmDialog({
    Key? key,
    required this.initialName,
    required this.initialCategories,
  }) : super(key: key);

  @override
  State<EditFirmDialog> createState() => _EditFirmDialogState();
}

class _EditFirmDialogState extends State<EditFirmDialog> {
  final _nameController = TextEditingController();
  List<String> _allCategories = [];
  Set<String> _selectedCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _selectedCategories = widget.initialCategories.toSet();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _allCategories = snapshot.docs.map((e) => e['name'] as String).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return AlertDialog(
      title: const Text('Edit Firm'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Firm Name'),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ..._allCategories.map((cat) => CheckboxListTile(
              title: Text(cat),
              value: _selectedCategories.contains(cat),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedCategories.add(cat);
                  } else {
                    _selectedCategories.remove(cat);
                  }
                });
              },
            )),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty || _selectedCategories.isEmpty) return;
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'categories': _selectedCategories.toList(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

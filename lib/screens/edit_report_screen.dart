import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report.dart';

class EditReportScreen extends StatefulWidget {
  final Report report;

  const EditReportScreen({super.key, required this.report});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _roomNumberController;
  String? _selectedCategory;
  List<String> _imageUrls = [];
  List<String> _categories = [];

  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(text: widget.report.description);
    _roomNumberController = TextEditingController(text: widget.report.roomNumber);
    _imageUrls = List.from(widget.report.imageUrls);
    _selectedCategory = widget.report.category;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance.collection('categories').get();
    final catList = snap.docs.map((e) => e['name'] as String).toList();
    setState(() {
      _categories = catList;
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      }
    });
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (_imageUrls.length + picked.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 3 images allowed')),
      );
      return;
    }

    for (final image in picked) {
      final file = File(image.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('report_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      setState(() {
        _imageUrls.add(url);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('reports').doc(widget.report.id).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'roomNumber': _roomNumberController.text,
        'category': _selectedCategory,
        'images': _imageUrls,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _viewImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _roomNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Room Number'),
            ),
            const SizedBox(height: 10),
            if (_categories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Add More Photos'),
            ),
            const SizedBox(height: 10),
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) => Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _viewImage(_imageUrls[index]),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Image.network(
                            _imageUrls[index],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            color: Colors.black54,
                            child: const Icon(Icons.close, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

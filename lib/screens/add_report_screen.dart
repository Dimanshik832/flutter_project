import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akademik_app/models/report.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomNumberController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  bool _isSubmitting = false;
  String _buttonText = 'Add Report';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    final cats = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    setState(() {
      _categories = cats.isEmpty ? ['Other'] : cats;
      _selectedCategory = _categories.first;
    });
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.length <= 3) {
      setState(() {
        _images = picked;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 3 photos')),
      );
    }
  }

  Future<List<String>> _uploadImages(List<XFile> images) async {
    final urls = <String>[];

    for (final image in images) {
      final file = File(image.path);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('report_images/$fileName.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  Future<void> _addReport() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _buttonText = 'Sending...';
    });

    try {
      final imageUrls = await _uploadImages(_images);
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? 'unknown';
      final userEmail = user?.email ?? 'no-email';

      final report = Report(
        title: _titleController.text,
        description: _descriptionController.text,
        roomNumber: _roomNumberController.text,
        category: _selectedCategory!,
        status: 'Submitted',
        imageUrls: imageUrls,
        createdAt: Timestamp.now(),
        userId: userId,
      );

      final reportData = report.toMap();
      reportData['userEmail'] = userEmail;

      await FirebaseFirestore.instance.collection('reports').add(reportData);

      setState(() {
        _buttonText = 'Report Sent ✅';
        _isSubmitting = false;
        _titleController.clear();
        _descriptionController.clear();
        _roomNumberController.clear();
        _images = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report sent successfully!')),
      );
    } catch (e) {
      setState(() {
        _buttonText = 'Failed to Add';
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Report')),
      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Add Photos (up to 3)'),
            ),
            const SizedBox(height: 10),
            _images.isNotEmpty
                ? SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Image.file(
                    File(_images[index].path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _addReport,
              child: Text(_buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

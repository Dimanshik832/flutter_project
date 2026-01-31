import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/report.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class EditReportScreen extends StatefulWidget {
  final Report report;

  const EditReportScreen({super.key, required this.report});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _roomController;

  final ImagePicker _picker = ImagePicker();
  List<String> _imageUrls = [];
  List<String> _categories = [];
  String? _selectedCategory;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController =
        TextEditingController(text: widget.report.description);
    _roomController = TextEditingController(text: widget.report.room);
    _imageUrls = List.from(widget.report.imageUrls);
    _selectedCategory = widget.report.category;

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final snap = await FirebaseFirestore.instance.collection("categories").get();
    setState(() {
      _categories =
          snap.docs.map((e) => e[FirestoreCategoryFields.name] as String).toList();

      if (_categories.isEmpty) {
        _categories = ["Other"];
      }

      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories.first;
      }
    });
  }

  Future<void> _pickImages() async {
    const maxPhotos = 3;
    final l10n = AppLocalizations.of(context)!;

    if (_imageUrls.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.photosCount(_imageUrls.length, maxPhotos))),
      );
      return;
    }

    final source = await _selectImageSource();
    if (source == null) return;

    if (source == ImageSource.camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;
      await _uploadAndAdd([picked]);
      return;
    }

    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    final remaining = maxPhotos - _imageUrls.length;
    final limited = picked.take(remaining).toList();
    await _uploadAndAdd(limited);
  }

  Future<void> _uploadAndAdd(List<XFile> picked) async {
    for (final img in picked) {
      final file = File(img.path);
      final name = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          FirebaseStorage.instance.ref().child("report_images/$name.jpg");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      if (!mounted) return;
      setState(() => _imageUrls.add(url));
    }
  }

  Future<ImageSource?> _selectImageSource() {
    final l10n = AppLocalizations.of(context)!;

    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.chooseFromGallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() => _imageUrls.removeAt(index));
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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFillAllFields)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .doc(widget.report.id)
          .update({
        FirestoreReportFields.title: _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        FirestoreReportFields.roomNumber: _roomController.text.trim(),
        "category": _selectedCategory,
        FirestoreReportFields.images: _imageUrls,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportUpdatedSuccessfully)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails(e.toString()))),
      );
    }

    if (mounted) setState(() => _isSaving = false);
  }

  InputDecoration _input(String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.black87),
      filled: true,
      fillColor: isDark ? theme.cardColor : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
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
        title: Text(
          l10n.editReport,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),

      body: _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _input(l10n.title),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _input(l10n.description),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _roomController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _input(l10n.roomNumber),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _input(l10n.category),
              items: _categories
                  .map((c) =>
                  DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    l10n.addPhotosMax(3),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _imageUrls[i],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Builder(
                              builder: (context) {
                                final theme = Theme.of(context);
                                final isDark = theme.brightness == Brightness.dark;
                                
                                return Container(
                              decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[700] : Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  _isSaving ? l10n.saving : l10n.saveChanges,
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
      ),
    );
  }
}

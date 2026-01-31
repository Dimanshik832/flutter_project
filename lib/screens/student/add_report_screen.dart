import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:akademik_app/models/report.dart';
import 'package:akademik_app/l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

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

  bool _titleError = false;
  bool _descError = false;
  bool _roomError = false;

  static const Color errorColor = Color(0xFFBA1A1A);

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  
  
  
  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();

    final cats = snapshot.docs
        .map((d) => d[FirestoreCategoryFields.name].toString())
        .toList();

    
    cats.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    setState(() {
      _categories = cats.isEmpty ? ['Other'] : cats;
      _selectedCategory = _categories.first;
    });
  }

  
  
  
  Future<File> _compressImage(File file) async {
    final newPath = "${file.path}_compressed.jpg";

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 70,
      minWidth: 1500,
      minHeight: 1500,
    );

    final compressedFile = File(newPath);
    await compressedFile.writeAsBytes(compressedBytes!);
    return compressedFile;
  }

  
  
  
  Future<void> _pickImages() async {
    const maxPhotos = 3;

    if (_images.length >= maxPhotos) {
      _showErrorToast(AppLocalizations.of(context)!.somethingWentWrong);
      return;
    }

    final source = await _selectImageSource();
    if (source == null) return;

    if (source == ImageSource.camera) {
      final picked = await _picker.pickImage(source: ImageSource.camera);
      if (picked == null) return;
      setState(() {
        _images.add(picked);
      });
      return;
    }

    final picked = await _picker.pickMultiImage();

    if (picked.isEmpty) return;

    final remaining = maxPhotos - _images.length;

    final l10n = AppLocalizations.of(context)!;
    if (picked.length > remaining) {
      _showErrorToast(l10n.somethingWentWrong);

      setState(() {
        _images.addAll(picked.take(remaining));
      });
    } else {
      setState(() {
        _images.addAll(picked);
      });
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

  
  
  
  void _openZoomScreen(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ZoomImageScreen(imagePath: path)),
    );
  }

  
  
  
  void _showErrorToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  
  
  
  void _showSuccessToast() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.reportCreatedSuccessfully,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  
  
  
  Future<List<String>> _uploadImages(List<XFile> images) async {
    final urls = <String>[];

    for (final img in images) {
      File original = File(img.path);
      File compressed = await _compressImage(original);

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child("report_images/$timestamp.jpg");

      await ref.putFile(compressed);
      urls.add(await ref.getDownloadURL());
    }

    return urls;
  }

  
  
  
  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final room = _roomNumberController.text.trim();

    _titleError = title.isEmpty;
    _descError = desc.isEmpty;
    _roomError = room.isEmpty;

    setState(() {});

    final l10n = AppLocalizations.of(context)!;
    if (_titleError || _descError || _roomError) {
      _showErrorToast(l10n.somethingWentWrong);
      return;
    }

    if (title.length > 20 || room.length > 10) {
      _showErrorToast(l10n.somethingWentWrong);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final urls = await _uploadImages(_images);
      final user = FirebaseAuth.instance.currentUser!;

      final report = Report(
        title: title,
        description: desc,
        room: room,
        category: _selectedCategory!,
        status: "Submitted",
        createdAt: Timestamp.now(),
        userId: user.uid,
        imageUrls: urls,

      );

      final data = report.toMap();
      data["createdBy"] = user.uid;
      data[FirestoreReportFields.userEmail] = user.email;

      await FirebaseFirestore.instance.collection(FirestoreCollections.reports).add(data);

      _showSuccessToast();
      await Future.delayed(const Duration(milliseconds: 350));

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showErrorToast(l10n.somethingWentWrong);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  
  
  
  InputDecoration _input(String label, bool error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: error ? errorColor : (isDark ? Colors.grey[400] : Colors.grey[700]),
        fontWeight: FontWeight.w400,
        fontSize: 16,
      ),
      filled: true,
      fillColor: isDark ? theme.cardColor : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.addReport,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return TextField(
                  controller: _titleController,
                  maxLength: 20,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: _input(l10n.title, _titleError),
                );
              },
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: _input(l10n.description, _descError),
                );
              },
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return TextField(
                  controller: _roomNumberController,
                  maxLength: 10,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: _input(l10n.roomNumber, _roomError),
                );
              },
            ),
            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _input(l10n.category, false),
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  dropdownColor: isDark ? theme.cardColor : Colors.white,
                  items: _categories
                      .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c,
                          style: TextStyle(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                );
              },
            ),

            const SizedBox(height: 20),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
                  l10n.photosCount(_images.length, 3),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _images.length >= 3 
                        ? errorColor 
                        : (isDark ? Colors.grey[400] : Colors.grey[800]),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),

            GestureDetector(
              onTap: _pickImages,
              child: Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  
                  return Container(
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
                    l10n.uploadPhotos,
                        style: TextStyle(
                          fontWeight: FontWeight.w600, 
                          fontSize: 15,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                  ),
                ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            if (_images.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _openZoomScreen(_images[i].path),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_images[i].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _images.removeAt(i));
                            },
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
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22)),
                ),
                child: Text(
                  _isSubmitting ? l10n.sending : l10n.submitReport,
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




class _ZoomImageScreen extends StatelessWidget {
  final String imagePath;

  const _ZoomImageScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.5,
          child: Image.file(File(imagePath)),
        ),
      ),
    );
  }
}

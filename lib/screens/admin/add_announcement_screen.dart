import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:akademik_app/l10n/app_localizations.dart';

import '../student/announcements_screen.dart';
import '../shared/home_screen.dart';
import '../../services/firestore_paths.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _textCtrl = TextEditingController();

  bool _titleError = false;
  bool _textError = false;

  String _type = "info";
  bool _isSending = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  static const int maxPhotos = 3;

  final List<Map<String, dynamic>> _types = [
    {"value": "info", "color": Colors.blue},
    {"value": "warning", "color": Colors.orange},
    {"value": "important", "color": Colors.red},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  
  
  
  Future<File> _compressImage(File file) async {
    final newPath = "${file.path}_comp.jpg";

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1500,
      minHeight: 1500,
      quality: 70,
    );

    final compressedFile = File(newPath);
    await compressedFile.writeAsBytes(compressedBytes!);
    return compressedFile;
  }

  
  
  
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();

    if (picked.isEmpty) return;

    final remaining = maxPhotos - _images.length;
    final toAdd = picked.length > remaining ? picked.take(remaining) : picked;

    setState(() {
      _images.addAll(toAdd);
    });
  }

  
  
  
  void _openZoom(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ZoomImageScreen(imagePath: path),
      ),
    );
  }

  
  
  
  Future<List<String>> _uploadImages() async {
    final urls = <String>[];

    for (final img in _images) {
      File original = File(img.path);
      File compressed = await _compressImage(original);

      final fileName = "announcement_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child("announcement_images/$fileName");

      await ref.putFile(compressed);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  
  
  
  Future<void> _submit() async {
    if (_isSending) return;
    final l10n = AppLocalizations.of(context)!;

    final title = _titleCtrl.text.trim();
    final text = _textCtrl.text.trim();

    _titleError = title.isEmpty || title.length > 50;
    _textError = text.isEmpty || text.length > 500;

    setState(() {});

    if (_titleError || _textError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.announcementFormInvalid)),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final urls = await _uploadImages();

      await FirebaseFirestore.instance.collection(FirestoreCollections.announcements).add({
        FirestoreAnnouncementFields.title: title,
        FirestoreAnnouncementFields.text: text,
        FirestoreAnnouncementFields.type: _type,
        FirestoreAnnouncementFields.createdAt: Timestamp.now(),
        FirestoreAnnouncementFields.authorEmail: user.email,
        FirestoreAnnouncementFields.authorId: user.uid,
        FirestoreAnnouncementFields.images: urls,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.announcementPublished)),
      );

      
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorWithDetails(e.toString()))),
      );
    }
  }

  
  
  
  InputDecoration _input(String label, bool error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? theme.cardColor : Colors.white,
      labelStyle: TextStyle(
        color: error ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[700]),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: error ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.addAnnouncement,
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
                  controller: _titleCtrl,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: _input(l10n.title, _titleError),
                );
              },
            ),
            if (_titleError)
              Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  l10n.titleIsRequired,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return TextField(
                  controller: _textCtrl,
                  maxLines: 4,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: _input(l10n.description, _textError),
                );
              },
            ),
            if (_textError)
              Padding(
                padding: EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  l10n.descriptionIsRequired,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const SizedBox(height: 22),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DropdownButton<String>(
                value: _type,
                underline: const SizedBox(),
                isExpanded: true,
                items: _types.map<DropdownMenuItem<String>>((t) {
                  final String label = switch (t["value"]) {
                    "info" => l10n.info,
                    "warning" => l10n.warning,
                    "important" => l10n.important,
                    _ => t["value"].toString(),
                  };
                  return DropdownMenuItem<String>(
                    value: t["value"],
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 8,
                          backgroundColor: t["color"],
                        ),
                        const SizedBox(width: 10),
                        Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;
                            
                            return Text(
                              label,
                              style: TextStyle(
                                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                );
              },
            ),

            const SizedBox(height: 22),

            
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
                  l10n.photosCount(_images.length, maxPhotos),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _images.length >= maxPhotos 
                        ? Colors.red 
                        : (isDark ? Colors.grey[400] : Colors.grey[800]),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            if (_images.isNotEmpty)
              SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _openZoom(_images[i].path),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(
                                File(_images[i].path),
                                width: 105,
                                height: 105,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(i)),
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
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 28),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _isSending ? l10n.sending : l10n.publish,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                  );
                },
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    
                    return Text(
                      l10n.viewAllAnnouncements,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
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

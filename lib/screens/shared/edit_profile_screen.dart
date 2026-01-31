import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final picker = ImagePicker();

  String? _avatarUrl;
  File? _newAvatarFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      _nameController.text =
          (data[FirestoreUserFields.name] ?? '').toString();
      _avatarUrl = data[FirestoreUserFields.avatarUrl];
    });
  }

  Future<void> _pickAvatar() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    setState(() {
      _newAvatarFile = File(img.path);
    });
  }

  Future<String?> _uploadAvatar(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final path = "avatars/${user.uid}.jpg";
    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    
    
    if (name.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nameCannotExceed20Characters)),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    String? avatar = _avatarUrl;

    if (_newAvatarFile != null) {
      avatar = await _uploadAvatar(_newAvatarFile!);
    }

    await FirebaseFirestore.instance.collection(FirestoreCollections.users).doc(user.uid).update({
      FirestoreUserFields.name: name,
      FirestoreUserFields.avatarUrl: avatar,
    });

    setState(() => _isSaving = false);

    Navigator.pop(context);
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          l10n.editProfile,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.blue.shade100,
                      backgroundImage: _newAvatarFile != null
                          ? FileImage(_newAvatarFile!) as ImageProvider
                          : (_avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null),
                      child: (_avatarUrl == null && _newAvatarFile == null)
                          ? Icon(Icons.person, size: 60, color: isDark ? Colors.grey[400] : Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tapToChangePhoto,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey, 
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            TextField(
              controller: _nameController,
              maxLength: 20,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _input(l10n.yourName).copyWith(
                counterText: "",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _isSaving ? l10n.saving : l10n.saveChanges,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
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

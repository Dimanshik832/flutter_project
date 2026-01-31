import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'register_firm_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_sheet_handle.dart';
import '../../services/firestore_paths.dart';

class FirmOwnerPanelScreen extends StatefulWidget {
  const FirmOwnerPanelScreen({super.key});

  @override
  State<FirmOwnerPanelScreen> createState() => _FirmOwnerPanelScreenState();
}

class _FirmOwnerPanelScreenState extends State<FirmOwnerPanelScreen> {
  bool _isLoading = true;

  DocumentSnapshot<Map<String, dynamic>>? _firmDoc;
  String? _logoUrl;

  final ImagePicker _picker = ImagePicker();

  bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    _loadFirm();
  }

  
  
  
  Future<void> _loadFirm() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _firmDoc = null;
        _logoUrl = null;
        _isLoading = false;
      });
      return;
    }

    try {
      final firmsSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.firms)
          .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
          .limit(1)
          .get();

      if (firmsSnap.docs.isEmpty) {
        setState(() {
          _firmDoc = null;
          _logoUrl = null;
          _isLoading = false;
        });
        return;
      }

      final firm = firmsSnap.docs.first;
      final firmData = firm.data();

      
      final catsSnap =
      await FirebaseFirestore.instance.collection('categories').get();

      final allCategories = catsSnap.docs
          .map((e) => (e.data()[FirestoreCategoryFields.name] ?? '').toString())
          .where((e) => e.isNotEmpty)
          .toList();

      final firmCats =
      List<String>.from(firmData?['categories'] ?? const <String>[]);

      final cleanedCategories =
      firmCats.where((c) => allCategories.contains(c)).toList();

      if (cleanedCategories.length != firmCats.length) {
        await firm.reference.update({'categories': cleanedCategories});
      }

      setState(() {
        _firmDoc = firm;
        _logoUrl = firmData?[FirestoreFirmFields.logoUrl];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorWithDetails(e.toString()))),
      );
    }
  }

  
  
  
  Future<void> _pickLogo() async {
    if (_firmDoc == null) return;

    try {
      final XFile? img =
      await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

      if (img == null) return;

      final firmId = _firmDoc!.id;
      final storageRef =
      FirebaseStorage.instance.ref().child('firm_logos/$firmId.jpg');

      final fileBytes = await img.readAsBytes();
      await storageRef.putData(fileBytes);

      final url = await storageRef.getDownloadURL();
      await _firmDoc!.reference.update({FirestoreFirmFields.logoUrl: url});

      setState(() => _logoUrl = url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.success)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorWithDetails(e.toString()))),
      );
    }
  }

  
  
  
  Future<void> _openEditDialog() async {
    if (_firmDoc == null) return;

    final data = _firmDoc!.data() ?? {};

    final nameController = TextEditingController(text: data[FirestoreFirmFields.name] ?? '');
    final descriptionController =
    TextEditingController(text: data['description'] ?? '');
    final emailController = TextEditingController(text: data[FirestoreUserFields.email] ?? '');
    final phoneController = TextEditingController(text: data[FirestoreFirmFields.phone] ?? '');

    final currentCategories =
    List<String>.from(data['categories'] ?? const <String>[]);

    final catsSnap =
    await FirebaseFirestore.instance.collection('categories').get();

    final allCategories = catsSnap.docs
        .map((e) => (e.data()[FirestoreCategoryFields.name] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();

    Set<String> selected = currentCategories.toSet();
    bool showCategories = true;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? theme.cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const BottomSheetHandle(),
                    const SizedBox(height: 16),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                      AppLocalizations.of(context)!.editFirm,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return TextField(
                          controller: nameController,
                          style: TextStyle(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.firmName,
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            filled: true,
                            fillColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return TextField(
                          maxLines: 2,
                          controller: descriptionController,
                          style: TextStyle(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.description,
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            filled: true,
                            fillColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return TextField(
                          controller: emailController,
                          style: TextStyle(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.email,
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            filled: true,
                            fillColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return TextField(
                          controller: phoneController,
                          style: TextStyle(
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.phone,
                            labelStyle: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            filled: true,
                            fillColor: isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => setStateSB(() {
                        showCategories = !showCategories;
                      }),
                      child: Row(
                        children: [
                          Icon(
                            showCategories
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark = theme.brightness == Brightness.dark;
                              
                              return Text(
                                AppLocalizations.of(context)!.categoriesLabel,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                                ),
                              );
                            },
                          ),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark = theme.brightness == Brightness.dark;
                              
                              return Text(
                            AppLocalizations.of(context)!.selectedCount(selected.length),
                                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: showCategories
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          
                          return SizedBox(
                            height: 200,
                            child: ListView(
                              children: allCategories.map((cat) {
                                return CheckboxListTile(
                                  title: Text(
                                    cat,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  value: selected.contains(cat),
                                  onChanged: (v) {
                                    setStateSB(() {
                                      if (v == true) {
                                        selected.add(cat);
                                      } else {
                                        selected.remove(cat);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _firmDoc!.reference.update({
                            FirestoreFirmFields.name: nameController.text.trim(),
                            'description': descriptionController.text.trim(),
                            FirestoreUserFields.email: emailController.text.trim(),
                            FirestoreFirmFields.phone: phoneController.text.trim(),
                            'categories': selected.toList(),
                          });

                          Navigator.pop(context);
                          await _loadFirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.saveChanges,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  
  
  
  Widget _categorySection(List<String> categories) {
    const maxVisible = 2;

    final visibleItems =
    _showAllCategories ? categories : categories.take(maxVisible).toList();

    final hasMore = categories.length > maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: visibleItems
              .map(
                (c) => Chip(
              label: Text(c),
              backgroundColor: Colors.blue.withOpacity(0.12),
              labelStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
              .toList(),
        ),

        if (hasMore)
          TextButton(
            onPressed: () {
              setState(() => _showAllCategories = !_showAllCategories);
            },
            child: Text(
              _showAllCategories
                  ? AppLocalizations.of(context)!.showLess
                  : AppLocalizations.of(context)!.showMore,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  
  
  
  Widget _infoBlock({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 20), 
              const SizedBox(width: 10),
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  
                  return Text(
                title,
                    style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            '$label: ',
                style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: isDark ? Colors.white : theme.colorScheme.onSurface),
          ),
          Expanded(
                child: Text(
                  value,
                  style: TextStyle(color: isDark ? Colors.grey[300] : theme.colorScheme.onSurface),
                ),
          ),
        ],
      ),
        );
      },
    );
  }

  
  
  
  Widget _buildNoFirmView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_rounded, color: Colors.blue, size: 42),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.youHaveNoFirmYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.registerYourFirm,
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterFirmScreen()),
                ).then((_) => _loadFirm());
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  AppLocalizations.of(context)!.registerFirm,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildFirmContent(BuildContext context) {
    final data = _firmDoc!.data() ?? {};

    final categories =
    List<String>.from(data['categories'] ?? const <String>[]);
    final description = (data['description'] ?? '').toString();
    final email = (data[FirestoreUserFields.email] ?? '').toString();
    final phone = (data[FirestoreFirmFields.phone] ?? '').toString();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickLogo,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _logoUrl == null
                            ? Builder(
                          builder: (context) {
                            final theme = Theme.of(context);
                            final isDark = theme.brightness == Brightness.dark;
                            
                            return Container(
                          width: 64,
                          height: 64,
                              color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                          child: const Icon(Icons.business,
                              color: Colors.blue, size: 32),
                            );
                          },
                        )
                            : Image.network(
                          _logoUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.photo_camera_rounded,
                              size: 14, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final theme = Theme.of(context);
                                final isDark = theme.brightness == Brightness.dark;
                                
                                return Text(
                              data[FirestoreFirmFields.name] ?? AppLocalizations.of(context)!.firm,
                                  style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                              ),
                                );
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: _openEditDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.edit,
                                      size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context)!.edit,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      
                      _categorySection(categories),
                    ],
                  ),
                ),
              ],
            ),
              );
            },
          ),

          
          _infoBlock(
            title: AppLocalizations.of(context)!.contactDetails,
            icon: Icons.contact_mail_rounded,
            children: [
              if (email.isNotEmpty)
                _infoRow(Icons.email_rounded, AppLocalizations.of(context)!.email, email),
              if (phone.isNotEmpty)
                _infoRow(Icons.phone_rounded, AppLocalizations.of(context)!.phone, phone),
              if (email.isEmpty && phone.isEmpty)
                Text(
                  AppLocalizations.of(context)!.noContactDetails,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.grey[400] 
                        : Colors.black54
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          
          _infoBlock(
            title: AppLocalizations.of(context)!.description,
            icon: Icons.description_rounded,
            children: [
              Text(
                description.isEmpty
                    ? AppLocalizations.of(context)!.noDescription
                    : description,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.black87, 
                  fontSize: 14
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          AppLocalizations.of(context)!.firmPanel,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _firmDoc == null
            ? _buildNoFirmView(context)
            : _buildFirmContent(context),
      ),
    );
  }
}

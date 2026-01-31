import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class RegisterFirmScreen extends StatefulWidget {
  const RegisterFirmScreen({super.key});

  @override
  State<RegisterFirmScreen> createState() => _RegisterFirmScreenState();
}

class _RegisterFirmScreenState extends State<RegisterFirmScreen> {
  final TextEditingController _nameController = TextEditingController();

  final List<String> _allCategories = [];
  final List<String> _selectedCategories = [];

  bool _isSubmitting = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  
  
  
  Future<void> _loadCategories() async {
    try {
        final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

      setState(() {
        _allCategories
          ..clear()
          ..addAll(
            snapshot.docs.map((doc) => doc[FirestoreCategoryFields.name].toString()),
          );
        _isLoadingCategories = false;
      });
    } catch (e, stack) {
      debugPrint('RegisterFirmScreen: failed to load categories: $e');
      debugPrintStack(stackTrace: stack);
      setState(() => _isLoadingCategories = false);
    }
  }

  
  
  
  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    final l10n = AppLocalizations.of(context)!;

    if (name.isEmpty) {
      _showError(l10n.firmNameRequired);
      return;
    }

    if (_selectedCategories.isEmpty) {
      _showError(l10n.selectAtLeastOneCategory);
      return;
    }

    if (uid == null) {
      _showError(l10n.userNotAuthenticated);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.firms).add({
        FirestoreFirmFields.name: name,
        FirestoreFirmFields.ownerId: uid,
        'categories': _selectedCategories,
        FirestoreFirmFields.workerIds: [],
        FirestoreFirmFields.createdAt: Timestamp.now(),
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        _showError(l10n.failedToRegisterFirm);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  
  
  
  InputDecoration _input(String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? theme.cardColor : Colors.white,
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[400] : Colors.grey[700],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
    );
  }

  
  
  
  Widget _categoryChip(String category, bool selected) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final Color color = selected 
            ? Colors.blue 
            : (isDark ? Colors.grey[800]! : Colors.grey.shade100);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(selected ? 1 : 0.6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontWeight: FontWeight.w600,
                color: selected 
                    ? Colors.white 
                    : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
        );
      },
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
          l10n.registerFirm,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            
            
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      
                      return TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                        decoration: _input(l10n.firmName),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      
                      return Text(
                        l10n.selectCategories,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  Builder(
                    builder: (context) {
                      final theme = Theme.of(context);
                      final isDark = theme.brightness == Brightness.dark;
                      
                      return Wrap(
                        children: _allCategories.isEmpty
                            ? [
                          Text(
                            l10n.noCategoriesAvailable,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey,
                            ),
                          )
                        ]
                            : _allCategories.map((cat) {
                          final selected =
                          _selectedCategories.contains(cat);
                          return _categoryChip(cat, selected);
                        }).toList(),
                      );
                    },
                  ),
                ],
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
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  _isSubmitting ? l10n.sending : l10n.registerFirm,
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:akademik_app/l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();

  final List<IconData> availableIcons = [
    Icons.build,
    Icons.water_damage,
    Icons.lightbulb,
    Icons.lock,
    Icons.door_front_door,
    Icons.electric_bolt,
    Icons.cleaning_services,
    Icons.bug_report,
    Icons.plumbing,
    Icons.security,
    Icons.key,
    Icons.fire_extinguisher,
    Icons.sensors,
    Icons.eco,
    Icons.wifi,
  ];

  IconData newCategoryIcon = Icons.build;

  
  
  
  Future<void> _addCategory() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryNameCannotBeEmpty)),
      );
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection('categories')
        .where(FirestoreCategoryFields.name, isEqualTo: name)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categoryAlreadyExists(name))),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('categories').add({
      FirestoreCategoryFields.name: name,
      FirestoreCategoryFields.icon: newCategoryIcon.codePoint,
    });

    _categoryController.clear();
    setState(() => newCategoryIcon = Icons.build);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.categoryAdded)),
    );
  }

  
  
  
  Future<void> _deleteCategory(String id, String name) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await FirebaseFirestore.instance.collection('categories').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.categoryDeleted(name))),
    );
  }

  
  
  
  Future<IconData?> _pickIcon(IconData current) async {
    return showModalBottomSheet<IconData>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        IconData selected = current;

        return StatefulBuilder(
          builder: (context, setStateSB) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectIcon,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: availableIcons.map((icon) {
                    final isSelected =
                        icon.codePoint == selected.codePoint;

                    return GestureDetector(
                      onTap: () => setStateSB(() => selected = icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color:
                          isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: Text(AppLocalizations.of(context)!.apply),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  
  
  
  Future<void> _editCategory(
      String id,
      String oldName,
      int oldIcon,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: oldName);
    IconData selectedIcon =
    IconData(oldIcon, fontFamily: 'MaterialIcons');

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateSB) => AlertDialog(
          title: Text(l10n.editCategoryTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration:
                    InputDecoration(labelText: l10n.categoryNameLabel),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final picked = await _pickIcon(selectedIcon);
                  if (picked != null) {
                    setStateSB(() => selectedIcon = picked);
                  }
                },
                child: Row(
                  children: [
                    Icon(selectedIcon, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(l10n.changeIcon),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    
    if (ok != true) return;

    await FirebaseFirestore.instance.collection('categories').doc(id).update({
      FirestoreCategoryFields.name: controller.text.trim(),
      FirestoreCategoryFields.icon: selectedIcon.codePoint,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.categoryUpdated)),
    );
  }

  
  
  
  Widget _categoryCard(String name, String id, int iconCode) {
    final icon = IconData(iconCode, fontFamily: 'MaterialIcons');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return CircleAvatar(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                child: Icon(icon, color: Colors.blue),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
                  name,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editCategory(id, name, iconCode),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteCategory(id, name),
          ),
        ],
      ),
    );
  }

  
  
  
  BoxDecoration _box() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? theme.cardColor : Colors.white,
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.manageCategories)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _categoryController,
              decoration:
                  InputDecoration(hintText: l10n.newCategory),
              onSubmitted: (_) => _addCategory(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addCategory,
              child: Text(l10n.addCategory),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy(FirestoreCategoryFields.name)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((d) {
                      return _categoryCard(
                        d[FirestoreCategoryFields.name],
                        d.id,
                        d[FirestoreCategoryFields.icon],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

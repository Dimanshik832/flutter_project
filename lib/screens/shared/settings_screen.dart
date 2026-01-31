import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'edit_profile_screen.dart';
import '../../services/settings_service.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/app_card.dart';
import '../../services/firestore_paths.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pushNotifications = true;
  bool newsNotifications = true;

  String themeMode = "system";
  String language = "en";
  String version = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSettings();
    MyApp.appStateNotifier.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    MyApp.appStateNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        language = MyApp.appStateNotifier.locale.languageCode;
        switch (MyApp.appStateNotifier.themeMode) {
          case ThemeMode.light:
            themeMode = 'light';
            break;
          case ThemeMode.dark:
            themeMode = 'dark';
            break;
          case ThemeMode.system:
            themeMode = 'system';
            break;
        }
      });
    }
  }

  Future<void> _loadSettings() async {
    final savedLanguage = await SettingsService.getLanguage();
    final savedThemeMode = await SettingsService.getThemeMode();
    
    if (mounted) {
    setState(() {
      language = savedLanguage;
      themeMode = savedThemeMode;
    });
    }
  }

  
  
  
  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = "v${info.version}";
    });
  }

  
  
  
  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.logoutConfirm,
      message: l10n.areYouSureLogout,
      confirmText: l10n.logout,
      cancelText: l10n.cancel,
    );

    if (confirmed) {
      await AuthService.logout();
    }
  }

  Future<void> _copyToClipboard(String text, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailCopied),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _reportBug() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    const email = "admin.akademik@example.com";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bug_report_rounded,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.reportBugTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.reportBugMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_rounded, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.blue),
                      onPressed: () {
                        _copyToClipboard(email, context);
                        Navigator.pop(context);
                      },
                      tooltip: l10n.copyEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  void _contactAdmin() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    const email = "admin.akademik@example.com";

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.contactAdminTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.contactAdminMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_rounded, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        email,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Colors.blue),
                      onPressed: () {
                        _copyToClipboard(email, context);
                        Navigator.pop(context);
                      },
                      tooltip: l10n.copyEmail,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(child: Text(l10n.noUserFound)),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final settings =
            (data[FirestoreUserFields.notificationSettings] as Map<String, dynamic>?) ?? {};

        pushNotifications = settings["push"] ?? true;
        newsNotifications = settings["news"] ?? true;

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
              l10n.settings,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                
                _settingsSection(
                  title: l10n.account,
                  items: [
                    _item(
                      icon: Icons.edit,
                      label: l10n.editProfile,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _item(
                      icon: Icons.lock,
                      label: l10n.changePassword,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                
                _settingsSection(
                  title: l10n.notifications,
                  items: [
                    _toggle(
                      icon: Icons.notifications_active_rounded,
                      label: l10n.pushNotifications,
                      value: pushNotifications,
                      onChanged: (v) async {
                        setState(() => pushNotifications = v);
                        await FirebaseFirestore.instance
                            .collection(FirestoreCollections.users)
                            .doc(user.uid)
                            .update({
                          "notificationSettings.push": v,
                        });
                      },
                    ),
                    _toggle(
                      icon: Icons.info_outline_rounded,
                      label: l10n.newsUpdates,
                      value: newsNotifications,
                      onChanged: (v) async {
                        setState(() => newsNotifications = v);
                        await FirebaseFirestore.instance
                            .collection(FirestoreCollections.users)
                            .doc(user.uid)
                            .update({
                          "notificationSettings.news": v,
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                
                _settingsSection(
                  title: l10n.appearance,
                  items: [
                    _radio(
                      icon: Icons.brightness_4_rounded,
                      label: l10n.systemTheme,
                      value: "system",
                    ),
                    _radio(
                      icon: Icons.light_mode_rounded,
                      label: l10n.lightTheme,
                      value: "light",
                    ),
                    _radio(
                      icon: Icons.dark_mode_rounded,
                      label: l10n.darkTheme,
                      value: "dark",
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                
                _settingsSection(
                  title: l10n.language,
                  items: [
                    _languageItem(
                      icon: Icons.language_rounded,
                      label: l10n.english,
                      value: "en",
                    ),
                    _languageItem(
                      icon: Icons.language_rounded,
                      label: l10n.polish,
                      value: "pl",
                    ),
                    _languageItem(
                      icon: Icons.language_rounded,
                      label: l10n.russian,
                      value: "ru",
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                
                _settingsSection(
                  title: l10n.support,
                  items: [
                    _item(
                      icon: Icons.bug_report_rounded,
                      label: l10n.reportBug,
                      onTap: _reportBug,
                    ),
                    _item(
                      icon: Icons.support_agent_rounded,
                      label: l10n.contactAdmin,
                      onTap: _contactAdmin,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                
                _settingsSection(
                  title: l10n.system,
                  items: [
                    _item(
                      icon: Icons.logout_rounded,
                      label: l10n.logout,
                      color: Colors.red,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  
  
  

  Widget _settingsSection({
    required String title,
    required List<Widget> items,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AppCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),
          ...items,
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final itemColor = color ?? (isDark ? Colors.white : Colors.black87);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: itemColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: itemColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: isDark ? Colors.grey[400] : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _toggle({
    required IconData icon,
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _radio({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: () async {
        if (themeMode == value) return;
        
        if (mounted) {
        setState(() => themeMode = value);
        }
        
        ThemeMode mode;
        switch (value) {
          case 'light':
            mode = ThemeMode.light;
            break;
          case 'dark':
            mode = ThemeMode.dark;
            break;
          default:
            mode = ThemeMode.system;
        }
        
        await MyApp.appStateNotifier.updateThemeMode(mode);
        
        if (mounted) {
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: themeMode,
              activeColor: Colors.blue,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.blue;
                }
                return isDark ? Colors.grey[600]! : Colors.grey[400]!;
              }),
              onChanged: (v) async {
                if (v == null || v == themeMode) return;
                
                if (mounted) {
                setState(() => themeMode = v);
                }
                
                ThemeMode mode;
                switch (v) {
                  case 'light':
                    mode = ThemeMode.light;
                    break;
                  case 'dark':
                    mode = ThemeMode.dark;
                    break;
                  default:
                    mode = ThemeMode.system;
                }
                
                await MyApp.appStateNotifier.updateThemeMode(mode);
                
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: () async {
        if (language == value) return;
        
        if (mounted) {
        setState(() => language = value);
        }
        
        await MyApp.appStateNotifier.updateLocale(Locale(value));
        
        if (mounted) {
          setState(() {});
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: language,
              activeColor: Colors.blue,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.blue;
                }
                return isDark ? Colors.grey[600]! : Colors.grey[400]!;
              }),
              onChanged: (v) async {
                if (v == null || v == language) return;
                
                if (mounted) {
                setState(() => language = v);
                }
                
                await MyApp.appStateNotifier.updateLocale(Locale(v));
                
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}


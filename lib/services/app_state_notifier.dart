import 'package:flutter/material.dart';
import 'settings_service.dart';

class AppStateNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  AppStateNotifier() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await SettingsService.getLanguage();
    final themeModeStr = await SettingsService.getThemeMode();

    _locale = Locale(language);
    
    switch (themeModeStr) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> updateLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    await SettingsService.setLanguage(locale.languageCode);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _themeMode = themeMode;
    
    String themeModeStr = 'system';
    switch (themeMode) {
      case ThemeMode.light:
        themeModeStr = 'light';
        break;
      case ThemeMode.dark:
        themeModeStr = 'dark';
        break;
      case ThemeMode.system:
        themeModeStr = 'system';
        break;
    }
    
    await SettingsService.setThemeMode(themeModeStr);
    notifyListeners();
  }
}


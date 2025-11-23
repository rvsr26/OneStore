import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 📦 Add this to pubspec.yaml

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get themeMode => _mode;

  // Helper to check if currently dark (considers System mode too)
  bool get isDarkMode {
    if (_mode == ThemeMode.system) {
      // You usually need BuildContext to check system brightness accurately,
      // but this is a safe fallback for simple toggles.
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _mode == ThemeMode.dark;
  }

  ThemeProvider() {
    loadTheme(); // 🟢 Auto-load on startup
  }

  void toggleTheme(bool isDark) {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    saveTheme(isDark);
  }

  // FEATURE: Reset to System Default
  void setSystemTheme() {
    _mode = ThemeMode.system;
    notifyListeners();
    removeThemePreference();
  }

  // 💾 FEATURE: Persistence
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  Future<void> removeThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_dark_mode');
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // If key doesn't exist, it stays as ThemeMode.system (default)
    if (prefs.containsKey('is_dark_mode')) {
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _mode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
}
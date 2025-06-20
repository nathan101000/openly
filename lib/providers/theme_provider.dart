import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _seedKey = 'seed_color';
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = const Color(0xff4b5c92);

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get(_themeKey);
    final modeStr = raw is String ? raw : ThemeMode.system.name;
    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => ThemeMode.system,
    );
    final seed = prefs.getInt(_seedKey);
    if (seed != null) _seedColor = Color(seed);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    await prefs.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }

  Future<void> updateSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _seedColor = color;
    await prefs.setInt(_seedKey, color.toARGB32());
    notifyListeners();
  }
}

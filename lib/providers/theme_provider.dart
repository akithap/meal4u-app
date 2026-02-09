import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isManual = false;

  ThemeMode get themeMode => _themeMode;
  bool get isManual => _isManual;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _isManual = true; // User manually changed it
    notifyListeners();
  }

  void updateThemeFromSensor(bool isDark) {
    if (_isManual) return; // Ignore sensor if user manually set it
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void resetToAuto() {
    _isManual = false;
    notifyListeners();
  }
}

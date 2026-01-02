import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  ThemeData get currentTheme =>
      _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

  bool get isDark => _isDark;
  bool get isDarkMode => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}


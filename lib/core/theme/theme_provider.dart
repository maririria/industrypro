import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  double _fontSizeMultiplier = 1.0;

  bool get isDark => _isDark;
  bool get isDarkMode => _isDark; 
  double get fontSizeMultiplier => _fontSizeMultiplier;

  ThemeData get currentTheme => _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setFontSize(String size) {
    if (size == 'Small') _fontSizeMultiplier = 0.8;
    else if (size == 'Medium') _fontSizeMultiplier = 1.0;
    else if (size == 'Large') _fontSizeMultiplier = 1.3;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  double _fontSizeMultiplier = 1.0;

  bool get isDark => _isDark;
  bool get isDarkMode => _isDark; 
  double get fontSizeMultiplier => _fontSizeMultiplier;

ThemeData get currentTheme => _isDark 
    ? ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.transparent,
      ) 
    : ThemeData.light().copyWith(
        primaryColor: const Color(0xFF4A148C), // Deep Purple
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A148C)),
          bodyMedium: TextStyle(color: Color(0xFF4A148C)),
        ),
      );
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
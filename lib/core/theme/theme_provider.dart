import 'package:flutter/material.dart';
import 'app_theme.dart'; // Upar wali file ko yahan import karein

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Ye getter decide karega ke screen par light theme dikhani hai ya dark
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Ye screen ko update karega
  }
}
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF5D1B80),
    scaffoldBackgroundColor: Colors.transparent, 
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF5D1B80)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepPurpleAccent,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Poppins',
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );
}
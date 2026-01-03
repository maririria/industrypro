import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    double scale = themeProvider.fontSizeMultiplier;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hey, Maria",
            style: TextStyle(
              fontSize: 22 * scale,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _glassCard("Active Jobs", isDark, scale),
          _glassCard("Deadlines this week", isDark, scale),
          _glassCard("Completed", isDark, scale),
          _glassCard("Pending", isDark, scale),
          const SizedBox(height: 100), // Navbar ke liye space
        ],
      ),
    );
  }

  Widget _glassCard(String title, bool isDark, double scale) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.15 : 0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF5D1B80),
          fontSize: 18 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
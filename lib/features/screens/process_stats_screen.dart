import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';

class ProcessStatsScreen extends StatelessWidget {
  final String title;
  final Map<String, dynamic> stats; // 🆕 Data coming from Detail Screen

  const ProcessStatsScreen({super.key, required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;
    final scale = themeProvider.fontSizeMultiplier;
    final primaryPurple = const Color(0xFF4A148C);
    final color = isDark ? Colors.white : primaryPurple;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark ? 'assets/images/bg_dark.png' : 'assets/images/bg_light.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, color, scale),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildStatCard("Total Jobs", stats['total'].toString(), Icons.assignment, Colors.blue, isDark, scale, primaryPurple),
                      _buildStatCard("Completed", stats['completed'].toString(), Icons.check_circle, Colors.green, isDark, scale, primaryPurple),
                      _buildStatCard("Pending", stats['pending'].toString(), Icons.pending_actions, Colors.orange, isDark, scale, primaryPurple),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color, double scale) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.arrow_back_ios, color: color), onPressed: () => Navigator.pop(context)),
          Text("$title Stats", style: GoogleFonts.balooBhai2(fontSize: 28 * scale, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color accent, bool isDark, double scale, Color purple) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: accent.withValues(alpha: 0.2),
            child: Icon(icon, color: accent, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 14 * scale, color: purple, fontWeight: FontWeight.bold)),
              Text(count, style: GoogleFonts.balooBhai2(fontSize: 32 * scale, fontWeight: FontWeight.bold, color: purple)),
            ],
          ),
        ],
      ),
    );
  }
}
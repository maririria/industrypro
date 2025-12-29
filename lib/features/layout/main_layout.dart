import 'package:flutter/material.dart';
import '../components/bottom_navbar.dart';

import '../screens/home_screen.dart';
import '../screens/processes_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const MainLayout({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final pages = const [
    HomeScreen(),
    ProcessesScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          /// 🔹 BACKGROUND IMAGE (LIGHT / DARK)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.isDark
                      ? 'lib/assets/bg_dark.png'
                      : 'lib/assets/bg_light.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🔹 CONTENT
          SafeArea(
            child: Column(
              children: [
                /// TOP SIMPLE BAR
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "IndustryPro",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      GestureDetector(
                        onTap: widget.onToggleTheme,
                        child: const Icon(Icons.brightness_6),
                      ),
                    ],
                  ),
                ),

                Expanded(child: pages[currentIndex]),
              ],
            ),
          ),
        ],
      ),

      /// 🔹 BOTTOM BAR ALWAYS VISIBLE
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}

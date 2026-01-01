import 'package:flutter/material.dart';
import '../components/bottom_navbar.dart';
import '../screens/home_screen.dart';
import '../screens/processes_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final List<dynamic> userRoles; // Login se milne wale roles yahan ayenge

  const MainLayout({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.userRoles,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  // Role ke mutabiq pages ko filter karne ki logic
  List<Widget> getFilteredPages() {
    List<Widget> availablePages = [const HomeScreen()];

    // Agar user worker hai aur uske pas 'printing' ya 'pasting' role hai
    if (widget.userRoles.contains('printing') || 
        widget.userRoles.contains('pasting') ||
        widget.userRoles.contains('admin')) {
      availablePages.add(const ProcessesScreen());
    }

    // Reports sirf admin ya specific roles ko dikhayen
    if (widget.userRoles.contains('admin')) {
      availablePages.add(const ReportsScreen());
    }

    availablePages.add(const ProfileScreen());
    return availablePages;
  }

  @override
  Widget build(BuildContext context) {
    final pages = getFilteredPages();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  widget.isDark ? 'assets/images/bg_dark.png' : 'assets/images/bg_light.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "IndustryPro",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: widget.onToggleTheme,
                        child: const Icon(Icons.brightness_6),
                      ),
                    ],
                  ),
                ),
                // Index check taake error na aaye agar pages kam hon
                Expanded(child: pages[currentIndex < pages.length ? currentIndex : 0]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}
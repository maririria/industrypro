import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../components/bottom_navbar.dart';
import '../screens/home_screen.dart';
import '../screens/processes_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final bool isDark; 
  final VoidCallback onToggleTheme; 
  final List<dynamic> userRoles;

  const MainLayout({
    super.key, 
    required this.isDark, 
    required this.onToggleTheme, 
    required this.userRoles
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  List<Widget> getFilteredPages() {
    List<Widget> pages = [const HomeScreen()];
    
    if (widget.userRoles.contains('printing') || 
        widget.userRoles.contains('pasting') || 
        widget.userRoles.contains('admin') ||
        widget.userRoles.contains('plates')) { 
      // 🔹 Important: ProcessesScreen mein roles pass karein
      pages.add(ProcessesScreen(userRoles: widget.userRoles)); 
    }
    
    if (widget.userRoles.contains('admin')) {
      pages.add(const ReportsScreen());
    }
    
    pages.add(const ProfileScreen());
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final pages = getFilteredPages();
    final currentIsDark = themeProvider.isDark;

    return Scaffold(
      extendBody: true, 
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              currentIsDark ? 'assets/images/bg_dark.png' : 'assets/images/bg_light.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "IndustryPro",
                        style: GoogleFonts.balooBhai2( 
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: currentIsDark ? Colors.white : const Color(0xFF4A148C),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings, 
                          size: 28,
                          color: currentIsDark ? Colors.white : const Color(0xFF4A148C)
                        ),
                        // 🔹 Ab yahan error nahi aayega kyunke function niche defined hai
                        onPressed: () => _showSettingsMenu(context, themeProvider),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: pages[currentIndex < pages.length ? currentIndex : 0],
                ),
              ],
            ),
          ),
        ],
      ),
      
     bottomNavigationBar: BottomNavbar(
  currentIndex: currentIndex,
  onTap: (index) {
    setState(() {
      currentIndex = index;
    });
  },
  userRoles: widget.userRoles, 
),
    );
  }

  
  void _showSettingsMenu(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: provider.isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "App Settings", 
          style: GoogleFonts.balooBhai2(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(provider.isDark ? Icons.dark_mode : Icons.light_mode, color: Colors.purple),
              title: const Text("Toggle Theme"),
              onTap: () {
                provider.toggleTheme();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
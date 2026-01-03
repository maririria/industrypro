import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<dynamic> userRoles; // 🔹 Added userRoles

  const BottomNavbar({
    super.key, 
    required this.currentIndex, 
    required this.onTap, 
    required this.userRoles
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    // 🔹 Role based items list
    List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
    ];

    // Check for Processes access
    if (userRoles.contains('printing') || 
        userRoles.contains('pasting') || 
        userRoles.contains('admin') || 
        userRoles.contains('plates')) {
      navItems.add({'icon': Icons.factory_outlined, 'label': 'Processes'});
    }

    // Check for Admin (Reports) access
    if (userRoles.contains('admin')) {
      navItems.add({'icon': Icons.bar_chart_rounded, 'label': 'Reports'});
    }

    // Always show Profile
    navItems.add({'icon': Icons.person_pin_rounded, 'label': 'Account'});

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232335) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItems.length, (index) {
          return _navItem(navItems[index]['icon'], index, isDark);
        }),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, bool isDark) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD1C4E9).withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? const Color(0xFF5D1B80) : Colors.grey,
        ),
      ),
    );
  }
}
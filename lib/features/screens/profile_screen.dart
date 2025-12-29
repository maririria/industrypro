import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
      child: Column(
        children: [
          // 👤 AVATAR
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.8),
            child: const Text(
              "MP",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Mari Parveen",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          _infoTile("Employee ID", "EMP-102"),
          _infoTile("Designation", "Production Manager"),

          const SizedBox(height: 24),

          // 🚪 LOGOUT
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.9),
              foregroundColor: Colors.deepPurple,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        "$title: $value",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}

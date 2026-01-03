import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import karein
import '../../core/theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Loading..."; // Default text

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Screen load hote hi naam fetch karein
  }

  // 🔹 Database se user ka naam lene ka function
  Future<void> _fetchUserName() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Aapke 'profiles' table se naam uthana (agar column ka naam 'full_name' ya 'name' hai)
        final data = await Supabase.instance.client
            .from('profiles')
            .select('full_name') // 👈 Apne table ke column name ke mutabiq check karein
            .eq('id', user.id)
            .maybeSingle();

        if (data != null && data['full_name'] != null) {
          setState(() {
            userName = data['full_name'];
          });
        } else {
          // Agar profile mein naam nahi hai toh email ka pehla hissa dikhayein
          setState(() {
            userName = user.email?.split('@')[0] ?? "User";
          });
        }
      }
    } catch (e) {
      setState(() {
        userName = "Welcome"; 
      });
      print("Error fetching user name: $e");
    }
  }

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
          const SizedBox(height: 20), // Thori space
          Text(
            "Hey, $userName", // 👈 Ab yahan dynamic name aayega
            style: TextStyle(
              fontSize: 22 * scale,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _glassCard("Active Jobs", isDark, scale),
          _glassCard("Deadlines this week", isDark, scale),
          _glassCard("Completed", isDark, scale),
          _glassCard("Pending", isDark, scale),
          const SizedBox(height: 100),
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
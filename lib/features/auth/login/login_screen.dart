import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_controller.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../features/layout/main_layout.dart';// Correctly navigating to Layout
import '../signup/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emp = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emp.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    // Fixed path according to your structure
    final bgImage = isDark 
        ? 'assets/images/bg_dark.png'  // Updated paths based on your previous logs
        : 'assets/images/bg_light.png';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              bgImage,
              fit: BoxFit.cover,
              gaplessPlayback: true, 
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380), 
                  child: _buildGlassCard(context, themeProvider, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, ThemeProvider theme, bool isDark) {
    final controller = context.watch<LoginController>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.black.withOpacity(0.4) 
                : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => theme.toggleTheme(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        ),
                      ),
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF9C27B0),
                  child: Icon(Icons.lock_outline, color: Colors.white, size: 28),
                ),
                
                const SizedBox(height: 15),
                const Text(
                  "Welcome to",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Text(
                  "IndustryPro",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 30),

                _inputLabel("Employee Code"),
                _inputField(
                  controller: _emp, 
                  hint: "Enter code", 
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Code is required" : null,
                ),
                
                const SizedBox(height: 15),

                _inputLabel("Password"),
                _inputField(
                  controller: _pass, 
                  hint: "Enter password", 
                  icon: Icons.lock_outline, 
                  isPassword: true,
                  validator: (v) => v!.length < 6 ? "Password too short" : null,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF673AB7), Color(0xFF2196F3)],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: controller.loading ? null : () => _handleLogin(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                      child: controller.loading
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              "Login", 
                              style: TextStyle(
                                color: Colors.white, 
                                fontSize: 16, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6, left: 4),
        child: Text(
          label, 
          style: const TextStyle(color: Colors.white, fontSize: 13)
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

 void _handleLogin(BuildContext context) async {
  if (_formKey.currentState!.validate()) {
    final controller = Provider.of<LoginController>(context, listen: false);
    // Theme provider ka access yahan bhi chahiye parameters pass karne ke liye
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final success = await controller.login(
      employeeCode: _emp.text.trim(),
      password: _pass.text.trim(),
    );

    if (success && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(
          builder: (_) => MainLayout(
            isDark: themeProvider.isDarkMode, // Pass isDark parameter
            onToggleTheme: () => themeProvider.toggleTheme(), // Pass toggle function
          ),
        ),
        (route) => false,
      );
    } else if (context.mounted && controller.error != null) {
      // Error message handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error!)),
      );
    }
  }
}
}
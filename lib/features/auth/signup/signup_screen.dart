import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_controller.dart';
import '../../../core/theme/theme_provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupController(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatefulWidget {
  const _SignupView();

  @override
  State<_SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<_SignupView> {
  // ERROR FIX: Added Name Controller
  final _name = TextEditingController(); 
  final _emp = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose(); 
    _emp.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final controller = context.watch<SignupController>();

    final bgImage = isDark 
        ? 'assets/images/operativexD.jpeg' 
        : 'assets/images/operativexL.jpg';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(bgImage, fit: BoxFit.cover, gaplessPlayback: true),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: _buildGlassSignupCard(context, controller, isDark),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSignupCard(BuildContext context, SignupController controller, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF9C27B0),
                  child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 10),
                const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                _inputLabel("Full Name"),
                _inputField(controller: _name, hint: "Enter your name", icon: Icons.person_outline),
                const SizedBox(height: 15),

                _inputLabel("Employee Code"),
                _inputField(controller: _emp, hint: "Enter code", icon: Icons.badge_outlined),
                const SizedBox(height: 15),
                
                _inputLabel("Password"),
                _inputField(controller: _pass, hint: "Min 6 chars", icon: Icons.lock_outline, isPassword: true),
                
                const SizedBox(height: 25),
                _buildActionButton(controller),

                // --- SOCIAL LOGIN BUTTONS (AB YAHAN HAI!) ---
                const SizedBox(height: 20),
                const Text("Or continue with", style: TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialButton(
                      icon: Icons.g_mobiledata, 
                      onTap: () => controller.signInWithGoogle()
                    ),
                    _socialButton(
                      icon: Icons.facebook, 
                      onTap: () => controller.signInWithFacebook()
                    ),
                  ],
                ),
                // ------------------------------------------
                
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(SignupController controller) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFF673AB7), Color(0xFF2196F3)]),
        ),
        child: ElevatedButton(
          onPressed: controller.loading ? null : () => _handleSignup(controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, 
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: controller.loading 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)));
  }

  Widget _inputField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v == null || v.isEmpty ? "Required" : null,
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

  void _handleSignup(SignupController controller) async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.signup(
        name: _name.text.trim(), // Fixed the red line error
        employeeCode: _emp.text.trim(),
        password: _pass.text.trim(),
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful!")),
        );
      } else if (controller.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.error!)),
        );
      }
    }
  } 
}
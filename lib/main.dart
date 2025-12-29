import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Imports (Inhe apne folder structure ke mutabiq check kar lein)
import 'firebase_options.dart';
import 'features/auth/login/login_screen.dart'; // New code wala login
import 'features/layout/main_layout.dart';             // Old code wala layout
import 'core/theme/theme_provider.dart';      // Theme logic

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize karna zaroori hai backend ke liye
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // Provider ko yahan wrap kiya taake puri app ko theme mile
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const IndustryProApp(),
    ),
  );
}

class IndustryProApp extends StatelessWidget {
  const IndustryProApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer theme changes ko listen karega
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Industry Pro',
  
          theme: themeProvider.currentTheme, 
          
         
          home: const LoginScreen(), 
        );
      },
    );
  }
}
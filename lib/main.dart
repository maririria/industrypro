import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:provider/provider.dart';
import 'features/auth/login/login_screen.dart'; 
import 'core/theme/theme_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase Initialize with Redirect URL
  await Supabase.initialize(
    url: 'https://atjzalcufttndzjyjigp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF0anphbGN1ZnR0bmR6anlqaWdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTM4MDEsImV4cCI6MjA3NzIyOTgwMX0.a426Q3RwaHxrtUsbCH-5bwDA9yKn-0SGD6ScznXZkO8',
    
  );
  
  runApp(
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
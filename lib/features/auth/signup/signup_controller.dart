import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool loading = false;
  String? error;

  // 1. Email/Password Signup + Store Profile in 'profiles' table
  Future<bool> signup({
    required String employeeCode, 
    required String password, 
    required String name
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final email = "$employeeCode@operativex.com";

      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (res.user != null) {
        // 'users' ki jagah 'profiles' table use karein
        await _supabase.from('profiles').insert({
          'id': res.user!.id,
          'employee_code': employeeCode, 
          'role': 'employee',
          'roles': ['employee'], // Array format agar zaroorat ho
          'created_at': DateTime.now().toIso8601String(),
        });
        
        return true;
      }
    } on AuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = "An unexpected error occurred: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
    return false;
  }

  // 2. Google Sign In 
  Future<void> signInWithGoogle() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'atjzalcufttndzjyjigp.supabase.co/auth/v1/callback', 
      );
      
     
    } catch (e) {
      error = "Google Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 3. Facebook Sign In
  Future<void> signInWithFacebook() async {
    try {
      loading = true;
      notifyListeners();

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'https://atjzalcufttndzjyjigp.supabase.co/auth/v1/callback',
      );
    } catch (e) {
      error = "Facebook Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController extends ChangeNotifier {
  // Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;
  
  bool loading = false;
  String? error;

  // 1. Email/Password Signup + Store Profile in 'users' table
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

      // Supabase Auth mein user create karna
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name}, // Metadata mein name save karna
      );

      if (res.user != null) {
        // Supabase mein 'users' table mein extra data save karna
        // Note: Make sure aapne Supabase DB mein 'users' table banaya hua hai
        await _supabase.from('users').insert({
          'id': res.user!.id, // Auth ID
          'name': name,
          'email': email,
          'role': 'employee',
          'created_at': DateTime.now().toIso8601String(),
        });
        
        loading = false;
        notifyListeners();
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

  // 2. Google Sign In (Supabase style)
  Future<void> signInWithGoogle() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // Supabase natively Google login support karta hai
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // redirectTo: 'io.supabase.flutter://login-callback/', // Optional: deep link configuration
      );
      
    } catch (e) {
      error = "Google Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 3. Facebook Sign In (Supabase style)
  Future<void> signInWithFacebook() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
      );
    } catch (e) {
      error = "Facebook Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
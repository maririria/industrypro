import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool loading = false;
  String? error;
  
  // Role based navigation ke liye variables
  String? userRole; // Main role (e.g., admin, worker)
  List<dynamic>? userRoles; // Specific departments (e.g., ['printing', 'pasting'])

  Future<bool> login({required String employeeCode, required String password}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Email formatting (Aapki original logic)
      String email = employeeCode.trim();
      if (!email.contains('@')) {
        email = "$email@operativex.com";
      }

      // 1. Supabase Auth se Login
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password.trim(),
      );

      if (res.user != null) {
        // 2. 'profiles' table se role fetch karna (Desktop logic ke mutabiq)
        final profileData = await _supabase
            .from('profiles')
            .select('role, roles, employee_code')
            .eq('id', res.user!.id)
            .single();

        // Data save karna
        userRole = profileData['role'];
        userRoles = profileData['roles'] as List<dynamic>;

        loading = false;
        notifyListeners();
        return true;
      }
    } on AuthException catch (e) {
      // Supabase specific error handling
      error = e.message;
    } catch (e) {
      error = "An unexpected error occurred: $e";
    }

    loading = false;
    notifyListeners();
    return false;
  }
}
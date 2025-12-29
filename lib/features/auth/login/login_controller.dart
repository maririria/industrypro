import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error;

  Future<bool> login({
    required String employeeCode,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      String email = employeeCode.trim();

      // Logic: If user provides only a code, append the domain. 
      // If they provide a full email (like gmail), use it as is.
      if (!email.contains('@')) {
        email = "$email@operativex.com";
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // Professional English Error Handling
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        error = "Invalid employee code or password.";
      } else if (e.code == 'wrong-password') {
        error = "The password you entered is incorrect.";
      } else if (e.code == 'invalid-email') {
        error = "The email or employee code format is invalid.";
      } else if (e.code == 'user-disabled') {
        error = "This account has been disabled. Please contact admin.";
      } else if (e.code == 'too-many-requests') {
        // This handles the "Unusual Activity" / Blocking error
        error = "Too many failed attempts. This device is temporarily blocked. Please try again later.";
      } else {
        error = e.message ?? "An unexpected authentication error occurred.";
      }
    } catch (e) {
      error = "Connection problem. Please check your internet.";
    }

    loading = false;
    notifyListeners();
    return false;
  }
}
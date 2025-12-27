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
      final email = "$employeeCode@operativex.com";

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? "Login failed";
    } catch (_) {
      error = "Something went wrong";
    }

    loading = false;
    notifyListeners();
    return false;
  }
}

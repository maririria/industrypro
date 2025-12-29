import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SignupController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  String? error;

  // 1. Email/Password Signup
  Future<bool> signup({required String employeeCode, required String password}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final email = "$employeeCode@operativex.com";
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      error = e.message;
    }
    loading = false;
    notifyListeners();
    return false;
  }

  // 2. Google Sign In Logic
  Future<void> signInWithGoogle() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        loading = false;
        notifyListeners();
        return; // User ne cancel kar diya
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
      
    } catch (e) {
      error = "Google Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // 3. Facebook Sign In Logic
  Future<void> signInWithFacebook() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // Trigger Facebook Login
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a Facebook Auth credential
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // Sign in to Firebase
        await _auth.signInWithCredential(credential);
      } else {
        error = "Facebook Login ${result.status.name}";
      }
    } catch (e) {
      error = "Facebook Sign-In failed: $e";
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
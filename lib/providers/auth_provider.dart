import 'dart:async'; // Required for StreamSubscription
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isAuthLoading = true;
  StreamSubscription<User?>? _authSubscription; // To avoid memory leaks

  AuthProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((u) {
      _user = u;
      _isAuthLoading = false;
      notifyListeners();
    });
  }

  bool get isLoggedIn => _user != null;
  bool get isAuthLoading => _isAuthLoading;
  User? get user => _user;

  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _auth.currentUser;
    notifyListeners();
  }

  // FEATURE: Human-Readable Error Parsing
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password provided is too weak.';
        default:
          return e.message ?? 'Authentication failed.';
      }
    }
    return e.toString();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  // FEATURE: Password Reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } catch (e) {
      return _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Prevent memory leaks
    super.dispose();
  }
}
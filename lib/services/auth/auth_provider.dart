import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  User? user;

  AuthProvider(this._authService) {
    _authService.authStateChanges.listen((user) {
      this.user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => user != null;

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}

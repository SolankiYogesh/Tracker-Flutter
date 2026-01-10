import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/network/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository auth;
  User? user;

  AuthProvider(this.auth) {
    auth.authStateChanges.listen((user) {
      this.user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => user != null;

  Future<void> signInWithGoogle() async {
    await auth.signInWithGoogle();
  }

  Future<void> logout() async {
    await auth.signOut();
  }
}

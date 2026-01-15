import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker/models/user_create.dart';
import 'package:tracker/models/user_response.dart';
import 'package:tracker/network/repositories/auth_repository.dart';
import 'package:tracker/network/repositories/user_repository.dart';
import 'package:tracker/services/database_helper.dart';

class AuthServiceProvider extends ChangeNotifier {
  AuthServiceProvider({required this.auth, required this.userRepo}) {
    auth.authStateChanges.listen((user) async {
      firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        syncUserWithBE(firebaseUser!);
      }
      firebaseUser = user;
      if (user != null) {
        await syncUserWithBE(user);
      } else {
        appUser = null;
      }
    });
  }

  final AuthRepository auth;
  final UserRepository userRepo;

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  UserResponse? appUser;
  bool get isAuthenticated => firebaseUser != null;
  String? get userId => appUser?.id;

  Future<void> signInWithGoogle() async {
    final userCredential = await auth.signInWithGoogle();
    firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      await syncUserWithBE(firebaseUser!);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await auth.signOut();
    firebaseUser = null;
    appUser = null;
    await DatabaseHelper().clearUser();
    notifyListeners();
  }

  Future<void> syncUserWithBE(User user) async {
    final userCreate = UserCreate(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      picture: user.photoURL,
    );
    final response = await userRepo.createUser(userCreate);
    appUser = response;
    await DatabaseHelper().saveUser(response);
    notifyListeners();
  }
}

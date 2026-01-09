import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/screens/login_screen.dart';
import 'package:tracker/screens/permission_screen.dart';
import 'auth_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    debugPrint(auth.user.toString());
    debugPrint(auth.isAuthenticated.toString());
    debugPrint(auth.toString());
    debugPrint(auth.hashCode.toString());

    if (auth.isAuthenticated) {
      return const PermissionScreen();
    } else {
      return const LoginScreen();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/screens/auth/login_screen.dart';
import 'package:tracker/screens/main/permissions/permission_screen.dart';
import '../../providers/auth_service_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthServiceProvider>();

    if (auth.isAuthenticated) {
      return const PermissionScreen();
    } else {
      return const LoginScreen();
    }
  }
}

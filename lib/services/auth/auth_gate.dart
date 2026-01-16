import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/screens/auth/login_screen.dart';
import 'package:tracker/screens/main/permissions/permission_screen.dart';
import 'package:tracker/router/main_navigation_screen.dart';
import 'package:tracker/utils/permission_utils.dart';
import '../../providers/auth_service_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<bool>? _permissionsFuture;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthServiceProvider>();

    if (!auth.isAuthenticated) {
      _permissionsFuture = null;
      return const LoginScreen();
    }

    _permissionsFuture ??= PermissionUtils.areAllPermissionsGranted();

    return FutureBuilder<bool>(
      future: _permissionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF141416),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9FA8DA),
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const MainNavigationScreen();
        } else {
          return const PermissionScreen();
        }
      },
    );
  }
}

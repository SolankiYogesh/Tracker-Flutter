import 'package:flutter/material.dart';
import 'package:sign_button/sign_button.dart';
import 'package:tracker/services/auth/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> loginWithGoogle(context) async {
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LoginScreen')),
      body: Center(
        child: SignInButton(
          buttonType: ButtonType.google,
          onPressed: () {
            loginWithGoogle(context);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:tracker/services/auth/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> loginWithGoogle() async {
      try {
        await context.read<AuthProvider>().signInWithGoogle();
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('LoginScreen')),
      body: Center(
        child: SignInButton(
          buttonType: ButtonType.google,
          onPressed: () {
            loginWithGoogle();
          },
        ),
      ),
    );
  }
}

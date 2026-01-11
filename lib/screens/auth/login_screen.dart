import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/utils/app_logger.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> loginWithGoogle() async {
      try {
        await context.read<AuthServiceProvider>().signInWithGoogle();
      } catch (e) {
        AppLogger.log(e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
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

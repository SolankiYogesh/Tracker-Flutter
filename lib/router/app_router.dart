import 'package:flutter/material.dart';
import 'package:tracker/screens/main/settings/help_support/help_support_screen.dart';
import 'package:tracker/screens/main/settings/about/about_screen.dart';
import 'package:tracker/screens/main/settings/data_storage/data_storage_screen.dart';
import 'package:tracker/screens/main/settings/privacy_security/privacy_security_screen.dart';
import 'package:tracker/services/auth/auth_gate.dart';
import 'package:tracker/screens/main/permissions/permission_screen.dart';
import 'package:tracker/router/main_navigation_screen.dart';

import 'package:tracker/screens/main/settings/edit_profile_screen.dart';

class AppRouter {
  static const String root = '/';
  static const String permissions = '/permissions';
  static const String main = '/main';
  static const String helpSupport = '/help-support';
  static const String about = '/about';
  static const String dataStorage = '/data-storage';
  static const String privacySecurity = '/privacy-security';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case root:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case permissions:
        return MaterialPageRoute(builder: (_) => const PermissionScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      case helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case dataStorage:
        return MaterialPageRoute(builder: (_) => const DataStorageScreen());
      case privacySecurity:
        return MaterialPageRoute(builder: (_) => const PrivacySecurityScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

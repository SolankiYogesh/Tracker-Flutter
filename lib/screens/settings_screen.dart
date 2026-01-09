import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:provider/provider.dart';
import 'package:tracker/services/auth/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var isDarkTheme =
        ThemeModelInheritedNotifier.of(context).theme.brightness ==
        Brightness.dark;

    Future<void> logOut() async {
      try {
        await context.read<AuthProvider>().logout();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ThemeSwitcher(
                      clipper: const ThemeSwitcherCircleClipper(),
                      builder: (context) {
                        return GestureDetector(
                          onTapDown: (details) {
                            ThemeSwitcher.of(context).changeTheme(
                              theme: isDarkTheme
                                  ? ThemeData.light(useMaterial3: true)
                                  : ThemeData.dark(useMaterial3: true),
                              offset: details.localPosition,
                              isReversed: isDarkTheme,
                            );
                          },
                          child: AbsorbPointer(
                            absorbing: true,
                            child: SwitchListTile(
                              title: const Text('Dark Theme'),
                              value: isDarkTheme,
                              onChanged: (val) {},
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    logOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

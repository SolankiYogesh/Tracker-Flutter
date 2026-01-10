import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/theme/app_theme.dart';
import 'package:tracker/utils/app_logger.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkTheme = false;

  Future<void> initStates() async {
    final theme = await DatabaseHelper().getIsDarkTheme();

    AppLogger.log("theme ${theme}");
    setState(() {
      isDarkTheme = theme;
    });
  }

  @override
  void initState() {
    initStates();
    super.initState();
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await context.read<AuthServiceProvider>().logout();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> changeTheme(TapDownDetails details, BuildContext context) async {
    try {
      final currentState = isDarkTheme;
      ThemeSwitcher.of(context).changeTheme(
        theme: currentState ? AppTheme.lightTheme : AppTheme.darkTheme,
        offset: details.localPosition,
        isReversed: isDarkTheme,
      );
      setState(() {
        isDarkTheme = !currentState;
      });
      await DatabaseHelper().setIsDarkTheme(!currentState);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            changeTheme(details, context);
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
                    logOut(context);
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

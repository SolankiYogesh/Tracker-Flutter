import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var isDarkTheme =
        ThemeModelInheritedNotifier.of(context).theme.brightness ==
        Brightness.dark;
    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Theme'),
            value:
                ThemeModelInheritedNotifier.of(context).theme.brightness ==
                Brightness.dark,
            onChanged: (bool value) {},
          ),
        ],
      ),
    );
  }
}

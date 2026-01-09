import 'package:flutter/material.dart';
import 'package:tracker/screens/map_screen.dart';
import 'package:tracker/screens/stats_screen.dart';
import 'package:tracker/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const MainNavigationScreen({super.key, required this.themeNotifier});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MapScreen(),
      const StatsScreen(),
      SettingsScreen(themeNotifier: widget.themeNotifier),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
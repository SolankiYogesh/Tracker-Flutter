import 'package:flutter/material.dart';
import 'package:tracker/screens/map_screen.dart';
import 'package:tracker/screens/stats_screen.dart';
import 'package:tracker/screens/settings_screen.dart';
import 'package:background_location_tracker/background_location_tracker.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _startTracking();
    _screens = [const MapScreen(), const StatsScreen(), const SettingsScreen()];
  }

  Future<void> _startTracking() async {
    await BackgroundLocationTrackerManager.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

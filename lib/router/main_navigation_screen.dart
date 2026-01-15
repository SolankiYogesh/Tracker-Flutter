import 'package:flutter/material.dart';
import 'package:tracker/screens/main/achievements/achievements_screen.dart';
import 'package:tracker/screens/main/leaderboard/leaderboard_screen.dart';
import 'package:tracker/screens/main/maps/map_screen.dart';
import 'package:tracker/screens/main/stats/stats_screen.dart';
import 'package:tracker/screens/main/settings/settings_screen.dart';
import 'package:background_location_tracker/background_location_tracker.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const StatsScreen(),
    const AchievementsScreen(),
    const LeaderboardScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    await BackgroundLocationTrackerManager.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedIndex: _currentIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Awards',
          ),
          NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Ranks'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

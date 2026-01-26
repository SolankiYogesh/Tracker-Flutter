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
  final ValueNotifier<int> _tabIndexNotifier = ValueNotifier<int>(0);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      MapScreen(tabIndexNotifier: _tabIndexNotifier),
      StatsScreen(tabIndexNotifier: _tabIndexNotifier),
      const AchievementsScreen(),
      const LeaderboardScreen(),
      const SettingsScreen(),
    ];
    _startTracking();
  }

  @override
  void dispose() {
    _tabIndexNotifier.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    await BackgroundLocationTrackerManager.startTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: _tabIndexNotifier,
        builder: (context, index, child) {
          return IndexedStack(
            index: index,
            children: _screens,
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabIndexNotifier,
        builder: (context, index, child) {
          return NavigationBar(
            onDestinationSelected: (int newIndex) {
              _tabIndexNotifier.value = newIndex;
            },
            selectedIndex: index,
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
              NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
              NavigationDestination(
                icon: Icon(Icons.emoji_events),
                label: 'Awards',
              ),
              NavigationDestination(icon: Icon(Icons.leaderboard), label: 'Ranks'),
              NavigationDestination(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          );
        },
      ),
    );
  }
}


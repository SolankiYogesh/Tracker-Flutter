import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tracker/screens/permission_screen.dart';
import 'package:tracker/services/repo.dart';

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => Repo().update(data),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        trackingInterval: Duration(seconds: 5), // updateIntervalMs
        distanceFilterMeters: 5, // smallestDisplacementMeters
        // fastestTrackingInterval: Duration(seconds: 3), // fastestIntervalMs - Not supported by current plugin
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        distanceFilterMeters: 5, // smallestDisplacementMeters
        restartAfterKill: true,
      ),
    ),
  );
  runApp(const TrackerApp());
}

class TrackerApp extends StatefulWidget {
  const TrackerApp({super.key});

  @override
  State<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends State<TrackerApp> {
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Tracker',
          theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: PermissionScreen(themeNotifier: _themeNotifier),
        );
      },
    );
  }

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }
}

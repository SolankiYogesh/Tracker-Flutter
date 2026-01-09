import 'dart:ui';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tracker/screens/permission_screen.dart';
import 'package:tracker/services/repo.dart';
import 'package:tracker/services/notification.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    if (data.horizontalAccuracy < 50) {
      await Repo().update(data);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  await initNotifications();
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        notificationBody: 'Tracking your location in background',
        trackingInterval: Duration(seconds: 5), // updateIntervalMs
        distanceFilterMeters: 5, // smallestDisplacementMeters
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        distanceFilterMeters: 5, // smallestDisplacementMeters
        restartAfterKill: true,
      ),
    ),
  );
  runApp(TrackerApp());
}

class TrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPlatformDark =
        PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    final initTheme = isPlatformDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return ThemeProvider(
      initTheme: initTheme,
      builder: (_, myTheme) {
        return MaterialApp(
          title: 'Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const PermissionScreen(),
        );
      },
    );
  }
}

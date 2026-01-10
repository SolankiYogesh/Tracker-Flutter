import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tracker/network/repositories/auth_repository.dart';
import 'package:tracker/network/repositories/user_repository.dart';
import 'package:tracker/services/auth/auth_gate.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/repo.dart';
import 'package:tracker/services/notification.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:tracker/theme/app_theme.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final repo = Repo();

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    if (data.horizontalAccuracy < 50) {
      await repo.update(data);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
  final isDarkTheme = await DatabaseHelper().getIsDarkTheme();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthServiceProvider(
        auth: AuthRepository(),
        userRepo: UserRepository(),
      ),
      child: TrackerApp(isDarkTheme: isDarkTheme),
    ),
  );
}

class TrackerApp extends StatelessWidget {
  final bool isDarkTheme;

  const TrackerApp({Key? key, required this.isDarkTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initTheme = isDarkTheme ? AppTheme.darkTheme : AppTheme.lightTheme;
    return ThemeProvider(
      duration: Duration(milliseconds: 700),
      initTheme: initTheme,
      builder: (_, myTheme) {
        return MaterialApp(
          theme: initTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          title: 'Tracker',
          home: const AuthGate(),
        );
      },
    );
  }
}

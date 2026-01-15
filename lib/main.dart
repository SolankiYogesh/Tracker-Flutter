import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tracker/network/repositories/auth_repository.dart';
import 'package:tracker/network/repositories/user_repository.dart';
import 'package:tracker/providers/theme_provider.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/entity_provider.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/repo.dart';
import 'package:tracker/services/notification.dart';
import 'package:tracker/theme/app_theme.dart';
import 'package:tracker/utils/talker.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tracker/router/app_router.dart';

final repo = Repo();

bool _isEnvLoaded = false;

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated((data) async {
    if (!_isEnvLoaded) {
      await dotenv.load(); // Initialize for background isolate
      _isEnvLoaded = true;
    }
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthServiceProvider>(
          create: (_) => AuthServiceProvider(
            auth: AuthRepository(),
            userRepo: UserRepository(),
          ),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(initialIsDark: isDarkTheme),
        ),
        ChangeNotifierProvider<EntityProvider>(create: (_) => EntityProvider()),
      ],
      child: TrackerApp(isDarkTheme: isDarkTheme),
    ),
  );
}

class TrackerApp extends StatelessWidget {

  const TrackerApp({super.key, required this.isDarkTheme});
  final bool isDarkTheme;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      navigatorObservers: [TalkerRouteObserver(talker)],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Tracker',
      initialRoute: AppRouter.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

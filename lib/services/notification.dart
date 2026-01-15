import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:tracker/constants/app_constants.dart';

// Top-level function for background action handling
@pragma('vm:entry-point')
Future<void> notificationTapBackground(
  NotificationResponse notificationResponse,
) async {
  // Needed for plugins to work in background isolate
  WidgetsFlutterBinding.ensureInitialized();

  if (notificationResponse.actionId == 'stop_tracking') {
    try {
      await BackgroundLocationTrackerManager.stopTracking();
      await FlutterLocalNotificationsPlugin().cancel(
        AppConstants.notificationIdTracking,
      );
    } catch (e) {
      AppLogger.error('Error stopping tracking from notification', e);
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (details) async {
      if (details.actionId == 'stop_tracking') {
        await BackgroundLocationTrackerManager.stopTracking();
        await flutterLocalNotificationsPlugin.cancel(
          AppConstants.notificationIdTracking,
        );
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
}

void sendNotification(String text, {String title = 'Tracking Active'}) {
  // Ensure we don't spam initialization, only show
  // (Assuming initNotifications is called in main)

  flutterLocalNotificationsPlugin.show(
    AppConstants.notificationIdTracking, // Fixed ID
    title,
    text,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelIdTracking,
        'Tracking Updates',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        onlyAlertOnce: true,
        actions: [
          AndroidNotificationAction(
            'stop_tracking',
            'Stop Tracking',
            showsUserInterface: false, // Don't open app
            cancelNotification:
                true, // Dismisses the notification immediately on tap
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        sound: null,
        threadIdentifier: 'LIVE_UPDATE_NOTIFICATION',
      ),
    ),
  );
}

void sendCollectionNotification(String title, String body) {
  flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'collection_channel',
        'Collection Updates',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

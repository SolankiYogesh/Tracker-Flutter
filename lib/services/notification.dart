import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void sendNotification(String text, {String title = 'Tracking Active'}) {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  );
  FlutterLocalNotificationsPlugin().initialize(settings);
  FlutterLocalNotificationsPlugin().show(
    777, // Fixed ID to update the same notification
    title,
    text,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'tracking_channel',
        'Tracking Updates',
        importance: Importance.low, // Low importance to avoid sound/vibration spam
        priority: Priority.low,
        ongoing: true,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

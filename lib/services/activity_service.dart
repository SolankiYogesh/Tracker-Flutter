import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

// The callback function should be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ActivityTaskHandler());
}

class ActivityTaskHandler extends TaskHandler {
  StreamSubscription<Activity>? _activitySubscription;
  final _activityRecognition = FlutterActivityRecognition.instance;
  
  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    if (kDebugMode) AppLogger.log('ActivityTaskHandler: onStart');
    
    // Subscribe to activity stream
    _activitySubscription = _activityRecognition.activityStream
        .listen((activity) async {
          _onActivityChange(activity);
    });
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    if (kDebugMode) AppLogger.log('ActivityTaskHandler: onDestroy');
    await _activitySubscription?.cancel();
  }

  // Called when no event is triggered for a long time.
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // Not needed for now
  }
  
  Future<void> _onActivityChange(Activity activity) async {
    final status = activity.type.name; // STILL, WALKING, RUNNING, IN_VEHICLE, etc.
    final confidence = activity.confidence.name;
    
    if (kDebugMode) {
      AppLogger.log('Activity Detected: $status ($confidence)');
    }
    
    // We only care if confidence is medium or high? 
    // For now, let's just log and save everything.
    
    try {
      await DatabaseHelper().setActivityStatus(status);
    } catch (e) {
      if (kDebugMode) AppLogger.error('Failed to save activity status', e);
    }
  }
}

class ActivityService {
  factory ActivityService() => _instance;

  ActivityService._internal();

  static final ActivityService _instance = ActivityService._internal();

  Future<void> init() async {
    _initForegroundTask();
  }

  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'activity_recognition',
        channelName: 'Activity Recognition',
        channelDescription: 'Tracking your activity to improve location accuracy',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      final result = await FlutterForegroundTask.restartService();
      return result.success;
    } else {
      final serviceRequestResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Activity Tracker Active',
        notificationText: 'Monitoring movement for better accuracy',
        notificationIcon: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher_icon',
        ),
        callback: startCallback,
      );
      return serviceRequestResult.success;
    }
  }

  Future<bool> startServiceIfPermitted() async {
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      return startService();
    } else {
      AppLogger.log('ActivityService: Permission not granted, skipping start.');
      return false;
    }
  }

  Future<bool> stopService() async {
    final result = await FlutterForegroundTask.stopService();
    return result.success;
  }
}

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker/models/location_point.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';
import 'package:tracker/utils/app_logger.dart';

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final user = await DatabaseHelper().getCurrentUser();
    final text =
        'Location: ${data.lat.toStringAsFixed(5)}, ${data.lon.toStringAsFixed(5)}';
    final locationPoint = LocationPoint(
      latitude: data.lat,
      longitude: data.lon,
      recordedAt: DateTime.now(),
      accuracy: data.horizontalAccuracy,
      altitude: data.alt,
      bearing: data.course,
      speed: data.speed,
      userId: user!.id,
    );
    if (kDebugMode) {
      AppLogger.log(
        'New LocationPoint: ${_locationPointToString(locationPoint)}',
      );
    }

    sendNotification(text);
  }
}

String _locationPointToString(LocationPoint point) {
  return '''
  userId: ${point.userId},
  lat: ${point.latitude.toStringAsFixed(5)},
  lon: ${point.longitude.toStringAsFixed(5)},
  accuracy: ${point.accuracy},
  altitude: ${point.altitude},
  speed: ${point.speed},
  bearing: ${point.bearing},
  recordedAt: ${point.recordedAt.toIso8601String()}
  ''';
}

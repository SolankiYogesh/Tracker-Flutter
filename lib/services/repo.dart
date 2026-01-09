import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final text = 'Lat: ${data.lat} Lon: ${data.lon}';
    if (kDebugMode) {
      print(text);
    }
    
    // We treat the current time as the session ID for now, or use a fixed one.
    // Ideally, we'd want a way to distinguish sessions. 
    // For this requirements, let's just use a single session or day-based session?
    // User said "Same color for session". 
    // Let's use 0 as default session for now, or maybe day-start timestamp.
    // Actually, let's just use 1 for now as the "continuously running" session.
    // The visualization will handle the 100m gaps.
    
    await DatabaseHelper().insertLocation(LocationPoint(
      lat: data.lat,
      lon: data.lon,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sessionId: 1, // Default session
    ));
    
    sendNotification(text);
  }
}

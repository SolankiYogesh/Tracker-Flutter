import 'dart:async';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker/models/location_batch.dart';
import 'package:tracker/models/location_point.dart';
import 'package:tracker/network/repositories/location_repository.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';
import 'package:tracker/utils/app_logger.dart';

class Repo {
  static Repo? _instance;

  final _locationRepository = LocationRepository();
  bool _isSyncing = false;
  Timer? _syncTimer;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final user = await DatabaseHelper().getCurrentUser();
    if (user == null) {
      if (kDebugMode) {
        AppLogger.log('Repo.update: No user found, skipping location update');
      }
      return;
    }

    final text =
        'Location: ${data.lat.toStringAsFixed(5)}, ${data.lon.toStringAsFixed(5)}';
    final locationPoint = LocationPoint(
      latitude: data.lat,
      longitude: data.lon,
      recordedAt: DateTime.now().toUtc(),
      accuracy: data.horizontalAccuracy,
      altitude: data.alt,
      bearing: data.course,
      speed: data.speed,
      userId: user.id,
    );
    
    // 1. Save to Local DB (isSynced = false by default)
    await DatabaseHelper().insertLocation(locationPoint);

    if (kDebugMode) {
      AppLogger.log(
        'New LocationPoint saved locally: ${_locationPointToString(locationPoint)}',
      );
    }

    sendNotification(text);

    // 2. Ensure sync timer is running (Lazy Start)
    if (_syncTimer == null || !_syncTimer!.isActive) {
      _startSyncTimer();
    }
  }

  void _startSyncTimer() {
    if (kDebugMode) {
      AppLogger.log('Starting periodic sync timer (30s)');
    }
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _syncLocations();
    });
    // Trigger immediately on start
    _syncLocations();
  }

  Future<void> _syncLocations() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final dbHelper = DatabaseHelper();
      final unsyncedLocations = await dbHelper.getUnsyncedLocations();

      if (unsyncedLocations.isEmpty) {
        _isSyncing = false;
        return;
      }

      if (kDebugMode) {
        AppLogger.log('Syncing ${unsyncedLocations.length} locations...');
      }

      // Create batch
      final batch = LocationBatch(unsyncedLocations);
      
      // Upload
      final response = await _locationRepository.uploadBatch(batch);

      if (response.success) {
        // Mark as synced
        final ids = unsyncedLocations
            .map((e) => e.recordedAt.millisecondsSinceEpoch)
            .toList();
        await dbHelper.markLocationsAsSynced(ids);
        if (kDebugMode) {
          AppLogger.log('Successfully synced ${ids.length} locations');
        }
      } else {
        AppLogger.error('Failed to sync locations: ${response.errors}');
      }
    } catch (e) {
      AppLogger.error('Error syncing locations', e);
    } finally {
      _isSyncing = false;
    }
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

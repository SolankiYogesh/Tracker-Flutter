import 'dart:async';
import 'package:tracker/constants/app_constants.dart';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:tracker/models/entity_model.dart'; // Ensure Collection is imported
import 'package:latlong2/latlong.dart';
import 'package:tracker/models/location_batch.dart';
import 'package:tracker/models/location_point.dart';
import 'package:tracker/network/repositories/location_repository.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:tracker/network/repositories/entity_repository.dart';

class Repo {
  static Repo? _instance;

  final _locationRepository = LocationRepository();
  final _entityRepository = EntityRepository();
  bool _isSyncing = false;
  Timer? _syncTimer;
  BackgroundLocationUpdateData? lastUpdateRecord;

  final _collectionController = StreamController<Collection>.broadcast();
  Stream<Collection> get onCollection => _collectionController.stream;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    lastUpdateRecord = data;
    final user = await DatabaseHelper().getCurrentUser();
    if (user == null) {
      if (kDebugMode) {
        AppLogger.log('Repo.update: No user found, skipping location update');
      }
      return;
    }

    // Check for nearby entities to collect
    _checkEntityCollection(data, user.id);

    final text =
        'Location: ${data.lat.toStringAsFixed(AppConstants.coordinatePrecision)}, ${data.lon.toStringAsFixed(AppConstants.coordinatePrecision)}';
    final locationPoint = LocationPoint(
      latitude: data.lat,
      longitude: data.lon,
      recordedAt: DateTime.now().toUtc(),
      accuracy: data.horizontalAccuracy < 0 ? 0 : data.horizontalAccuracy,
      altitude: data.alt < 0 ? 0 : data.alt,
      bearing: data.course < 0 ? 0 : data.course,
      speed: data.speed < 0 ? 0 : data.speed,
      userId: user.id,
    );

    // 1. Save to Local DB (isSynced = false by default)
    await DatabaseHelper().insertLocation(locationPoint);

    if (kDebugMode) {
      AppLogger.log(
        'New LocationPoint saved locally: ${_locationPointToString(locationPoint)}',
      );
    }


    // 2. Ensure sync timer is running (Lazy Start)
    if (_syncTimer == null || !_syncTimer!.isActive) {
      _startSyncTimer();
    }
  }

  Future<void> _checkEntityCollection(
    BackgroundLocationUpdateData data,
    String userId,
  ) async {
    try {
      final db = DatabaseHelper();
      final entitiesMap = await db.getUncollectedEntities();
      final entities = entitiesMap.map((e) => Entity.fromMap(e)).toList();

      if (entities.isEmpty) return;

      final currentPos = LatLng(data.lat, data.lon);
      final distanceCalc = const Distance();

      for (var entity in entities) {
        final entityPos = LatLng(entity.latitude, entity.longitude);
        final dist = distanceCalc.as(LengthUnit.Meter, currentPos, entityPos);

        if (dist <= entity.spawnRadius) {
          // Attempt collection
          try {
            if (kDebugMode) {
              AppLogger.log(
                'Attempting to collect entity: ${entity.entityType?.name} at $dist meters',
              );
            }

            final collection = await _entityRepository.collectEntity(
              entity.id,
              data.lat,
              data.lon,
              userId,
            );

            // Notification
            final name =
                collection.entityType?.name ??
                entity.entityType?.name ??
                'Item';
            sendCollectionNotification(
              'Collected $name!',
              'You earned ${collection.xpEarned} XP',
            );

            _collectionController.add(collection);
          } catch (e) {
            AppLogger.error(
              'Failed to collect entity ${entity.id}',
              e.toString(),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error('Error checking entity collection', e);
    }
  }

  void _startSyncTimer() {
    if (kDebugMode) {
      AppLogger.log('Starting periodic sync timer (30s)');
    }
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(AppConstants.locationSyncInterval, (timer) {
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

      //   if (lastUpdateRecord != null) {
      //     final lastSyncItem = unsyncedLocations.last;
      //     final distance = Distance().as(
      //       LengthUnit.Meter,
      //       LatLng(lastUpdateRecord!.lat, lastUpdateRecord!.lon),
      //       LatLng(lastSyncItem.latitude, lastSyncItem.longitude),
      //     );
      // AppLogger.log('Distance: $distance');
      //     if (distance < 7) {
      //       _isSyncing = false;
      //       return;
      //     }
      //   }

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
  lat: ${point.latitude.toStringAsFixed(AppConstants.coordinatePrecision)},
  lon: ${point.longitude.toStringAsFixed(AppConstants.coordinatePrecision)},
  accuracy: ${point.accuracy},
  altitude: ${point.altitude},
  speed: ${point.speed},
  bearing: ${point.bearing},
  recordedAt: ${point.recordedAt.toIso8601String()}
  ''';
}

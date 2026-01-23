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
  factory Repo() => _instance ??= Repo._();

  Repo._();

  static Repo? _instance;

  final _locationRepository = LocationRepository();
  final _entityRepository = EntityRepository();
  bool _isSyncing = false;
  Timer? _syncTimer;
  BackgroundLocationUpdateData? lastUpdateRecord;
  LocationPoint? _lastSavedLocation;

  final _collectionController = StreamController<Collection>.broadcast();
  Stream<Collection> get onCollection => _collectionController.stream;
  
  // Track in-progress collections to prevent double-firing if API is slow
  final Set<String> _collectingEntityIds = {};

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

    // --- FILTER LOGIC START ---
    if (!_shouldSaveLocation(data)) {
      return;
    }
    // --- FILTER LOGIC END ---

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

    // Update last saved location
    _lastSavedLocation = locationPoint;

    if (kDebugMode) {
      AppLogger.log(
        'New LocationPoint saved locally: ${_locationPointToString(locationPoint)}',
      );
    }

    // 2. Ensure sync timer is running (Lazy Start)
    if (_syncTimer == null || !_syncTimer!.isActive) {
      _startSyncTimer();
      // Overwrite the default plugin notification (ID 879848645) with our custom one
      // that includes the "Stop" button. We only need to do this once.
      sendNotification('GeoPulsify is running');
    }
  }

  Future<void> _checkEntityCollection(
    BackgroundLocationUpdateData data,
    String userId,
  ) async {
    try {
      final db = DatabaseHelper();

      // Optimization: Only fetch entities within ~500m
      const double range = 0.005;
      final entitiesMap = await db.getUncollectedEntitiesInBounds(
        minLat: data.lat - range,
        maxLat: data.lat + range,
        minLon: data.lon - range,
        maxLon: data.lon + range,
      );
      final entities = entitiesMap.map((e) => Entity.fromMap(e)).toList();

      if (entities.isEmpty) return;

      final currentPos = LatLng(data.lat, data.lon);
      final distanceCalc = const Distance();

      for (var entity in entities) {
        // Skip if already being collected
        if (_collectingEntityIds.contains(entity.id)) continue;
        
        final entityPos = LatLng(entity.latitude, entity.longitude);
        final dist = distanceCalc.as(LengthUnit.Meter, currentPos, entityPos);

        if (dist <= entity.spawnRadius) {
          _collectingEntityIds.add(entity.id);
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

            // Mark locally (Critical for Single Source of Truth)
            await db.markEntityAsCollected(
              entity.id,
              DateTime.now().millisecondsSinceEpoch,
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
          } catch (e, stack) {
            AppLogger.error(
              'Failed to collect entity ${entity.id}',
              e, // Pass error object directly
              stack,
            );
            // If failed, remove from set so we can retry later
             _collectingEntityIds.remove(entity.id);
          } finally {
             // If successful, we DON'T remove from set immediately to prevent double-trigger
             // in the brief window before DB update reflects in next loop?
             // Actually, we marked it collected in DB above. 
             // So next loop won't pick it up.
             // But if we want to be safe, we can leave it in the set for a bit or just remove it.
             // Prudence: Remove it from set now that DB is updated.
             _collectingEntityIds.remove(entity.id);
          }
        }
      }
    } catch (e, stack) {
      AppLogger.error('Error checking entity collection', e, stack);
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

  bool _shouldSaveLocation(BackgroundLocationUpdateData newData) {
    // 1. Accuracy Check
    // If accuracy is too low (radius is too big), we reject it to avoid "jumping"
    if (newData.horizontalAccuracy > AppConstants.minLocationAccuracy) {
      if (kDebugMode) {
        AppLogger.log(
          'FILTER REJECT: Low accuracy (${newData.horizontalAccuracy.toStringAsFixed(1)}m > ${AppConstants.minLocationAccuracy}m)',
        );
      }
      return false;
    }

    // If we haven't saved any location yet, always save the first one (provided it's accurate enough)
    if (_lastSavedLocation == null) {
      if (kDebugMode) AppLogger.log('FILTER ACCEPT: First location point');
      return true;
    }

    // Calculate distance from last saved point
    const distanceCalc = Distance();
    final dist = distanceCalc.as(
      LengthUnit.Meter,
      LatLng(_lastSavedLocation!.latitude, _lastSavedLocation!.longitude),
      LatLng(newData.lat, newData.lon),
    );

    // Calculate time delta
    final timeDelta = DateTime.now().difference(_lastSavedLocation!.recordedAt).inSeconds;
    final speed = newData.speed < 0 ? 0 : newData.speed;

    // 2. Stationary Check
    // If speed is very low, we assume user is stationary.
    // In this state, we require a larger distance change to filter out "stationary jitter".
    if (speed < AppConstants.minStationarySpeed) {
      if (dist < AppConstants.minStationaryDistance) {
        if (kDebugMode) {
          AppLogger.log(
            'FILTER REJECT: Stationary jitter (Speed: ${speed.toStringAsFixed(1)}m/s, Dist: ${dist.toStringAsFixed(1)}m)',
          );
        }
        return false;
      } else {
        if (kDebugMode) {
          AppLogger.log(
            'FILTER ACCEPT: Stationary but moved significantly (Dist: ${dist.toStringAsFixed(1)}m)',
          );
        }
        return true;
      }
    }

    // 3. Moving Check
    // A) Significant Distance: If moved enough distance, accept regardless of time.
    if (dist > AppConstants.minMovingDistance) {
      if (kDebugMode) {
        AppLogger.log(
          'FILTER ACCEPT: Significant distance (Dist: ${dist.toStringAsFixed(1)}m)',
        );
      }
      return true;
    }

    // B) Time & Distance (Slow steady movement):
    // If moved a smaller distance but enough time has passed, accept it.
    if (dist > AppConstants.minSignificantDistance &&
        timeDelta > AppConstants.minSignificantTime) {
      if (kDebugMode) {
        AppLogger.log(
          'FILTER ACCEPT: Time & Distance (Dist: ${dist.toStringAsFixed(1)}m, Time: ${timeDelta}s)',
        );
      }
      return true;
    }

    // Otherwise, reject as insignificant
    if (kDebugMode) {
      AppLogger.log(
        'FILTER REJECT: Insignificant (Dist: ${dist.toStringAsFixed(1)}m, Time: ${timeDelta}s)',
      );
    }
    return false;
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

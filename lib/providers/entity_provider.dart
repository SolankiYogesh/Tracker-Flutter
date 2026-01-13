import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/network/repositories/entity_repository.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';
import 'package:latlong2/latlong.dart';

class EntityProvider extends ChangeNotifier {
  final EntityRepository _repo = EntityRepository();
  final DatabaseHelper _db = DatabaseHelper();
  
  List<Entity> _nearbyEntities = [];
  UserExperience? _userExperience;
  UserCollectionsResponse? _userCollections;
  bool _isLoading = false;
  DateTime _lastCollectionCheck = DateTime.now(); // Track last check time
  
  List<Entity> get nearbyEntities => _nearbyEntities;
  UserExperience? get userExperience => _userExperience;
  UserCollectionsResponse? get userCollections => _userCollections;
  bool get isLoading => _isLoading;
  
  Timer? _fetchTimer;
  StreamSubscription? _collectionSubscription;

  // Stream controller to notify UI of collection events (for animation)
  final _collectionCompleteController = StreamController<Collection>.broadcast();
  Stream<Collection> get onCollectionComplete => _collectionCompleteController.stream;

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _collectionSubscription?.cancel(); // If we had one from repo
    _collectionCompleteController.close();
    super.dispose();
  }

  /// Initialize: Load local entities and start periodic fetch
  Future<void> init(String userId) async {
    await _loadLocalEntities();
    await fetchUserExperience(userId);
    startPeriodicFetch(userId);
  }
  
  Future<void> _loadLocalEntities() async {
    final maps = await _db.getUncollectedEntities();
    _nearbyEntities = maps.map((e) => Entity.fromMap(e)).toList();
    notifyListeners();
  }

  void startPeriodicFetch(String userId) {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(const Duration(seconds: 50), (timer) {
      fetchNearbyEntities(userId);
    });
    // Trigger immediately
    fetchNearbyEntities(userId);
  }

  Future<void> fetchNearbyEntities(String userId, {double? lat, double? lng}) async {
    // If lat/lng not provided, try to get last known? 
    // For now, we rely on the MapScreen to pass current location or we fetch from DB last location
    // But since this is periodic, we need a way to get current location.
    // Actually, simpler implementation: MapScreen calls fetchNearbyEntities periodically with actual location,
    // OR we use the Repository/DB last location if available. 
    // Let's rely on MapScreen calling this, OR use the last known location from DatabaseHelper location table.
    
    // Changing strategy: Provider exposes a method, MapScreen calls it inside its existing timer?
    // The plan said "provider.startPeriodicFetch". 
    // Let's get the last location from DB to perform the fetch if not provided.
    
    if (lat == null || lng == null) {
      final locs = await _db.getLocations(userId: userId);
      if (locs.isNotEmpty) {
        lat = locs.last.latitude;
        lng = locs.last.longitude;
      } else {
        return; // No location known yet
      }
    }

    try {
      debugPrint('EntityProvider: Fetching nearby entities... lat=$lat, lng=$lng, radius=1000');
      final entities = await _repo.fetchAndSaveNearbyEntities(lat!, lng!, userId: userId);
      debugPrint('EntityProvider: Fetched and saved ${entities.length} entities from API.');
      await _loadLocalEntities(); // Refresh state from DB
    } catch (e) {
      debugPrint('Error fetching entities: $e');
    }
  }

  Future<void> fetchUserExperience(String userId) async {
    try {
      _userExperience = await _repo.getUserExperience(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching XP: $e');
    }
  }

  Future<void> fetchUserCollections(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userCollections = await _repo.getUserCollections(userId);
    } catch (e) {
      debugPrint('Error fetching collections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Method to manually notify collection happened (e.g. from foreground logic if we had it, 
  // currently Repo handles logic. We might need a way to listen to Repo events? 
  // DatabaseHelper doesn't have streams.
  // We can poll DB or use a shared StreamController if we want UI update immediately.
  // For now, _loadLocalEntities call in fetchNearbyEntities updates the list. 
  // If BG collection happens, the list in Provider won't update until next 50s fetch OR if we listen to something.
  // IMPROVEMENT: Poll local DB more frequently? Or just rely on MapScreen refresh?
  // MapScreen has a 5s timer calling `_refreshLocations`. We can hook into that to refresh entities from DB too.
  
  Future<void> refreshEntitiesFromDb() async {
    await _loadLocalEntities();
  }

  /// Check if user is close enough to any entity to collect it (Foreground logic)
  Future<void> checkProximityAndCollect(double userLat, double userLng, String userId) async {
    const Distance distance = Distance();
    final List<Entity> collected = [];

    for (var entity in _nearbyEntities) {
      if (entity.isCollected) continue;

      final dist = distance.as(LengthUnit.Meter, 
          LatLng(userLat, userLng), 
          LatLng(entity.latitude, entity.longitude));
      
      if (dist <= entity.spawnRadius) {
        // Attempt collection
        try {
            final collectedEntity = await _repo.collectEntity(entity.id, userLat, userLng, userId);
            // If execution continues here, it was successful (otherwise catch block)
            
            // Mark locally
            await _db.markEntityAsCollected(entity.id);
            
            // Construct collection object for UI
            // The repo now returns the actual Collection object from API, use it!
            final collection = collectedEntity;
            
            _collectionCompleteController.add(collection);
            collected.add(entity);
            
            // Send notification
            sendCollectionNotification(
                "Entity Collected!", 
                "You found a ${entity.entityType?.name ?? 'Item'}! +${entity.xpValue} XP"
            );
        } catch (e) {
            debugPrint("Error collecting entity in foreground: $e");
        }
      }
    }
    
    if (collected.isNotEmpty) {
        await _loadLocalEntities(); // Refresh list to remove collected items
        await fetchUserExperience(userId); // Refresh stats
    }
  }

  /// Poll for collections that happened recently (e.g. by background service)
  /// This ensures UI animation plays even if background isolate did the work.
  Future<void> checkForNewCollections(String userId) async {
    try {
        // Get collections after last check
        final collections = await _repo.getUserCollections(userId, limit: 1); // Get latest
        if (collections.collections.isNotEmpty) {
            final latest = collections.collections.first;
            
            // If this is new to us (compare with small buffer for clock diffs)
            if (latest.collectedAt.isAfter(_lastCollectionCheck)) {
                 _lastCollectionCheck = DateTime.now();
                 
                 // Trigger UI
                 _collectionCompleteController.add(latest);
                 
                 // Also ensure local notification if not already shown?
                 // Ideally background service shows it. But user said no notification.
                 // Let's show it here to be safe (might duplicate if BG works, but better than none)
                 sendCollectionNotification(
                    "Entity Collected!", 
                    "You found a ${latest.entityType?.name ?? 'Item'}! +${latest.xpEarned} XP"
                );
                
                await _loadLocalEntities();
                await fetchUserExperience(userId);
            }
        }
    } catch (e) {
        debugPrint("Error checking new collections: $e");
    }
  }
}

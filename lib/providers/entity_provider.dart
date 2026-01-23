import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/network/repositories/entity_repository.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/services/notification.dart';
import 'package:tracker/constants/app_constants.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracker/utils/app_logger.dart';
import 'package:tracker/network/api_queries.dart';
import 'package:tracker/main.dart' show queryCache;

import 'package:tracker/services/repo.dart'; // Add this import

class EntityProvider extends ChangeNotifier {
  final EntityRepository _entityRepository = EntityRepository();
  final DatabaseHelper _db = DatabaseHelper();
  final Repo _serviceRepo = Repo(); // Use the centralized service

  List<Entity> _nearbyEntities = [];
  bool _isLoading = false;
  DateTime _lastCollectionCheck = DateTime.now();
  
  List<Entity> get nearbyEntities => _nearbyEntities;

  UserExperience? get userExperience => queryCache
      .getQueryData<UserExperience, Exception>([ApiQueries.userExperienceKey]);
  UserCollectionsResponse? get userCollections =>
      queryCache.getQueryData<UserCollectionsResponse, Exception>([
        ApiQueries.userCollectionsKey,
      ]);

  bool get isLoading => _isLoading;

  Timer? _fetchTimer;
  StreamSubscription? _repoSubscription;
  LatLng? _lastFetchLocation;

  // Stream controller to notify UI of collection events (for animation)
  final _collectionCompleteController =
      StreamController<Collection>.broadcast();
  Stream<Collection> get onCollectionComplete =>
      _collectionCompleteController.stream;

  @override
  void dispose() {
    _fetchTimer?.cancel();
    _repoSubscription?.cancel();
    _collectionCompleteController.close();
    super.dispose();
  }

  /// Initialize: Load local entities and start periodic fetch
  Future<void> init(String userId) async {
    await _loadLocalEntities();
    await fetchUserExperience(userId);
    startPeriodicFetch(userId);
    
    // Observer Pattern: Listen to Repo for any collections (BG or via other means)
    _repoSubscription?.cancel();
    _repoSubscription = _serviceRepo.onCollection.listen((collection) {
      // 1. Update local list state
      _nearbyEntities.removeWhere((e) => e.id == collection.entityId);
      notifyListeners();
      
      // 2. Forward to UI for animation
      _collectionCompleteController.add(collection);
      
      // 3. Refresh XP
      fetchUserExperience(userId);
      // Collections list query invalidation
      queryCache.invalidateQueries([ApiQueries.userCollectionsKey, userId]);
    });
  }

  Future<void> _loadLocalEntities() async {
    final maps = await _db.getUncollectedEntities();
    _nearbyEntities = maps.map((e) => Entity.fromMap(e)).toList();
    notifyListeners();
  }

  void startPeriodicFetch(String userId) {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(AppConstants.entityFetchInterval, (timer) {
      fetchNearbyEntities(userId);
    });
    // Trigger immediately
    fetchNearbyEntities(userId);
  }

  Future<void> fetchNearbyEntities(
    String userId, {
    double? lat,
    double? lng,
  }) async {
    if (lat == null || lng == null) {
      final locs = await _db.getLocations(userId: userId);
      if (locs.isNotEmpty) {
        lat = locs.last.latitude;
        lng = locs.last.longitude;
      } else {
        return; // No location known yet
      }
    }
    
    // Smart Invalidation: Check if moved enough since last fetch
    if (_lastFetchLocation != null) {
      const distance = Distance();
      final dist = distance.as(
        LengthUnit.Meter, 
        LatLng(lat, lng), 
        _lastFetchLocation!
      );
      
      if (dist < AppConstants.entityFetchMinDistance) { // 100 meters threshold
        AppLogger.log('EntityProvider: Skipping fetch - User moved only ${dist.toStringAsFixed(1)}m');
        return;
      }
    }

    try {
      AppLogger.log(
        'EntityProvider: Fetching nearby entities... lat=$lat, lng=$lng, radius=1000',
      );
      final entities = await _entityRepository.fetchAndSaveNearbyEntities(
        lat,
        lng,
        userId: userId,
      );
      
      _lastFetchLocation = LatLng(lat, lng);
      
      AppLogger.log(
        'EntityProvider: Fetched and saved ${entities.length} entities from API.',
      );
      await _loadLocalEntities(); // Refresh state from DB
    } catch (e) {
      AppLogger.log('Error fetching entities: $e');
    }
  }

  Future<void> fetchUserExperience(String userId) async {
    try {
      // Invalidate will trigger a refetch if any listener is active,
      // or we can just use the QueryBuilder to handle initial fetch.
      // For background updates, invalidate is standard.
      queryCache.invalidateQueries([ApiQueries.userExperienceKey, userId]);
      notifyListeners();
    } catch (e) {
      AppLogger.log('Error fetching XP: $e');
    }
  }

  Future<void> fetchUserCollections(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      queryCache.invalidateQueries([ApiQueries.userCollectionsKey, userId]);
    } catch (e) {
      AppLogger.log('Error fetching collections: $e');
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

  // Tracking for DB polling
  int _lastCollectionCheckTimestamp = DateTime.now().millisecondsSinceEpoch;
  final Set<String> _animatedCollectionIds = {};

  Future<void> refreshEntitiesFromDb() async {
    // 1. Check for recent collections (bridging the background isolate gap)
    await _checkRecentCollections();
    // 2. Refresh local list
    await _loadLocalEntities();
  }
  
  Future<void> _checkRecentCollections() async {
    // Look for collections since last check
    final recent = await _db.getRecentCollectedEntities(_lastCollectionCheckTimestamp);
    
    if (recent.isNotEmpty) {
      // Update check time to now
      _lastCollectionCheckTimestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (var row in recent) {
        final id = row['id'] as String;
        // Skip if already animated (deduplication)
        if (_animatedCollectionIds.contains(id)) continue;
        
        _animatedCollectionIds.add(id);
        
        // Construct a partial Collection object for animation
        // Note: we might miss exact 'collectedAt' from API if we use 'now', 
        // but row['collected_at'] is from local DB update time which is close enough.
        final collectedAt = DateTime.fromMillisecondsSinceEpoch(row['collected_at'] as int);
        
        // Reconstruct EntityType info from row
        final entityType = EntityType(
          id: row['entity_type_id'] as String, // Partial
          name: (row['type_name'] as String?) ?? 'Item',
          iconUrl: row['type_icon_url'] as String?,
          rarity: (row['type_rarity'] as String?) ?? 'common',
          baseXpValue: row['xp_value'] as int,
          isActive: true,
        );

        final collection = Collection(
          id: id, // Using Entity ID as Collection ID proxy for animation
          entityId: id,
          xpEarned: row['xp_value'] as int, // Using local value
          collectedAt: collectedAt,
          entityType: entityType,
        );
        
        // Trigger Animation
        _collectionCompleteController.add(collection);
        
        // Also refresh XP
        // fetchUserExperience(userId); // We don't have userId handy here easily without passing it...
        // But map_screen calls refreshEntitiesFromDb, maybe we can just let eventual sync handle it?
        // Or better, let the UI refresh XP when it receives the collection event.
        // Actually MapScreen receives it.
      }
    }
  }

  // Removed checkProximityAndCollect to avoid race conditions. 
  // Logic is now centralized in Repo._checkEntityCollection

  // checkForNewCollections removed. We now rely on _repoSubscription (Observer Pattern)
  // to detect collections from background service.

  // Leaderboard is now handled by fquery in the UI, but if needed here:
  LeaderboardResponse? get leaderboard =>
      queryCache.getQueryData<LeaderboardResponse, Exception>([
        ApiQueries.leaderboardKey,
      ]);

  Future<void> fetchLeaderboard() async {
    try {
      queryCache.invalidateQueries([ApiQueries.leaderboardKey]);
      notifyListeners();
    } catch (e) {
      AppLogger.log('Error fetching leaderboard: $e');
    }
  }
}

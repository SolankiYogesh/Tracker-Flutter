import 'package:dio/dio.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/network/api_exceptions.dart';
import 'package:tracker/network/dio_client.dart';
import 'package:tracker/services/database_helper.dart';

class EntityRepository {
  final Dio _dio = DioClient().dio;
  final DatabaseHelper _db = DatabaseHelper();

  /// Fetches nearby entities from the backend
  Future<List<Entity>> getNearbyEntities(
    double lat,
    double lng, {
    int radius = 1000,
    String? userId,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/entities/nearby',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'radius': radius,
        },
        options: userId != null
            ? Options(headers: {'X-User-ID': userId})
            : null,
      );
      
      final list = ((res.data as Map<String, dynamic>)['entities'] as List<dynamic>)
          .map((e) => Entity.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Fetches nearby entities and saves them to SQLite for background access
  Future<List<Entity>> fetchAndSaveNearbyEntities(
    double lat,
    double lng, {
    int radius = 1000,
    String? userId,
  }) async {
    final entities = await getNearbyEntities(lat, lng, radius: radius, userId: userId);
    
    // We clear old entities to avoid clutter, or maybe we just upsert?
     // Strategy: Upsert is better, but for now we might want to just replace nearby ones.
     // Simpler approach for now: Save/Replace. The DatabaseHelper.saveEntities uses ConflictAlgorithm.replace.
     // However, we might want to prune old far away entities eventually. 
     // For this sprint, just saving the new batch is enough. 
    await _db.saveEntities(entities);
    
    return entities;
  }

  /// Collects an entity
  Future<Collection> collectEntity(
    String entityId,
    double lat,
    double lng,
    String userId,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/entities/collect',
        data: {
          'entity_id': entityId,
          'user_latitude': lat,
          'user_longitude': lng,
        },
        options: Options(headers: {'X-User-ID': userId}),
      );
      
      // Mark as collected locally immediately
      await _db.markEntityAsCollected(
        entityId,
        DateTime.now().millisecondsSinceEpoch,
      );
      
      return Collection.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Get user experience
  Future<UserExperience> getUserExperience(String userId) async {
     try {
      final res = await _dio.get<Map<String, dynamic>>('/api/v1/users/$userId/experience');
      return UserExperience.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
  
  /// Get user collections
  Future<UserCollectionsResponse> getUserCollections(String userId, {int limit = 50, int offset = 0}) async {
     try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/users/$userId/collections',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return UserCollectionsResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
  /// Get leaderboard
  Future<LeaderboardResponse> fetchLeaderboard({int limit = 50, int offset = 0}) async {
     try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/leaderboard',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return LeaderboardResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

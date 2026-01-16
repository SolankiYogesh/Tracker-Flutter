import 'package:tracker/models/entity_model.dart';
import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/network/repositories/auth_repository.dart';
import 'package:tracker/network/repositories/entity_repository.dart';
import 'package:tracker/network/repositories/location_repository.dart';
import 'package:tracker/network/repositories/user_repository.dart';

class ApiQueries {
  static final authRepo = AuthRepository();
  static final userRepo = UserRepository();
  static final entityRepo = EntityRepository();
  static final locationRepo = LocationRepository();

  // Query Keys
  static const String userExperienceKey = 'user_experience';
  static const String userCollectionsKey = 'user_collections';
  static const String leaderboardKey = 'leaderboard';
  static const String nearbyUsersKey = 'nearby_users';
  static const String nearbyEntitiesKey = 'nearby_entities';
  static const String userKey = 'user';

  // Query Functions
  static Future<UserExperience> fetchUserExperience(String userId) =>
      entityRepo.getUserExperience(userId);

  static Future<UserCollectionsResponse> fetchUserCollections(String userId) =>
      entityRepo.getUserCollections(userId);

  static Future<LeaderboardResponse> fetchLeaderboard() =>
      entityRepo.fetchLeaderboard();

  static Future<List<NearbyUser>> fetchNearbyUsers(String userId) =>
      locationRepo.getNearbyUsers(userId);

  static Future<dynamic> fetchUser(String userId) => userRepo.getUser(userId);

  // You can also define mutations here if needed, but fquery focus is on queries.
}

import 'package:latlong2/latlong.dart';

class EntityType {

  EntityType({
    this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.category,
    required this.baseXpValue,
    required this.rarity,
    required this.isActive,
  });

  factory EntityType.fromJson(Map<String, dynamic> json) {
    return EntityType(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      category: json['category'] as String?,
      baseXpValue: json['base_xp_value'] as int,
      rarity: json['rarity'] as String,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
  final String? id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? category;
  final int baseXpValue;
  final String rarity;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'base_xp_value': baseXpValue,
      'rarity': rarity,
      'is_active': isActive,
    };
  }
}

class Entity {

  Entity({
    required this.id,
    required this.entityTypeId,
    required this.latitude,
    required this.longitude,
    required this.spawnRadius,
    required this.xpValue,
    this.distanceMeters,
    this.entityType,
    this.isCollected = false,
  });

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'] as String,
      entityTypeId: json['entity_type_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      spawnRadius: (json['spawn_radius'] as num).toDouble(),
      xpValue: json['xp_value'] as int,
      distanceMeters: json['distance_meters'] != null
          ? (json['distance_meters'] as num).toDouble()
          : null,
      entityType: json['entity_type'] != null
          ? EntityType.fromJson(json['entity_type'] as Map<String, dynamic>)
          : null,
      isCollected: (json['is_collected'] as bool?) ?? false,
    );
  }
  
  // From SQLite
  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      id: map['id'] as String,
      entityTypeId: map['entity_type_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      spawnRadius: (map['spawn_radius'] as num).toDouble(),
      xpValue: map['xp_value'] as int,
      isCollected: map['is_collected'] == 1,
      entityType: EntityType(
        id: map['entity_type_id'] as String, // Reconstruct partial type
        name: (map['type_name'] as String?) ?? 'Unknown',
        iconUrl: map['type_icon_url'] as String?,
        rarity: (map['type_rarity'] as String?) ?? 'common',
        baseXpValue: map['xp_value'] as int, // Fallback
        isActive: true,
      ),
    );
  }
  final String id;
  final String entityTypeId;
  final double latitude;
  final double longitude;
  final double spawnRadius;
  final int xpValue;
  final double? distanceMeters;
  final EntityType? entityType;
  final bool isCollected;

  LatLng get position => LatLng(latitude, longitude);
  
  // For SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity_type_id': entityTypeId,
      'latitude': latitude,
      'longitude': longitude,
      'spawn_radius': spawnRadius,
      'xp_value': xpValue,
      'is_collected': isCollected ? 1 : 0,
      'type_name': entityType?.name,
      'type_icon_url': entityType?.iconUrl,
      'type_rarity': entityType?.rarity,
    };
  }
}

class Collection {

  Collection({
    required this.id,
    required this.entityId,
    required this.xpEarned,
    required this.collectedAt,
    this.entityType,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      entityId: json['entity_id'] as String,
      xpEarned: json['xp_earned'] as int,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      entityType: json['entity_type'] != null
          ? EntityType.fromJson(json['entity_type'] as Map<String, dynamic>)
          : null,
    );
  }
  final String id;
  final String entityId;
  final int xpEarned;
  final DateTime collectedAt;
  final EntityType? entityType;
}

class UserExperience {

  UserExperience({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.entitiesCollected,
    this.lastCollectionAt,
  });

  factory UserExperience.fromJson(Map<String, dynamic> json) {
    return UserExperience(
      userId: json['user_id'] as String,
      totalXp: json['total_xp'] as int,
      currentLevel: json['current_level'] as int,
      entitiesCollected: json['entities_collected'] as int,
      lastCollectionAt: json['last_collection_at'] != null
          ? DateTime.parse(json['last_collection_at'] as String)
          : null,
    );
  }
  final String userId;
  final int totalXp;
  final int currentLevel;
  final int entitiesCollected;
  final DateTime? lastCollectionAt;
}

class UserCollectionsResponse {

  UserCollectionsResponse({
    required this.collections,
    required this.totalCount,
    required this.totalXp,
  });

  factory UserCollectionsResponse.fromJson(Map<String, dynamic> json) {
    return UserCollectionsResponse(
      collections: (json['collections'] as List<dynamic>)
          .map((e) => Collection.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      totalXp: json['total_xp'] as int,
    );
  }
  final List<Collection> collections;
  final int totalCount;
  final int totalXp;
}

class LeaderboardEntry {

  LeaderboardEntry({
    required this.userId,
    this.name,
    this.username,
    this.picture,
    required this.totalXp,
    required this.currentLevel,
    required this.entitiesCollected,
    this.lastCollectionAt,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      picture: json['picture'] as String?,
      totalXp: json['total_xp'] as int,
      currentLevel: json['current_level'] as int,
      entitiesCollected: json['entities_collected'] as int,
      lastCollectionAt: json['last_collection_at'] != null
          ? DateTime.parse(json['last_collection_at'] as String)
          : null,
      rank: json['rank'] as int,
    );
  }
  final String userId;
  final String? name;
  final String? username;
  final String? picture;
  final int totalXp;
  final int currentLevel;
  final int entitiesCollected;
  final DateTime? lastCollectionAt;
  final int rank;
}

class LeaderboardResponse {

  LeaderboardResponse({
    required this.leaderboard,
    required this.totalCount,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      leaderboard: (json['leaderboard'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
    );
  }
  final List<LeaderboardEntry> leaderboard;
  final int totalCount;
}

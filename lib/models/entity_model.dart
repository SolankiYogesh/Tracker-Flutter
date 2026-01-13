import 'package:latlong2/latlong.dart';

class EntityType {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final String? category;
  final int baseXpValue;
  final String rarity;
  final bool isActive;

  EntityType({
    required this.id,
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      category: json['category'],
      baseXpValue: json['base_xp_value'],
      rarity: json['rarity'],
      isActive: json['is_active'] ?? true,
    );
  }

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
  final String id;
  final String entityTypeId;
  final double latitude;
  final double longitude;
  final double spawnRadius;
  final int xpValue;
  final double? distanceMeters;
  final EntityType? entityType;
  final bool isCollected;

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

  LatLng get position => LatLng(latitude, longitude);

  factory Entity.fromJson(Map<String, dynamic> json) {
    return Entity(
      id: json['id'],
      entityTypeId: json['entity_type_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      spawnRadius: (json['spawn_radius'] as num).toDouble(),
      xpValue: json['xp_value'],
      distanceMeters: json['distance_meters'] != null
          ? (json['distance_meters'] as num).toDouble()
          : null,
      entityType: json['entity_type'] != null
          ? EntityType.fromJson(json['entity_type'])
          : null,
      isCollected: json['is_collected'] ?? false,
    );
  }
  
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
  
  // From SQLite
  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      id: map['id'],
      entityTypeId: map['entity_type_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      spawnRadius: map['spawn_radius'],
      xpValue: map['xp_value'],
      isCollected: map['is_collected'] == 1,
      entityType: EntityType(
        id: map['entity_type_id'], // Reconstruct partial type
        name: map['type_name'] ?? 'Unknown',
        iconUrl: map['type_icon_url'],
        rarity: map['type_rarity'] ?? 'common',
        baseXpValue: map['xp_value'], // Fallback
        isActive: true,
      )
    );
  }
}

class Collection {
  final String id;
  final String entityId;
  final int xpEarned;
  final DateTime collectedAt;
  final EntityType? entityType;

  Collection({
    required this.id,
    required this.entityId,
    required this.xpEarned,
    required this.collectedAt,
    this.entityType,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      entityId: json['entity_id'],
      xpEarned: json['xp_earned'],
      collectedAt: DateTime.parse(json['collected_at']),
      entityType: json['entity_type'] != null
          ? EntityType.fromJson(json['entity_type'])
          : null,
    );
  }
}

class UserExperience {
  final String userId;
  final int totalXp;
  final int currentLevel;
  final int entitiesCollected;
  final DateTime? lastCollectionAt;

  UserExperience({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.entitiesCollected,
    this.lastCollectionAt,
  });

  factory UserExperience.fromJson(Map<String, dynamic> json) {
    return UserExperience(
      userId: json['user_id'],
      totalXp: json['total_xp'],
      currentLevel: json['current_level'],
      entitiesCollected: json['entities_collected'],
      lastCollectionAt: json['last_collection_at'] != null
          ? DateTime.parse(json['last_collection_at'])
          : null,
    );
  }
}

class UserCollectionsResponse {
  final List<Collection> collections;
  final int totalCount;
  final int totalXp;

  UserCollectionsResponse({
    required this.collections,
    required this.totalCount,
    required this.totalXp,
  });

  factory UserCollectionsResponse.fromJson(Map<String, dynamic> json) {
    return UserCollectionsResponse(
      collections: (json['collections'] as List)
          .map((e) => Collection.fromJson(e))
          .toList(),
      totalCount: json['total_count'],
      totalXp: json['total_xp'],
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String? name;
  final String? picture;
  final int totalXp;
  final int currentLevel;
  final int entitiesCollected;
  final DateTime? lastCollectionAt;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    this.name,
    this.picture,
    required this.totalXp,
    required this.currentLevel,
    required this.entitiesCollected,
    this.lastCollectionAt,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'],
      name: json['name'],
      picture: json['picture'],
      totalXp: json['total_xp'],
      currentLevel: json['current_level'],
      entitiesCollected: json['entities_collected'],
      lastCollectionAt: json['last_collection_at'] != null
          ? DateTime.parse(json['last_collection_at'])
          : null,
      rank: json['rank'],
    );
  }
}

class LeaderboardResponse {
  final List<LeaderboardEntry> leaderboard;
  final int totalCount;

  LeaderboardResponse({
    required this.leaderboard,
    required this.totalCount,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      leaderboard: (json['leaderboard'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      totalCount: json['total_count'],
    );
  }
}

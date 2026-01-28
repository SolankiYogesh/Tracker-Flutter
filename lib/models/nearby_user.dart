class NearbyUser {

  const NearbyUser({
    required this.userId,
    this.name,
    this.username,
    this.picture,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.distanceMeters,
    required this.lastUpdated,
    this.socialMediaLinks,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      username: json['username'] as String?,
      picture: json['picture'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      socialMediaLinks: (json['social_media_links'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
  final String userId;
  final String? name;
  final String? username;
  final String? picture;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double distanceMeters;
  final DateTime lastUpdated;
  final Map<String, String>? socialMediaLinks;
}

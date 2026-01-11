class NearbyUser {
  final String userId;
  final String? name;
  final String? picture;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double distanceMeters;
  final DateTime lastUpdated;

  const NearbyUser({
    required this.userId,
    this.name,
    this.picture,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.distanceMeters,
    required this.lastUpdated,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      userId: json['user_id'],
      name: json['name'],
      picture: json['picture'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      distanceMeters: json['distance_meters'].toDouble(),
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }
}

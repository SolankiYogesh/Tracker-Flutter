class LocationPoint {

  LocationPoint({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
    this.isSynced = false,
  });

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      userId: map['user_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at'] as int),
      accuracy: (map['accuracy'] as num?)?.toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      bearing: (map['bearing'] as num?)?.toDouble(),
      isSynced: map['is_synced'] == 1,
    );
  }
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final bool isSynced;

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
    if (accuracy != null) 'accuracy': accuracy,
    if (altitude != null) 'altitude': altitude,
    if (speed != null) 'speed': speed,
    if (bearing != null) 'bearing': bearing,
  };

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'bearing': bearing,
      'is_synced': isSynced ? 1 : 0,
    };
  }
}

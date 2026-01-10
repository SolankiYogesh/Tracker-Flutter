class LocationPoint {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime recordedAt;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? bearing;

  LocationPoint({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': recordedAt.toIso8601String(),
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
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      userId: map['user_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recorded_at']),
      accuracy: map['accuracy'],
      altitude: map['altitude'],
      speed: map['speed'],
      bearing: map['bearing'],
    );
  }
}

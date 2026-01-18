class TravelActivity {

  TravelActivity({
    this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.userId,
  });

  factory TravelActivity.fromMap(Map<String, dynamic> map) {
    return TravelActivity(
      id: map['id'] as int?,
      type: map['type'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      distance: (map['distance'] as num).toDouble(),
      userId: map['user_id'] as String,
    );
  }
  final int? id;
  final String type; // 'still', 'walking', 'vehicle'
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // in meters
  final String userId;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'distance': distance,
      'user_id': userId,
    };
  }

  double get durationMinutes => endTime.difference(startTime).inSeconds / 60.0;
}

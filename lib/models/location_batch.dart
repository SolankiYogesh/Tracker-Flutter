import 'location_point.dart';

class LocationBatch {
  final List<LocationPoint> locations;

  LocationBatch(this.locations);

  Map<String, dynamic> toJson() => {
    'locations': locations.map((e) => e.toJson()).toList(),
  };
}

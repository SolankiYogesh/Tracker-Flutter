import 'location_point.dart';

class LocationBatch {

  LocationBatch(this.locations);
  final List<LocationPoint> locations;

  Map<String, dynamic> toJson() => {
    'locations': locations.map((e) => e.toJson()).toList(),
  };
}

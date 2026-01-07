import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:tracker/services/notification.dart';

class Repo {
  static Repo? _instance;

  Repo._();

  factory Repo() => _instance ??= Repo._();

  Future<void> update(BackgroundLocationUpdateData data) async {
    final text = 'Lat: ${data.lat} Lon: ${data.lon}';
    print(text);
    sendNotification(text);
  }
}

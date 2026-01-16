import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class PermissionUtils {
  static Future<bool> areAllPermissionsGranted() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      final loc = await Permission.location.status;
      if (!(loc.isGranted || loc.isLimited)) return false;

      final bgLoc = await Permission.locationAlways.status;
      if (!(bgLoc.isGranted || bgLoc.isLimited)) return false;

      if (Platform.isAndroid) {
        final activity = await Permission.activityRecognition.status;
        if (!(activity.isGranted || activity.isLimited)) return false;
      }

      final notif = await Permission.notification.status;
      if (!(notif.isGranted || notif.isLimited)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}

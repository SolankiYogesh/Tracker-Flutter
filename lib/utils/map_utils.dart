import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tracker/constants/app_constants.dart';
import 'package:tracker/utils/app_logger.dart';

class MapUtils {
  static List<LatLng> makeSmooth(List<LatLng> points) {
    if (points.length < 3) return points;
    List<LatLng> spline = [];
    // Catmull-Rom Spline
    // We add duplicate first and last points for control
    List<LatLng> padded = [points.first, ...points, points.last];

    for (int i = 0; i < padded.length - 3; i++) {
      LatLng p0 = padded[i];
      LatLng p1 = padded[i + 1];
      LatLng p2 = padded[i + 2];
      LatLng p3 = padded[i + 3];

      // 10 points per segment for smoothness
      for (int t = 0; t <= AppConstants.splineSegmentSubdivisions; t++) {
        double tNorm = t / AppConstants.splineSegmentSubdivisions.toDouble();
        double t2 = tNorm * tNorm;
        double t3 = t2 * tNorm;

        double f0 = -0.5 * t3 + t2 - 0.5 * tNorm;
        double f1 = 1.5 * t3 - 2.5 * t2 + 1.0;
        double f2 = -1.5 * t3 + 2.0 * t2 + 0.5 * tNorm;
        double f3 = 0.5 * t3 - 0.5 * t2;

        double lat =
            p0.latitude * f0 +
            p1.latitude * f1 +
            p2.latitude * f2 +
            p3.latitude * f3;
        double lon =
            p0.longitude * f0 +
            p1.longitude * f1 +
            p2.longitude * f2 +
            p3.longitude * f3;
        spline.add(LatLng(lat, lon));
      }
    }
    return spline;
  }

  static Future<void> openDirections(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse('google.navigation:q=$lat,$lng');
    final Uri appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lng',
    );
    final Uri fallbackUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      AppLogger.log('Error launching maps: $e');
      rethrow;
    }
  }
}

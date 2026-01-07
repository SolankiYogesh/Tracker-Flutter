import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController controller = MapController(
    useExternalTracking: true,
    initMapWithUserPosition: UserTrackingOption(
      enableTracking: false,
      unFollowUser: false,
    ),
  );

  Future<void> resetToCurrentLocation() async {
    await controller.disabledTracking();
    await controller.currentLocation();
  }

  @override
  void initState() {
    resetToCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: OSMFlutter(
        controller: controller,
        osmOption: OSMOption(
          zoomOption: const ZoomOption(
            initZoom: 3,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(Icons.double_arrow, size: 48),
            ),
          ),
          roadConfiguration: const RoadOption(roadColor: Colors.red),
        ),
      ),
    );
  }
}

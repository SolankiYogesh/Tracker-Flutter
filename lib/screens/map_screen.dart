import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tracker/services/database_helper.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<List<LatLng>> _polylines = [];
  LatLng? _currentLocation;
  Timer? _timer;
  bool _hasInitiallyCentered = false;

  @override
  void initState() {
    super.initState();
    _refreshLocations();
    // Refresh map every 5 seconds to show new points
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshLocations());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refreshLocations() async {
    final points = await DatabaseHelper().getLocations();
    if (points.isEmpty) return;

    List<List<LatLng>> segments = [];
    List<LatLng> currentSegment = [];

    // 1. Segment based on 100m gap
    for (int i = 0; i < points.length; i++) {
      final p = LatLng(points[i].lat, points[i].lon);
      
      if (currentSegment.isEmpty) {
        currentSegment.add(p);
      } else {
        final lastPoint = currentSegment.last;
        final distance = const Distance().as(LengthUnit.Meter, lastPoint, p);
        
        if (distance > 100) {
          segments.add(currentSegment);
          currentSegment = [p];
        } else {
          currentSegment.add(p);
        }
      }
    }
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
    }

    // 2. Smooth segments
    List<List<LatLng>> smoothedSegments = [];
    for (var segment in segments) {
      smoothedSegments.add(_makeSmooth(segment));
    }

    setState(() {
      _polylines = smoothedSegments;
      if (points.isNotEmpty) {
        _currentLocation = LatLng(points.last.lat, points.last.lon);
        
        // Center map on the user on the very first load
        if (!_hasInitiallyCentered && _currentLocation != null) {
          _mapController.move(_currentLocation!, 15.0);
          _hasInitiallyCentered = true;
        }
      }
    });
  }

  List<LatLng> _makeSmooth(List<LatLng> points) {
    if (points.length < 3) return points;
    List<LatLng> spline = [];
    // Catmull-Rom Spline
    // We add duplicate first and last points for control
    List<LatLng> padded = [points.first, ...points, points.last];

    for (int i = 0; i < padded.length - 3; i++) {
        LatLng p0 = padded[i];
        LatLng p1 = padded[i+1];
        LatLng p2 = padded[i+2];
        LatLng p3 = padded[i+3];

        // 10 points per segment for smoothness
        for (int t = 0; t <= 10; t++) {
           double tNorm = t / 10.0;
           double t2 = tNorm * tNorm;
           double t3 = t2 * tNorm;

           double f0 = -0.5 * t3 + t2 - 0.5 * tNorm;
           double f1 = 1.5 * t3 - 2.5 * t2 + 1.0;
           double f2 = -1.5 * t3 + 2.0 * t2 + 0.5 * tNorm;
           double f3 = 0.5 * t3 - 0.5 * t2;

           double lat = p0.latitude * f0 + p1.latitude * f1 + p2.latitude * f2 + p3.latitude * f3;
           double lon = p0.longitude * f0 + p1.longitude * f1 + p2.longitude * f2 + p3.longitude * f3;
           spline.add(LatLng(lat, lon));
        }
    }
    return spline;
  }

  void _recenter() {
    if (_currentLocation != null) {
       _mapController.move(_currentLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(0, 0),
              initialZoom: 2.0, // Start bumped out to see the world, avoids "blank screen" panic
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tracker',
              ),
              PolylineLayer(
                polylines: _polylines.map((points) => Polyline(
                  points: points,
                  strokeWidth: 4.0,
                  color: Colors.lightBlue,
                )).toList(),
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                     Marker(
                       point: _currentLocation!,
                       width: 40,
                       height: 40,
                       child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                     ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _recenter,
              child: const Icon(Icons.my_location),
            ),
          )
        ],
      ),
    );
  }
}

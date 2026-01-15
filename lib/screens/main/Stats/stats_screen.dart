import 'package:flutter/material.dart';
import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tracker/services/database_helper.dart';
import 'package:tracker/constants/app_constants.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Stream<StepCount> _stepCountStream;
  String _steps = '0';
  String _km = '0.00';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _refreshStats();
    // Refresh stats periodically
    _refreshTimer = Timer.periodic(AppConstants.statsRefreshInterval, (timer) {
      _refreshStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    await _calculateDistance();
    await _loadSteps();
  }
  
  Future<void> _loadSteps() async {
    final stats = await DatabaseHelper().getUserStats();
    if (mounted) {
      setState(() {
        _steps = (stats['total_steps'] ?? 0).toString();
      });
    }
  }

  Future<void> _calculateDistance() async {
    final points = await DatabaseHelper().getLocations();
    if (points.isEmpty) {
      if (mounted) {
        setState(() {
          _km = '0.00';
        });
      }
      return;
    }

    double totalDistance = 0.0;
    const distanceCalculator = Distance();
    
    // Minimum accuracy required to consider a point (in meters).
    // If accuracy is worse (higher number) than this, we skip it.
    const double minAccuracyThreshold = AppConstants.gpsMinAccuracyThreshold; 
    
    // Max reasonable speed in m/s (approx 100 km/h) to filter out jumps.
    const double maxSpeedMps = AppConstants.gpsMaxSpeedMps; 

    for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        // 1. Filter by Accuracy (if available)
        if (p1.accuracy != null && p1.accuracy! > minAccuracyThreshold) continue;
        if (p2.accuracy != null && p2.accuracy! > minAccuracyThreshold) continue;

        final dist = distanceCalculator.as(LengthUnit.Meter, 
            LatLng(p1.latitude, p1.longitude), 
            LatLng(p2.latitude, p2.longitude));

        // 2. Filter by plausible speed (teleportation check)
        final timeDiffSeconds = p2.recordedAt.difference(p1.recordedAt).inSeconds;
        
        // If points are extremely close in time but far in distance, it's likely a jump.
        // Allow for some gap: if timeDiff is 0 (same second), we skip unless distance is negligible.
        if (timeDiffSeconds <= 0) {
            if (dist > AppConstants.gpsMaxInstantJump) continue; // Skip if > 5m movement in 0 seconds
        } else {
            final calculatedSpeed = dist / timeDiffSeconds;
            if (calculatedSpeed > maxSpeedMps) continue;
        }

        totalDistance += dist;
    }

    if (mounted) {
      setState(() {
        _km = (totalDistance / 1000).toStringAsFixed(2);
      });
    }
  }

  void onStepCount(StepCount event) async {
    // Save to DB
    await DatabaseHelper().updateUserSteps(event.steps);
    // Refresh UI from DB to keep it consistent
    _loadSteps();
  }

  void onStepCountError(dynamic error) {
    print('onStepCountError: $error');
    // We don't necessarily need to show an error on screen, 
    // just fail gracefully and keep showing stored steps.
  }

  Future<void> initPlatformState() async {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Total Steps', style: TextStyle(fontSize: 30)),
            Text(_steps, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const Text('Total Distance', style: TextStyle(fontSize: 30)),
            Text('$_km km', style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:pedometer/pedometer.dart';
import 'package:tracker/services/database_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  String _km = '?';
  Timer? _distanceTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _calculateDistance();
    _distanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _calculateDistance();
    });
  }

  @override
  void dispose() {
    _distanceTimer?.cancel();
    super.dispose();
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

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = LatLng(points[i].latitude, points[i].longitude);
      final p2 = LatLng(points[i + 1].latitude, points[i + 1].longitude);
      totalDistance += distanceCalculator.as(LengthUnit.Kilometer, p1, p2);
    }

    if (mounted) {
      setState(() {
        _km = totalDistance.toStringAsFixed(2);
      });
    }
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(dynamic error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(dynamic error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  Future<void> initPlatformState() async {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

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
            Text('Steps Taken', style: TextStyle(fontSize: 30)),
            Text(_steps, style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text('Distance (km)', style: TextStyle(fontSize: 30)),
            Text(_km, style: TextStyle(fontSize: 60)),
            Divider(height: 100, thickness: 0, color: Colors.white),
            Text('Pedestrian Status', style: TextStyle(fontSize: 30)),
            Icon(
              _status == 'walking'
                  ? Icons.directions_walk
                  : _status == 'stopped'
                  ? Icons.accessibility_new
                  : Icons.error,
              size: 100,
            ),
            Center(
              child: Text(
                _status,
                style: _status == 'walking' || _status == 'stopped'
                    ? TextStyle(fontSize: 30)
                    : TextStyle(fontSize: 20, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

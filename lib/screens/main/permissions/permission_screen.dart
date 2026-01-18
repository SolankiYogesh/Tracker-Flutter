import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker/router/app_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tracker/screens/main/permissions/widgets/permission_card.dart';
import 'package:tracker/utils/responsive_utils.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;

  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _backgroundLocationStatus = PermissionStatus.denied;
  PermissionStatus _activityStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;
  bool _isLocationServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions(showLoader: true).then((_) => _initialRequestFlow());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions({bool showLoader = false}) async {
    if (showLoader && mounted) setState(() => _isLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final loc = await Permission.location.status;
      final bgLoc = await Permission.locationAlways.status;
      final activity = await Permission.activityRecognition.status;
      final notif = await Permission.notification.status;

      if (mounted) {
        setState(() {
          _locationStatus = loc;
          _backgroundLocationStatus = bgLoc;
          _activityStatus = activity;
          _notificationStatus = notif;
          _isLocationServiceEnabled = serviceEnabled;
          if (showLoader) _isLoading = false;
        });
        _checkAllGranted();
      }
    } catch (e) {
      if (showLoader && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _initialRequestFlow() async {
    if (!_locationStatus.isGranted) {
      await _requestPermission(Permission.location);
    }

    if (_locationStatus.isGranted && !_backgroundLocationStatus.isGranted) {
      await _requestPermission(Permission.locationAlways);
    }

    if (!_activityStatus.isGranted && Platform.isAndroid) {
      await _requestPermission(Permission.activityRecognition);
    }

    if (!_notificationStatus.isGranted) {
      await _requestPermission(Permission.notification);
    }
  }

  void _checkAllGranted() {
    bool allGranted =
        (_locationStatus.isGranted || _locationStatus.isLimited) &&
        (_backgroundLocationStatus.isGranted ||
            _backgroundLocationStatus.isLimited) &&
        (Platform.isAndroid
            ? (_activityStatus.isGranted || _activityStatus.isLimited)
            : true) &&
        (_notificationStatus.isGranted || _notificationStatus.isLimited) &&
        _isLocationServiceEnabled;

    if (allGranted && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRouter.main);
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    if (permission == Permission.locationAlways) {
      if (!_locationStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please grant "Location Access" first.'),
            ),
          );
        }
        return;
      }
    }

    final status = await permission.request();

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF141416);
    const cardColor = Color(0xFF2C2C2E);
    const accentColor = Color(0xFF9FA8DA);
    const textColor = Colors.white;
    const subTextColor = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.w(500)),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(24),
                      vertical: context.h(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: context.h(40)),

                        Center(
                          child: Container(
                            padding: EdgeInsets.all(context.w(16)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withValues(alpha: 0.2),
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: context.w(64),
                              color: accentColor,
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(32)),

                        Text(
                          'Location Permissions\nRequired',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(26),
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: context.h(16)),

                        Text(
                          'Tracktor needs location permissions to track\nyour movement and draw your path on the map.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(15),
                            color: subTextColor,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: context.h(40)),

                        PermissionCard(
                          icon: Icons.gps_fixed,
                          title: 'Location Services',
                          subtitle:
                              'Enable GPS on your device for accurate tracking',
                          status: PermissionStatus.granted,
                          isDone: _isLocationServiceEnabled,
                          onGrant: () => Geolocator.openLocationSettings(),
                          cardColor: cardColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        SizedBox(height: context.h(12)),

                        PermissionCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location Access',
                          subtitle: 'Required to track your GPS position',
                          status: _locationStatus,
                          onGrant: () =>
                              _requestPermission(Permission.location),
                          cardColor: cardColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        SizedBox(height: context.h(12)),

                        PermissionCard(
                          icon: Icons.location_searching,
                          title: 'Background Location',
                          subtitle:
                              'Required to track when app is in\nbackground',
                          status: _backgroundLocationStatus,
                          onGrant: () =>
                              _requestPermission(Permission.locationAlways),
                          cardColor: cardColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        SizedBox(height: context.h(12)),

                        PermissionCard(
                          icon: Icons.directions_walk,
                          title: 'Physical Activity',
                          subtitle:
                              'Required to count steps and detect\nactivity',
                          status: _activityStatus,
                          onGrant: () => _requestPermission(
                            Permission.activityRecognition,
                          ),
                          cardColor: cardColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        SizedBox(height: context.h(12)),

                        PermissionCard(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifications',
                          subtitle: 'Required to show tracking status',
                          status: _notificationStatus,
                          onGrant: () =>
                              _requestPermission(Permission.notification),
                          cardColor: cardColor,
                          accentColor: accentColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                        ),
                        SizedBox(height: context.h(40)),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

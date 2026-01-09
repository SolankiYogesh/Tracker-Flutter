import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker/screens/main_navigation_screen.dart';

class PermissionScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const PermissionScreen({super.key, required this.themeNotifier});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _isLoading = false;

  // Track status of each required permission
  PermissionStatus _locationStatus = PermissionStatus.denied;
  PermissionStatus _backgroundLocationStatus = PermissionStatus.denied;
  PermissionStatus _activityStatus = PermissionStatus.denied;
  PermissionStatus _notificationStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start by checking, then auto-requesting
    _checkPermissions().then((_) => _initialRequestFlow());
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

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    final loc = await Permission.location.status;
    final bgLoc = await Permission.locationAlways.status;
    final activity = await Permission.activityRecognition.status;
    final notif = await Permission.notification.status;

    setState(() {
      _locationStatus = loc;
      _backgroundLocationStatus = bgLoc;
      _activityStatus = activity;
      _notificationStatus = notif;
      _isLoading = false;
    });

    _checkAllGranted();
  }

  Future<void> _initialRequestFlow() async {
    // Sequentially request permissions that are not yet granted.
    // 1. Location
    if (!_locationStatus.isGranted) {
      await _requestPermission(Permission.location);
    }
    
    // 2. Background Location (Only if location is granted)
    // We need to re-check location status because _requestPermission updates it
    if (_locationStatus.isGranted && !_backgroundLocationStatus.isGranted) {
      await _requestPermission(Permission.locationAlways);
    }

    // 3. Activity
    if (!_activityStatus.isGranted) {
      await _requestPermission(Permission.activityRecognition);
    }

    // 4. Notifications
    if (!_notificationStatus.isGranted) {
      await _requestPermission(Permission.notification);
    }
  }

  void _checkAllGranted() {
    // Note: Background location might be "denied" if "whileInUse" is granted on some Android versions until upgraded.
    // Logic: 
    // - Foreground: Must be granted.
    // - Background: Must be granted for "perfect track".
    // - Activity: Must be granted.
    // - Notification: Must be granted.

    // On iOS, background location logic is different, usually handled by "Always" request.
    // Simplification for this task: Check if all are "granted".
    
    // PermissionStatus.granted or PermissionStatus.limited (iOS) are usually acceptable.
    bool allGranted = 
        (_locationStatus.isGranted || _locationStatus.isLimited) &&
        (_backgroundLocationStatus.isGranted || _backgroundLocationStatus.isLimited) &&
        (_activityStatus.isGranted || _activityStatus.isLimited) &&
        (_notificationStatus.isGranted || _notificationStatus.isLimited);

    if (allGranted && mounted) {
       Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainNavigationScreen(themeNotifier: widget.themeNotifier),
        ),
      );
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    // Special handling for background location on Android 11+
    if (permission == Permission.locationAlways) {
      if (!_locationStatus.isGranted) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please grant "Location Access" first.')),
          );
        }
        return;
      }
    }

    final status = await permission.request();
    
    // If permanently denied, open settings
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    // Re-check all
    await _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme colors based on screenshot
    const backgroundColor = Color(0xFF141416); // Very dark/black
    const cardColor = Color(0xFF2C2C2E); // Dark Grey
    const accentColor = Color(0xFF9FA8DA); // Light Indigo
    const textColor = Colors.white;
    const subTextColor = Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Header Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.2), // Light circle bg
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 64,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      'Location Permissions\nRequired',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    const Text(
                      'Tracktor needs location permissions to track\nyour movement and draw your path on the map.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Permission Cards
                    _buildPermissionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Location Access',
                      subtitle: 'Required to track your GPS position',
                      status: _locationStatus,
                      onGrant: () => _requestPermission(Permission.location),
                      cardColor: cardColor,
                      accentColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildPermissionCard(
                      icon: Icons.location_searching,
                      title: 'Background Location',
                      subtitle: 'Required to track when app is in\nbackground',
                      status: _backgroundLocationStatus,
                      onGrant: () => _requestPermission(Permission.locationAlways),
                      cardColor: cardColor,
                      accentColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildPermissionCard(
                      icon: Icons.directions_walk,
                      title: 'Physical Activity',
                      subtitle: 'Required to count steps and detect\nactivity',
                      status: _activityStatus,
                      onGrant: () => _requestPermission(Permission.activityRecognition),
                      cardColor: cardColor,
                      accentColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                    const SizedBox(height: 16),

                    _buildPermissionCard(
                      icon: Icons.notifications_active_outlined,
                      title: 'Notifications',
                      subtitle: 'Required to show tracking status',
                      status: _notificationStatus,
                      onGrant: () => _requestPermission(Permission.notification),
                      cardColor: cardColor,
                      accentColor: accentColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                    ),
                     const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required PermissionStatus status,
    required VoidCallback onGrant,
    required Color cardColor,
    required Color accentColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    final isGranted = status.isGranted || status.isLimited;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          isGranted
              ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
              : ElevatedButton(
                  onPressed: onGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black, // Text color on button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Grant'),
                ),
        ],
      ),
    );
  }
}
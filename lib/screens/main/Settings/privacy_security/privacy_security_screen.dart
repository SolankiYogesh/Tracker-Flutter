import 'package:flutter/material.dart';
import 'package:tracker/screens/main/Settings/privacy_security/widgets/security_status_badge.dart';
import 'package:tracker/screens/main/Settings/widgets/setting_item.dart';
import 'package:tracker/theme/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _faceIdEnabled = true;
  bool _incognitoMode = false;
  bool _shareAnalytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SecurityStatusBadge(),
            const SizedBox(height: 32),
            const Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SettingItem(
              title: 'App Lock',
              subtitle: 'Require Face ID / Fingerprint to open',
              leadingIcon: Icons.fingerprint,
              trailing: Switch(
                value: _faceIdEnabled,
                onChanged: (value) {
                  setState(() {
                    _faceIdEnabled = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              onTap: () {
                setState(() {
                  _faceIdEnabled = !_faceIdEnabled;
                });
              },
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Change Password',
              subtitle: 'Last changed 3 months ago',
              leadingIcon: Icons.lock_outline,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
            const SizedBox(height: 32),
            const Text(
              'Privacy Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SettingItem(
              title: 'Incognito Tracking',
              subtitle: 'Do not save location logs to history',
              leadingIcon: Icons.visibility_off_outlined,
              trailing: Switch(
                value: _incognitoMode,
                onChanged: (value) {
                  setState(() {
                    _incognitoMode = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              onTap: () {
                setState(() {
                  _incognitoMode = !_incognitoMode;
                });
              },
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Share Usage Analytics',
              subtitle: 'Help us improve the app experience',
              leadingIcon: Icons.analytics_outlined,
              trailing: Switch(
                value: _shareAnalytics,
                onChanged: (value) {
                  setState(() {
                    _shareAnalytics = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              onTap: () {
                setState(() {
                  _shareAnalytics = !_shareAnalytics;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Device Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SettingItem(
              title: 'Location Permissions',
              subtitle: 'Managed in system settings',
              leadingIcon: Icons.location_on_outlined,
              trailing: const Icon(Icons.open_in_new, size: 14),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Notification Settings',
              subtitle: 'Managed in system settings',
              leadingIcon: Icons.notifications_none,
              trailing: const Icon(Icons.open_in_new, size: 14),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

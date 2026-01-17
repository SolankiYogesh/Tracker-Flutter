import 'package:flutter/material.dart';
import 'package:tracker/screens/main/settings/privacy_security/widgets/security_status_badge.dart';
import 'package:tracker/screens/main/settings/widgets/setting_item.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/utils/responsive_utils.dart';

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
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SecurityStatusBadge(),
            SizedBox(height: context.h(32)),
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.h(16)),
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
            SizedBox(height: context.h(12)),
            SettingItem(
              title: 'Change Password',
              subtitle: 'Last changed 3 months ago',
              leadingIcon: Icons.lock_outline,
              trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
              onTap: () {},
            ),
            SizedBox(height: context.h(32)),
            Text(
              'Privacy Controls',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.h(16)),
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
            SizedBox(height: context.h(12)),
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
            SizedBox(height: context.h(32)),
            Text(
              'Device Permissions',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.h(16)),
            SettingItem(
              title: 'Location Permissions',
              subtitle: 'Managed in system settings',
              leadingIcon: Icons.location_on_outlined,
              trailing: Icon(Icons.open_in_new, size: context.w(14)),
              onTap: () {},
            ),
            SizedBox(height: context.h(12)),
            SettingItem(
              title: 'Notification Settings',
              subtitle: 'Managed in system settings',
              leadingIcon: Icons.notifications_none,
              trailing: Icon(Icons.open_in_new, size: context.w(14)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

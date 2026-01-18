import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/theme_provider.dart';
import 'package:tracker/screens/main/settings/widgets/setting_item.dart';
import 'package:tracker/screens/main/settings/widgets/setting_profile_card.dart';
import 'package:tracker/screens/main/settings/widgets/setting_section.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/router/app_router.dart';
import 'package:tracker/utils/responsive_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // bool _notificationsEnabled = true;
  // bool _locationTracking = true;
  // bool _autoSync = true;
  // bool _privacyMode = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.w(16)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!context.mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthServiceProvider>().logout();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.root, (route) => false);
      }
    } catch (e) {
      if (!context.mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> changeTheme(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      context.read<ThemeProvider>().toggleTheme();
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = context.watch<ThemeProvider>().isDark;
    final user = context.watch<AuthServiceProvider>().appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.h(8)),
                    if (user != null) SettingProfileCard(user: user),

                    // Preferences Section
                    SettingSection(
                      title: 'Preferences',
                      icon: Icons.settings,
                      children: [
                        SettingItem(
                          title: 'Theme',
                          subtitle: isDarkTheme ? 'Dark Mode' : 'Light Mode',
                          trailing: Switch(
                            value: isDarkTheme,
                            onChanged: (value) => changeTheme(context),
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () => changeTheme(context),
                          leadingIcon: Icons.dark_mode,
                        ),
                        // Divider(
                        //   height: 1,
                        //   thickness: 0.5,
                        //   color: Theme.of(
                        //     context,
                        //   ).dividerColor.withValues(alpha: .3),
                        //   indent: context.w(64),
                        // ),
                        // SettingItem(
                        //   title: 'Notifications',
                        //   subtitle: 'Receive app notifications',
                        //   trailing: Switch(
                        //     value: _notificationsEnabled,
                        //     onChanged: (value) {
                        //       setState(() {
                        //         _notificationsEnabled = value;
                        //       });
                        //     },
                        //     activeThumbColor: AppColors.primary,
                        //   ),
                        //   onTap: () {
                        //     setState(() {
                        //       _notificationsEnabled = !_notificationsEnabled;
                        //     });
                        //   },
                        //   leadingIcon: Icons.notifications,
                        // ),
                        //   Divider(
                        //     height: 1,
                        //     thickness: 0.5,
                        //     color: Theme.of(
                        //       context,
                        //     ).dividerColor.withValues(alpha: .3),
                        //     indent: context.w(64),
                        //   ),
                        //   SettingItem(
                        //     title: 'Location Tracking',
                        //     subtitle: 'Track location in background',
                        //     trailing: Switch(
                        //       value: _locationTracking,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           _locationTracking = value;
                        //         });
                        //       },
                        //       activeThumbColor: AppColors.primary,
                        //     ),
                        //     onTap: () {
                        //       setState(() {
                        //         _locationTracking = !_locationTracking;
                        //       });
                        //     },
                        //     leadingIcon: Icons.location_on,
                        //   ),
                      ],
                    ),

                    // Tracking Section
                    SettingSection(
                      title: 'Activity Tracking',
                      icon: Icons.analytics_outlined,
                      children: [
                        SettingItem(
                          title: 'Travel Insights',
                          subtitle: 'Track your walking and vehicle trips',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.travelHistory,
                            );
                          },
                          leadingIcon: Icons.route_outlined,
                        ),
                      ],
                    ),

                    // SettingSection(
                    //   title: 'Privacy & Security',
                    //   icon: Icons.security,
                    //   children: [
                    //     SettingItem(
                    //       title: 'Privacy & Security Settings',
                    //       subtitle: 'Manage your account security',
                    //       trailing: Icon(
                    //         Icons.chevron_right,
                    //         color: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium!
                    //             .color!
                    //             .withValues(alpha: .5),
                    //       ),
                    //       onTap: () {
                    //         Navigator.pushNamed(
                    //           context,
                    //           AppRouter.privacySecurity,
                    //         );
                    //       },
                    //       leadingIcon: Icons.security_outlined,
                    //     ),
                    //     Divider(
                    //       height: 1,
                    //       thickness: 0.5,
                    //       color: Theme.of(
                    //         context,
                    //       ).dividerColor.withValues(alpha: .3),
                    //       indent: 64,
                    //     ),
                    //     SettingItem(
                    //       title: 'Privacy Mode',
                    //       subtitle: 'Hide sensitive information',
                    //       trailing: Switch(
                    //         value: _privacyMode,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _privacyMode = value;
                    //           });
                    //         },
                    //         activeThumbColor: AppColors.primary,
                    //       ),
                    //       onTap: () {
                    //         setState(() {
                    //           _privacyMode = !_privacyMode;
                    //         });
                    //       },
                    //       leadingIcon: Icons.visibility_off,
                    //     ),
                    //     Divider(
                    //       height: 1,
                    //       thickness: 0.5,
                    //       color: Theme.of(
                    //         context,
                    //       ).dividerColor.withValues(alpha: .3),
                    //       indent: 64,
                    //     ),
                    //     SettingItem(
                    //       title: 'Auto Sync',
                    //       subtitle: 'Automatically sync data',
                    //       trailing: Switch(
                    //         value: _autoSync,
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _autoSync = value;
                    //           });
                    //         },
                    //         activeThumbColor: AppColors.primary,
                    //       ),
                    //       onTap: () {
                    //         setState(() {
                    //           _autoSync = !_autoSync;
                    //         });
                    //       },
                    //       leadingIcon: Icons.sync,
                    //     ),
                    //     Divider(
                    //       height: 1,
                    //       thickness: 0.5,
                    //       color: Theme.of(
                    //         context,
                    //       ).dividerColor.withValues(alpha: .3),
                    //       indent: 64,
                    //     ),
                    //     SettingItem(
                    //       title: 'Data & Storage',
                    //       subtitle: 'Manage storage and cache',
                    //       trailing: Icon(
                    //         Icons.chevron_right,
                    //         color: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium!
                    //             .color!
                    //             .withValues(alpha: .5),
                    //       ),
                    //       onTap: () {
                    //         Navigator.pushNamed(context, AppRouter.dataStorage);
                    //       },
                    //       leadingIcon: Icons.storage,
                    //     ),
                    //   ],
                    // ),

                    // Support Section
                    // SettingSection(
                    //   title: 'Support',
                    //   icon: Icons.help,
                    //   children: [
                    //     SettingItem(
                    //       title: 'Help & Support',
                    //       subtitle: 'Get help with the app',
                    //       trailing: Icon(
                    //         Icons.chevron_right,
                    //         color: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium!
                    //             .color!
                    //             .withValues(alpha: .5),
                    //       ),
                    //       onTap: () {
                    //         Navigator.pushNamed(context, AppRouter.helpSupport);
                    //       },
                    //       leadingIcon: Icons.help_center,
                    //     ),
                    //     Divider(
                    //       height: 1,
                    //       thickness: 0.5,
                    //       color: Theme.of(
                    //         context,
                    //       ).dividerColor.withValues(alpha: .3),
                    //       indent: 64,
                    //     ),
                    //     SettingItem(
                    //       title: 'About',
                    //       subtitle: 'App version and info',
                    //       trailing: Icon(
                    //         Icons.chevron_right,
                    //         color: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium!
                    //             .color!
                    //             .withValues(alpha: .5),
                    //       ),
                    //       onTap: () {
                    //         Navigator.pushNamed(context, AppRouter.about);
                    //       },
                    //       leadingIcon: Icons.info,
                    //     ),
                    //     Divider(
                    //       height: 1,
                    //       thickness: 0.5,
                    //       color: Theme.of(
                    //         context,
                    //       ).dividerColor.withValues(alpha: .3),
                    //       indent: 64,
                    //     ),
                    //     SettingItem(
                    //       title: 'Rate App',
                    //       subtitle: 'Share your feedback',
                    //       trailing: Icon(
                    //         Icons.chevron_right,
                    //         color: Theme.of(context)
                    //             .textTheme
                    //             .bodyMedium!
                    //             .color!
                    //             .withValues(alpha: .5),
                    //       ),
                    //       onTap: () {
                    //         // Open app store for rating
                    //       },
                    //       leadingIcon: Icons.star,
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: context.h(32)),
                  ],
                ),
              ),
            ),

            // Logout Button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(12),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: .2),
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () => logOut(context),
                icon: Icon(Icons.logout, size: context.w(20)),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: context.sp(15),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(context.h(52)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.w(14)),
                  ),
                  elevation: 0,
                  backgroundColor: AppColors.error.withValues(alpha: .1),
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: .2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

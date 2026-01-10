import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/models/user_response.dart';
import 'package:tracker/providers/auth_service_provider.dart';
import 'package:tracker/providers/theme_provider.dart';
import 'package:tracker/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationTracking = true;
  bool _autoSync = true;
  bool _privacyMode = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOut(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await context.read<AuthServiceProvider>().logout();
    } catch (e) {
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

  Widget _buildUserProfileCard(UserResponse? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.darkGlassBorder
        : AppColors.lightGlassBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              image: user?.picture != null
                  ? DecorationImage(
                      image: NetworkImage(user!.picture!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.picture == null
                ? Icon(Icons.person, size: 36, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No Email',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Joined ${_formatDate(user?.createdAt)}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.edit, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.darkGlassBorder
        : AppColors.lightGlassBorder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    IconData? leadingIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(leadingIcon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
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
                    const SizedBox(height: 8),
                    _buildUserProfileCard(user),

                    // Preferences Section
                    _buildSettingsSection(
                      title: 'Preferences',
                      icon: Icons.settings,
                      children: [
                        _buildSettingItem(
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
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'Notifications',
                          subtitle: 'Receive app notifications',
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                _notificationsEnabled = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () {
                            setState(() {
                              _notificationsEnabled = !_notificationsEnabled;
                            });
                          },
                          leadingIcon: Icons.notifications,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'Location Tracking',
                          subtitle: 'Track location in background',
                          trailing: Switch(
                            value: _locationTracking,
                            onChanged: (value) {
                              setState(() {
                                _locationTracking = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () {
                            setState(() {
                              _locationTracking = !_locationTracking;
                            });
                          },
                          leadingIcon: Icons.location_on,
                        ),
                      ],
                      context: context,
                    ),

                    // Privacy & Security Section
                    _buildSettingsSection(
                      title: 'Privacy & Security',
                      icon: Icons.security,
                      children: [
                        _buildSettingItem(
                          title: 'Privacy Mode',
                          subtitle: 'Hide sensitive information',
                          trailing: Switch(
                            value: _privacyMode,
                            onChanged: (value) {
                              setState(() {
                                _privacyMode = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () {
                            setState(() {
                              _privacyMode = !_privacyMode;
                            });
                          },
                          leadingIcon: Icons.visibility_off,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'Auto Sync',
                          subtitle: 'Automatically sync data',
                          trailing: Switch(
                            value: _autoSync,
                            onChanged: (value) {
                              setState(() {
                                _autoSync = value;
                              });
                            },
                            activeThumbColor: AppColors.primary,
                          ),
                          onTap: () {
                            setState(() {
                              _autoSync = !_autoSync;
                            });
                          },
                          leadingIcon: Icons.sync,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'Data & Storage',
                          subtitle: 'Manage storage and cache',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                          onTap: () {
                            // Navigate to data management screen
                          },
                          leadingIcon: Icons.storage,
                        ),
                      ],
                      context: context,
                    ),

                    // Support Section
                    _buildSettingsSection(
                      title: 'Support',
                      icon: Icons.help,
                      children: [
                        _buildSettingItem(
                          title: 'Help & Support',
                          subtitle: 'Get help with the app',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                          onTap: () {
                            // Navigate to help screen
                          },
                          leadingIcon: Icons.help_center,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'About',
                          subtitle: 'App version and info',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                          onTap: () {
                            // Navigate to about screen
                          },
                          leadingIcon: Icons.info,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .3),
                          indent: 64,
                        ),
                        _buildSettingItem(
                          title: 'Rate App',
                          subtitle: 'Share your feedback',
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withValues(alpha: .5),
                          ),
                          onTap: () {
                            // Open app store for rating
                          },
                          leadingIcon: Icons.star,
                        ),
                      ],
                      context: context,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Logout Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

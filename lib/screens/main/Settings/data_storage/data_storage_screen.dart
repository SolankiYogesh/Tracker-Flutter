import 'package:flutter/material.dart';
import 'package:tracker/screens/main/Settings/data_storage/widgets/storage_usage_card.dart';
import 'package:tracker/screens/main/Settings/widgets/setting_item.dart';
import 'package:tracker/theme/app_colors.dart';

class DataStorageScreen extends StatefulWidget {
  const DataStorageScreen({super.key});

  @override
  State<DataStorageScreen> createState() => _DataStorageScreenState();
}

class _DataStorageScreenState extends State<DataStorageScreen> {
  bool _mobileDataTracking = true;
  bool _offlineMaps = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Storage'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StorageUsageCard(),
            const SizedBox(height: 32),
            const Text(
              'Network Usage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SettingItem(
              title: 'Mobile Data Tracking',
              subtitle: 'Allow tracking when on mobile data',
              leadingIcon: Icons.network_cell,
              trailing: Switch(
                value: _mobileDataTracking,
                onChanged: (value) {
                  setState(() {
                    _mobileDataTracking = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              onTap: () {
                setState(() {
                  _mobileDataTracking = !_mobileDataTracking;
                });
              },
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Offline Maps',
              subtitle: 'Download maps for offline use',
              leadingIcon: Icons.map_outlined,
              trailing: Switch(
                value: _offlineMaps,
                onChanged: (value) {
                  setState(() {
                    _offlineMaps = value;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
              onTap: () {
                setState(() {
                  _offlineMaps = !_offlineMaps;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SettingItem(
              title: 'Clear Cache',
              subtitle: 'Remove temporary files',
              leadingIcon: Icons.cleaning_services_outlined,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Export History',
              subtitle: 'Download all tracking logs as CSV',
              leadingIcon: Icons.file_download_outlined,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            SettingItem(
              title: 'Delete All History',
              subtitle: 'Permanently remove all logs',
              leadingIcon: Icons.delete_outline,
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

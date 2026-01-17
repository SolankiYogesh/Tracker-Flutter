import 'package:flutter/material.dart';
import 'package:tracker/screens/main/settings/about/widgets/about_app_card.dart';
import 'package:tracker/screens/main/settings/widgets/setting_item.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AboutAppCard(),
            const SizedBox(height: 32),
            _buildLinksSection(context),
            const SizedBox(height: 40),
            Text(
              '© 2026 GeoPulsify Inc.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Made with ❤️ for modern travelers',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksSection(BuildContext context) {
    return Column(
      children: [
        SettingItem(
          title: 'Website',
          subtitle: 'Visit our official website',
          leadingIcon: Icons.language,
          trailing: const Icon(Icons.open_in_new, size: 16),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        SettingItem(
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          leadingIcon: Icons.policy_outlined,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        SettingItem(
          title: 'Terms of Service',
          subtitle: 'App usage guidelines',
          leadingIcon: Icons.description_outlined,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        SettingItem(
          title: 'Open Source Licenses',
          subtitle: 'Third-party attribution',
          leadingIcon: Icons.code,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
      ],
    );
  }
}

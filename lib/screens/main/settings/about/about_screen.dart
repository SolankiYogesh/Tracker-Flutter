import 'package:flutter/material.dart';
import 'package:tracker/screens/main/settings/about/widgets/about_app_card.dart';
import 'package:tracker/screens/main/settings/widgets/setting_item.dart';
import 'package:tracker/utils/responsive_utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          children: [
            const AboutAppCard(),
            SizedBox(height: context.h(32)),
            _buildLinksSection(context),
            SizedBox(height: context.h(40)),
            Text(
              '© 2026 GeoPulsify Inc.',
              style: TextStyle(
                fontSize: context.sp(14),
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: context.h(8)),
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
          trailing: Icon(Icons.open_in_new, size: context.w(16)),
          onTap: () {},
        ),
        SizedBox(height: context.h(12)),
        SettingItem(
          title: 'Privacy Policy',
          subtitle: 'How we handle your data',
          leadingIcon: Icons.policy_outlined,
          trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
          onTap: () {},
        ),
        SizedBox(height: context.h(12)),
        SettingItem(
          title: 'Terms of Service',
          subtitle: 'App usage guidelines',
          leadingIcon: Icons.description_outlined,
          trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
          onTap: () {},
        ),
        SizedBox(height: context.h(12)),
        SettingItem(
          title: 'Open Source Licenses',
          subtitle: 'Third-party attribution',
          leadingIcon: Icons.code,
          trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
          onTap: () {},
        ),
      ],
    );
  }
}

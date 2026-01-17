import 'package:flutter/material.dart';
import 'package:tracker/screens/main/settings/help_support/widgets/faq_item.dart';
import 'package:tracker/screens/main/settings/widgets/setting_item.dart';
import 'package:tracker/utils/responsive_utils.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context),
            SizedBox(height: context.h(32)),
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.h(16)),
            const FaqItem(
              question: 'How do I start tracking my location?',
              answer:
                  'Go to the Map screen and ensure location tracking is enabled in Settings. The app will automatically track your location in the background.',
            ),
            const FaqItem(
              question: 'Is my data secure?',
              answer:
                  'Yes, your data is stored securely on our servers and is only accessible by you. We use industry-standard encryption to protect your privacy.',
            ),
            const FaqItem(
              question: 'How can I export my data?',
              answer:
                  'You can export your tracking data from the Data & Storage section in Settings. Data is exported in CSV format.',
            ),
            const FaqItem(
              question: 'The app is not tracking in background.',
              answer:
                  'Please ensure you have granted "Always" location permission in your device settings. Also check if battery optimization is disabled for GeoPulsify.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.h(16)),
        SettingItem(
          title: 'Email Support',
          subtitle: 'support@tracker.app',
          leadingIcon: Icons.email_outlined,
          trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
          onTap: () {},
        ),
        SizedBox(height: context.h(12)),
        SettingItem(
          title: 'Live Chat',
          subtitle: 'Available 24/7',
          leadingIcon: Icons.chat_bubble_outline,
          trailing: Icon(Icons.arrow_forward_ios, size: context.w(14)),
          onTap: () {},
        ),
      ],
    );
  }
}

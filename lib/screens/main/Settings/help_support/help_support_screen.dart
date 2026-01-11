import 'package:flutter/material.dart';
import 'package:tracker/screens/main/Settings/help_support/widgets/faq_item.dart';
import 'package:tracker/screens/main/Settings/widgets/setting_item.dart';
import 'package:tracker/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context),
            const SizedBox(height: 32),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const FaqItem(
              question: 'How do I start tracking my location?',
              answer: 'Go to the Map screen and ensure location tracking is enabled in Settings. The app will automatically track your location in the background.',
            ),
            const FaqItem(
              question: 'Is my data secure?',
              answer: 'Yes, your data is stored securely on our servers and is only accessible by you. We use industry-standard encryption to protect your privacy.',
            ),
            const FaqItem(
              question: 'How can I export my data?',
              answer: 'You can export your tracking data from the Data & Storage section in Settings. Data is exported in CSV format.',
            ),
            const FaqItem(
              question: 'The app is not tracking in background.',
              answer: 'Please ensure you have granted "Always" location permission in your device settings. Also check if battery optimization is disabled for Tracker.',
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
        const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SettingItem(
          title: 'Email Support',
          subtitle: 'support@tracker.app',
          leadingIcon: Icons.email_outlined,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        SettingItem(
          title: 'Live Chat',
          subtitle: 'Available 24/7',
          leadingIcon: Icons.chat_bubble_outline,
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {},
        ),
      ],
    );
  }
}

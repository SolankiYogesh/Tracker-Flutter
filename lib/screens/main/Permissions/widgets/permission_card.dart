import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final PermissionStatus status;
  final VoidCallback onGrant;
  final Color cardColor;
  final Color accentColor;
  final Color textColor;
  final IconData icon;
  final Color subTextColor;
  final bool? isDone = false;
  PermissionCard({
    super.key,
    bool? isDone,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onGrant,
    required this.cardColor,
    required this.accentColor,
    required this.textColor,
    required this.icon,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final isGranted = isDone ?? (status.isGranted || status.isLimited);
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
                  style: TextStyle(fontSize: 12, color: subTextColor),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Grant'),
                ),
        ],
      ),
    );
  }
}

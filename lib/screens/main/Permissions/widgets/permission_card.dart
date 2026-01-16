import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionCard extends StatelessWidget {
  const PermissionCard({
    super.key,
    this.isDone,
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
  final String title;
  final String subtitle;
  final PermissionStatus status;
  final VoidCallback onGrant;
  final Color cardColor;
  final Color accentColor;
  final Color textColor;
  final IconData icon;
  final Color subTextColor;
  final bool? isDone;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isGranted = isDone ?? (status.isGranted || status.isLimited);

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: isCompact ? 24 : 28),
          SizedBox(width: isCompact ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isCompact ? 11 : 12,
                    color: subTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          isGranted
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: isCompact ? 24 : 28,
                )
              : ElevatedButton(
                  onPressed: onGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 20,
                      vertical: isCompact ? 8 : 10,
                    ),
                    minimumSize: Size(isCompact ? 60 : 80, 0),
                    elevation: 0,
                  ),
                  child: Text(
                    'Grant',
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

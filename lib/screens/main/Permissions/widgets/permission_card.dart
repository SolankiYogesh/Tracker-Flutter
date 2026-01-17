import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker/utils/responsive_utils.dart';

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
    final isGranted = isDone ?? (status.isGranted || status.isLimited);

    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(context.w(16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: subTextColor, size: context.w(28)),
          SizedBox(width: context.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.sp(16),
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.sp(13),
                    color: subTextColor,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.w(12)),
          isGranted
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: context.w(28),
                )
              : ElevatedButton(
                  onPressed: onGrant,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(context.w(20)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(20),
                      vertical: context.h(10),
                    ),
                    minimumSize: Size(context.w(80), 0),
                    elevation: 0,
                  ),
                  child: Text(
                    'Grant',
                    style: TextStyle(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

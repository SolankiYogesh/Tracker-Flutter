import 'package:flutter/material.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/utils/responsive_utils.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.leadingIcon,
  });
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.w(12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(16),
            vertical: context.h(14),
          ),
          child: Row(
            children: [
              if (leadingIcon != null) ...[
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.w(10)),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: context.w(20),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: context.w(12)),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: context.sp(15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: context.h(2)),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: context.sp(13),
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
}

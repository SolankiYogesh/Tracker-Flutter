import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/user_response.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/utils/responsive_utils.dart';

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

class SettingProfileCard extends StatelessWidget {
  const SettingProfileCard({super.key, required this.user});
  final UserResponse user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(8),
      ),
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(context.w(20)),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.w(10),
            offset: Offset(0, context.h(4)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: context.w(70),
            height: context.w(70),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: context.w(2),
              ),
              image: user.picture != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(user.picture!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user.picture == null
                ? Icon(
                    Icons.person,
                    size: context.w(36),
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(width: context.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: context.sp(14),
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.color!.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(8)),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: context.w(14),
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.color!.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: context.w(6)),
                    Text(
                      'Joined ${_formatDate(user.createdAt)}',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: context.sp(12),
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
          // Icon(Icons.edit, color: AppColors.primary, size: context.w(20)),
        ],
      ),
    );
  }
}

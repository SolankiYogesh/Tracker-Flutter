import 'package:flutter/material.dart';
import 'package:tracker/theme/app_colors.dart';
import 'package:tracker/utils/responsive_utils.dart';

class StorageUsageCard extends StatelessWidget {
  const StorageUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(24)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(context.w(24)),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage Usage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '12.5 MB',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: context.sp(18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(20)),
          ClipRRect(
            borderRadius: BorderRadius.circular(context.w(8)),
            child: LinearProgressIndicator(
              value: 0.15,
              minHeight: context.h(8),
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: context.h(16)),
          Row(
            children: [
              _buildUsageItem(context, 'Data', '10.2 MB', AppColors.primary),
              SizedBox(width: context.w(24)),
              _buildUsageItem(context, 'Cache', '2.3 MB', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: context.w(8),
              height: context.w(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: context.w(8)),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: context.sp(12),
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(4)),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: context.sp(14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

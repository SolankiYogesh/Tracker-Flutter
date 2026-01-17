import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/entity_model.dart' as model;
import 'package:tracker/utils/responsive_utils.dart';

class EntityInfoSheet extends StatelessWidget {
  final model.Entity entity;
  final void Function(double lat, double lng) onDirectionTap;

  const EntityInfoSheet({
    super.key,
    required this.entity,
    required this.onDirectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sw,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.w(28)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: context.w(10),
            spreadRadius: context.w(5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        context.w(24),
        context.h(12),
        context.w(24),
        context.h(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.w(40),
            height: context.h(4),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(context.w(2)),
            ),
          ),
          SizedBox(height: context.h(24)),
          CircleAvatar(
            radius: context.w(45),
            backgroundColor: Colors.transparent,
            backgroundImage: entity.entityType?.iconUrl != null
                ? CachedNetworkImageProvider(entity.entityType!.iconUrl!)
                : null,
            child: entity.entityType?.iconUrl == null
                ? Icon(Icons.extension, size: context.w(45))
                : null,
          ),
          SizedBox(height: context.h(16)),
          Text(
            entity.entityType?.name ?? 'Unknown Item',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: context.sp(22),
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.h(8)),
          Text(
            entity.entityType?.description ?? 'Discover this item on the map',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: context.sp(15),
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          SizedBox(height: context.h(20)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(16),
              vertical: context.h(8),
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(context.w(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt, color: Colors.amber, size: context.w(20)),
                SizedBox(width: context.w(4)),
                Text(
                  '${entity.xpValue} XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(32)),
          SizedBox(
            width: double.infinity,
            height: context.h(56),
            child: ElevatedButton.icon(
              onPressed: () =>
                  onDirectionTap(entity.latitude, entity.longitude),
              icon: const Icon(Icons.directions_outlined),
              label: Text(
                'Get Directions',
                style: TextStyle(
                  fontSize: context.sp(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.w(16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

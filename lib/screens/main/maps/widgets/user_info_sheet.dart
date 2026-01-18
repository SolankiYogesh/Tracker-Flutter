import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/utils/responsive_utils.dart';

class UserInfoSheet extends StatelessWidget {

  const UserInfoSheet({
    super.key,
    required this.user,
    required this.onDirectionTap,
    required this.timeAgoFormatter,
  });
  final NearbyUser user;
  final void Function(double lat, double lng) onDirectionTap;
  final String Function(DateTime d) timeAgoFormatter;

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
          // Drag handle
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
            backgroundImage: user.picture != null
                ? CachedNetworkImageProvider(user.picture!)
                : null,
            child: user.picture == null
                ? Icon(Icons.person, size: context.w(45))
                : null,
          ),
          SizedBox(height: context.h(16)),
          Text(
            user.name ?? 'Unknown User',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: context.sp(22),
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: context.h(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: context.h(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.w(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place, size: context.w(16), color: Colors.blue),
                    SizedBox(width: context.w(4)),
                    Text(
                      '${user.distanceMeters.toStringAsFixed(0)}m away',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.w(12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: context.h(6),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.w(12)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: context.w(16),
                      color: Colors.green,
                    ),
                    SizedBox(width: context.w(4)),
                    Text(
                      'Active ${timeAgoFormatter(user.lastUpdated)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(32)),
          SizedBox(
            width: double.infinity,
            height: context.h(56),
            child: ElevatedButton.icon(
              onPressed: () => onDirectionTap(user.latitude, user.longitude),
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

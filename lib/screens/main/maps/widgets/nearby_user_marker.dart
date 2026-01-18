import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/nearby_user.dart';
import 'package:tracker/utils/responsive_utils.dart';

class NearbyUserMarker extends StatelessWidget {

  const NearbyUserMarker({super.key, required this.user, required this.onTap});
  final NearbyUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: context.w(2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: context.w(4),
            ),
          ],
        ),
        child: CircleAvatar(
          backgroundImage: user.picture != null
              ? CachedNetworkImageProvider(user.picture!)
              : null,
          child: user.picture == null
              ? Icon(Icons.person, size: context.w(24))
              : null,
        ),
      ),
    );
  }
}

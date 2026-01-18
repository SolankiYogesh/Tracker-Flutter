import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/entity_model.dart' as model;
import 'package:tracker/utils/responsive_utils.dart';

class EntityMarker extends StatelessWidget {
  final model.Entity entity;
  final VoidCallback onTap;

  const EntityMarker({super.key, required this.entity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          entity.entityType?.iconUrl != null
              ? CachedNetworkImage(
                  imageUrl: entity.entityType!.iconUrl!,
                  width: context.w(50),
                  height: context.w(50),
                  errorWidget: (c, e, s) => Icon(
                    Icons.extension,
                    color: Colors.purple,
                    size: context.w(40),
                  ),
                )
              : Icon(
                  Icons.extension,
                  color: Colors.purple,
                  size: context.w(40),
                ),
        ],
      ),
    );
  }
}

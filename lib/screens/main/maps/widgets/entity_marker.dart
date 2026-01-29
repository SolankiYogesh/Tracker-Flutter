import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tracker/models/entity_model.dart' as model;
import 'package:tracker/utils/responsive_utils.dart';

class EntityMarker extends StatelessWidget {

  const EntityMarker({super.key, required this.entity, required this.onTap});
  final model.Entity entity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.contain,
        child: entity.entityType?.iconUrl != null
            ? CachedNetworkImage(
                imageUrl: entity.entityType!.iconUrl!,
                width: 60, // Use a base reference size, FittedBox will scale it
                height: 60,
                errorWidget: (c, e, s) => const Icon(
                  Icons.extension,
                  color: Colors.purple,
                  size: 50,
                ),
              )
            : const Icon(
                Icons.extension,
                color: Colors.purple,
                size: 50,
              ),
      ),
    );
  }
}

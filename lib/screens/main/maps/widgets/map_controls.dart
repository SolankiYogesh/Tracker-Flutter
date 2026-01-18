import 'package:flutter/material.dart';
import 'package:tracker/utils/responsive_utils.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onRecenter;

  const MapControls({super.key, required this.onRecenter});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: context.h(30),
      right: context.w(20),
      child: FloatingActionButton(
        onPressed: onRecenter,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

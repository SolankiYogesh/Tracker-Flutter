import 'package:flutter/material.dart';
import 'package:tracker/models/entity_model.dart';
import 'package:tracker/models/entity_model.dart' as model; // Prefix if conflict

class CollectionAnimationOverlay extends StatefulWidget {
  final model.Collection collection;
  final VoidCallback onAnimationComplete;

  const CollectionAnimationOverlay({
    super.key,
    required this.collection,
    required this.onAnimationComplete,
  });

  @override
  State<CollectionAnimationOverlay> createState() => _CollectionAnimationOverlayState();
}

class _CollectionAnimationOverlayState extends State<CollectionAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);
    
    // Fly towards bottom right (Achievements tab position roughly)
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 3.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward().then((_) => widget.onAnimationComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Align(
              alignment: Alignment.center,
              child: SlideTransition(
                position: _slideAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ]
                        ),
                        child: widget.collection.entityType?.iconUrl != null
                          ? Image.network(
                              widget.collection.entityType!.iconUrl!,
                              width: 80,
                              height: 80,
                            )
                          : const Icon(Icons.star, size: 80, color: Colors.amber),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '+${widget.collection.xpEarned} XP',
                        style: const TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.white)
                          ]
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

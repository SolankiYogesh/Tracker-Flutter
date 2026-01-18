import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:tracker/utils/responsive_utils.dart';

class UserLocationMarker extends StatefulWidget {
  const UserLocationMarker({super.key, this.bearing});
  final double? bearing;

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Circle
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              width: context.w(24) * _pulseAnimation.value,
              height: context.w(24) * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(
                  alpha: 0.3 * (1 - (_pulseAnimation.value - 1) / 1.2),
                ),
              ),
            );
          },
        ),
        // Direction Beam
        if (widget.bearing != null)
          Transform.rotate(
            angle: (widget.bearing! * math.pi / 180),
            child: CustomPaint(
              size: Size(context.w(60), context.w(60)),
              painter: _DirectionBeamPainter(context: context),
            ),
          ),
        // Google Blue Dot
        Container(
          width: context.w(18),
          height: context.w(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: context.w(4),
                offset: Offset(0, context.h(2)),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: context.w(14),
              height: context.w(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectionBeamPainter extends CustomPainter {
  _DirectionBeamPainter({required this.context});
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.blue.withValues(alpha: 0.5),
          Colors.blue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..lineTo(size.width / 2 - context.w(15), size.height / 2 - context.h(35))
      ..relativeArcToPoint(
        Offset(context.w(30), 0),
        radius: Radius.circular(context.w(35)),
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final double rippleSize;
  final Color color;

  CirclePainter({
    required this.center,
    required this.progress,
    required this.rippleSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final radius = rippleSize * (progress >= 1.0 ? 0.5 : progress / 2);

    canvas.drawCircle(
      center,
      radius,
      paint,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return progress != oldDelegate.progress ||
        center != oldDelegate.center ||
        color != oldDelegate.color;
  }
}

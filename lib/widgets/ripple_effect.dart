import 'package:flutter/material.dart';
import '../models/ripple_effect_model.dart';
import '../painters/circle_painter.dart';

class RippleEffectWidget extends StatelessWidget {
  final RippleEffect ripple;
  final double rippleSize;

  const RippleEffectWidget({
    super.key,
    required this.ripple,
    required this.rippleSize,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: ripple.position,
      builder: (context, position, child) {
        return AnimatedBuilder(
          animation: ripple.animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: CirclePainter(
                center: position,
                progress: ripple.animation.value,
                rippleSize: rippleSize,
                color: ripple.color,
              ),
            );
          },
        );
      },
    );
  }
}

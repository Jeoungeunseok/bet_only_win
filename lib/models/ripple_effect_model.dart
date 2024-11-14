import 'package:flutter/material.dart';

class RippleEffect {
  ValueNotifier<Offset> position;
  final AnimationController controller;
  final Animation<double> animation;
  bool isActive;
  bool isAnimating;
  Color color;

  RippleEffect({
    required Offset initialPosition,
    required this.controller,
    required this.animation,
    this.isActive = true,
    this.isAnimating = true,
    this.color = const Color(0x4DFFFFFF),
  }) : position = ValueNotifier<Offset>(initialPosition);

  void updatePosition(Offset newPosition) {
    position.value = newPosition;
  }

  void updateColor(Color newColor) {
    color = newColor;
  }
}

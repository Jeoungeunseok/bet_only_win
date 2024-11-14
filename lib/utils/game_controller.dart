import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ripple_effect_model.dart';

class GameController {
  final Map<int, RippleEffect> activeRipples = {};
  final double rippleSize = 150.0;
  final int maxRipples = 5;
  Timer? selectionTimer;
  bool isSelectionComplete = false;
  final TickerProvider vsync;
  final Function() onStateChanged;

  GameController(this.vsync, this.onStateChanged);

  void startSelectionTimer() {
    if (selectionTimer?.isActive == true || isSelectionComplete) return;

    selectionTimer = Timer(const Duration(seconds: 3), () {
      if (activeRipples.length >= 2) {
        selectRandomRipple();
      }
    });
  }

  void selectRandomRipple() {
    if (activeRipples.isEmpty) return;

    isSelectionComplete = true;

    final random = Random();
    final selectedKey =
        activeRipples.keys.elementAt(random.nextInt(activeRipples.length));

    activeRipples[selectedKey]!.updateColor(const Color(0xFF000000));

    activeRipples.forEach((key, ripple) {
      if (key != selectedKey) {
        ripple.controller.reverse().then((_) {
          ripple.controller.dispose();
        });
      }
    });

    activeRipples.removeWhere((key, _) => key != selectedKey);
    onStateChanged();
  }

  void resetGame() {
    for (var ripple in activeRipples.values) {
      ripple.controller.dispose();
    }
    activeRipples.clear();

    selectionTimer?.cancel();
    selectionTimer = null;

    isSelectionComplete = false;
    onStateChanged();
  }

  void handlePointerDown(PointerDownEvent event, BuildContext context) {
    if (isSelectionComplete) {
      resetGame();
      return;
    }

    if (activeRipples.length >= maxRipples) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);

    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    final ripple = RippleEffect(
      initialPosition: localPosition,
      controller: controller,
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      ),
    );

    activeRipples[event.pointer] = ripple;
    onStateChanged();

    controller.forward().then((_) {
      if (activeRipples.containsKey(event.pointer)) {
        activeRipples[event.pointer]!.isAnimating = false;
        onStateChanged();
      }
    });

    if (activeRipples.length >= 2) {
      startSelectionTimer();
    }
  }

  void handlePointerMove(PointerMoveEvent event, BuildContext context) {
    if (isSelectionComplete || !activeRipples.containsKey(event.pointer))
      return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);

    activeRipples[event.pointer]!.updatePosition(localPosition);
    onStateChanged();
  }

  void handlePointerUp(PointerUpEvent event) {
    if (isSelectionComplete) return;
    if (!activeRipples.containsKey(event.pointer)) return;

    final ripple = activeRipples[event.pointer]!;
    ripple.controller.reverse().then((_) {
      ripple.controller.dispose();
      activeRipples.remove(event.pointer);
      onStateChanged();
    });
  }

  void dispose() {
    selectionTimer?.cancel();
    for (var ripple in activeRipples.values) {
      ripple.controller.dispose();
    }
    activeRipples.clear();
  }
}

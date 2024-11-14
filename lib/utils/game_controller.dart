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
  ValueNotifier<int?> countdown = ValueNotifier<int?>(null);

  // 코너 설정 상태 추가
  bool leftBottomEnabled = false;
  bool rightBottomEnabled = false;
  bool rightTopEnabled = false;
  bool leftTopEnabled = false;

  GameController(this.vsync, this.onStateChanged);

  void startSelectionTimer() {
    if (selectionTimer?.isActive == true || isSelectionComplete) return;

    countdown.value = 3;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value == 1) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 200), () {
          countdown.value = null;
          selectRandomRipple();
        });
      } else {
        countdown.value = countdown.value! - 1;
      }
    });
  }

  void selectRandomRipple() {
    if (activeRipples.isEmpty) return;

    isSelectionComplete = true;

    // 모서리가 아닌 리플들만 필터링
    final nonCornerRipples =
        activeRipples.entries.where((entry) => !entry.value.isCorner).toList();

    if (nonCornerRipples.isEmpty) {
      // 모든 리플이 모서리인 경우 전체 리플 중에서 선택
      final random = Random();
      final selectedKey =
          activeRipples.keys.elementAt(random.nextInt(activeRipples.length));
      activeRipples[selectedKey]!
          .updateColor(const Color.fromARGB(255, 255, 0, 38));
    } else {
      // 모서리가 아닌 리플 중에서 랜덤 선택
      final random = Random();
      final selectedEntry =
          nonCornerRipples[random.nextInt(nonCornerRipples.length)];
      activeRipples[selectedEntry.key]!
          .updateColor(const Color.fromARGB(255, 255, 0, 38));
    }

    // 선택되지 않은 리플 제거
    activeRipples.forEach((key, ripple) {
      if (ripple.color != const Color.fromARGB(255, 255, 0, 38)) {
        ripple.controller.reverse().then((_) {
          ripple.controller.dispose();
        });
      }
    });

    activeRipples.removeWhere(
        (key, ripple) => ripple.color != const Color.fromARGB(255, 255, 0, 38));
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
    countdown.value = null;
    onStateChanged();
  }

  void handlePointerDown(PointerDownEvent event, BuildContext context) {
    if (isSelectionComplete) {
      resetGame();
      return;
    }

    if (activeRipples.length >= maxRipples) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size screenSize = renderBox.size;
    final localPosition = renderBox.globalToLocal(event.position);

    // 각 모서리 영역 확인
    bool isLeftBottom =
        localPosition.dx <= 50 && localPosition.dy >= (screenSize.height - 50);
    bool isRightBottom = localPosition.dx >= (screenSize.width - 50) &&
        localPosition.dy >= (screenSize.height - 50);
    bool isRightTop = localPosition.dx >= (screenSize.width - 50) &&
        localPosition.dy >= 50 &&
        localPosition.dy <= 100;
    bool isLeftTop = localPosition.dx <= 50 &&
        localPosition.dy >= 50 &&
        localPosition.dy <= 100;

    // 활성화된 모서리만 디버그 출력
    if (isLeftBottom && leftBottomEnabled) {
      print('왼쪽 하단 모서리가 터치되었습니다!');
    }
    if (isRightBottom && rightBottomEnabled) {
      print('오른쪽 하단 모서리가 터치되었습니다!');
    }
    if (isRightTop && rightTopEnabled) {
      print('오른쪽 상단 모서리가 터치되었습니다!');
    }
    if (isLeftTop && leftTopEnabled) {
      print('왼쪽 상단 모서리가 터치되었습니다!');
    }

    final controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 300),
    );

    bool isCorner = false;
    // 활성화된 모서리 확인
    if ((isLeftBottom && leftBottomEnabled) ||
        (isRightBottom && rightBottomEnabled) ||
        (isRightTop && rightTopEnabled) ||
        (isLeftTop && leftTopEnabled)) {
      isCorner = true;
      print('모서리에서 시작된 리플입니다!');
    }

    final ripple = RippleEffect(
      initialPosition: localPosition,
      controller: controller,
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      ),
      isCorner: isCorner,
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

      if (activeRipples.length < 2) {
        countdown.value = null;
        selectionTimer?.cancel();
        selectionTimer = null;
      }

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

  // 코너 설정을 업데이트하는 메서드
  void updateCornerSettings({
    required bool leftBottom,
    required bool rightBottom,
    required bool rightTop,
    required bool leftTop,
  }) {
    leftBottomEnabled = leftBottom;
    rightBottomEnabled = rightBottom;
    rightTopEnabled = rightTop;
    leftTopEnabled = leftTop;
  }
}

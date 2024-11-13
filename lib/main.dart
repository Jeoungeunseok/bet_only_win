import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betcha',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF98E4D8),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Betcha'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<int, RippleEffect> activeRipples = {};
  final double _rippleSize = 150.0;
  final int maxRipples = 5;
  Timer? _selectionTimer;
  bool isSelectionComplete = false;

  void startSelectionTimer() {
    if (_selectionTimer?.isActive == true || isSelectionComplete) return;

    _selectionTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && activeRipples.length >= 2) {
        selectRandomRipple();
      }
    });
  }

  void selectRandomRipple() {
    if (activeRipples.isEmpty) return;

    setState(() {
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
    });
  }

  void resetGame() {
    setState(() {
      // 모든 리플 제거
      for (var ripple in activeRipples.values) {
        ripple.controller.dispose();
      }
      activeRipples.clear();

      // 타이머 취소
      _selectionTimer?.cancel();
      _selectionTimer = null;

      // 선택 완료 상태 초기화
      isSelectionComplete = false;
    });
  }

  void onPointerDown(PointerDownEvent event) {
    // 선택 완료 상태에서 터치하면 게임 리셋
    if (isSelectionComplete) {
      resetGame();
      return;
    }

    if (activeRipples.length >= maxRipples) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final ripple = RippleEffect(
      initialPosition: localPosition,
      controller: controller,
      animation: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      ),
    );

    setState(() {
      activeRipples[event.pointer] = ripple;
    });

    controller.forward().then((_) {
      if (mounted && activeRipples.containsKey(event.pointer)) {
        setState(() {
          activeRipples[event.pointer]!.isAnimating = false;
        });
      }
    });

    if (activeRipples.length >= 2) {
      startSelectionTimer();
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (isSelectionComplete || !activeRipples.containsKey(event.pointer))
      return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);

    setState(() {
      activeRipples[event.pointer]!.updatePosition(localPosition);
    });
  }

  void onPointerUp(PointerUpEvent event) {
    if (isSelectionComplete) return;
    if (!activeRipples.containsKey(event.pointer)) return;

    final ripple = activeRipples[event.pointer]!;
    ripple.controller.reverse().then((_) {
      if (mounted) {
        setState(() {
          ripple.controller.dispose();
          activeRipples.remove(event.pointer);
        });
      }
    });
  }

  @override
  void dispose() {
    _selectionTimer?.cancel();
    for (var ripple in activeRipples.values) {
      ripple.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF98E4D8),
      body: Listener(
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isSelectionComplete
                          ? 'Touch to restart!'
                          : 'Betting Start!',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ...activeRipples.values.map(
                (ripple) => ValueListenableBuilder<Offset>(
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
                            rippleSize: _rippleSize,
                            color: ripple.color,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 25,
        height: 25,
        child: FloatingActionButton(
          onPressed: () async {
            final packageInfo = await PackageInfo.fromPlatform();

            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return FractionallySizedBox(
                  heightFactor: 0.9,
                  widthFactor: 1.0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF3C3C3E),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '설정',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  '완료',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF0A84FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          '앱 정보',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2E),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '버전 ${packageInfo.version}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            );
          },
          backgroundColor: Colors.white,
          elevation: 2,
          shape: const CircleBorder(),
          child: Container(),
        ),
      ),
    );
  }
}

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

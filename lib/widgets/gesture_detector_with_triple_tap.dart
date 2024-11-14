import 'package:flutter/material.dart';
import 'dart:async';

class GestureDetectorWithTripleTap extends StatefulWidget {
  final VoidCallback onTripleTap;
  final Widget child;

  const GestureDetectorWithTripleTap({
    super.key,
    required this.onTripleTap,
    required this.child,
  });

  @override
  State<GestureDetectorWithTripleTap> createState() =>
      _GestureDetectorWithTripleTapState();
}

class _GestureDetectorWithTripleTapState
    extends State<GestureDetectorWithTripleTap> {
  int _tapCount = 0;
  Timer? _timer;

  void _handleTap() {
    _tapCount++;
    _timer?.cancel();

    if (_tapCount == 3) {
      widget.onTripleTap();
      _tapCount = 0;
    } else {
      _timer = Timer(const Duration(milliseconds: 500), () {
        _tapCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

class ProperShake extends StatefulWidget {
  final Widget child;
  final int trigger; // Increments to start a shake
  final double intensity; // How violent the shake is

  const ProperShake(
      {super.key,
      required this.child,
      required this.trigger,
      this.intensity = 8.0});

  @override
  State<ProperShake> createState() => _ProperShakeState();
}

class _ProperShakeState extends State<ProperShake>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(ProperShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Whenever the trigger count increases, restart the shake
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _getOffset(double animationValue) {
    if (animationValue == 0 || animationValue == 1) return 0;

    // Damping: Shake is violent at start, calm at end
    double damping = 1.0 - animationValue;

    // Random movement within the intensity range
    return (_random.nextDouble() * 2.0 - 1.0) * widget.intensity * damping;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset:
          Offset(_getOffset(_controller.value), _getOffset(_controller.value)),
      child: widget.child,
    );
  }
}

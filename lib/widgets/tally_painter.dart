import 'package:flutter/material.dart';

class TallyPainter extends CustomPainter {
  final int count; // How many lines to draw (1 to 5)
  final Color color; // Blue for P1, Red for P2

  TallyPainter({required this.count, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // We make the lines slightly thicker or thinner based on the box size
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    // Define the boundaries of the tally box
    double spacing = size.width / 5;
    double top = size.height * 0.15;
    double bottom = size.height * 0.85;

    // 1. Draw the vertical lines (up to 4)
    for (int i = 0; i < (count > 4 ? 4 : count); i++) {
      double x = (i + 1) * spacing;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }

    // 2. Draw the diagonal "crash out" line ONLY if the count is 5
    if (count >= 5) {
      canvas.drawLine(
        Offset(spacing * 0.2, bottom - (size.height * 0.05)),
        Offset(spacing * 4.8, top + (size.height * 0.05)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(TallyPainter old) =>
      old.count != count || old.color != color;
}

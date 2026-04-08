import 'package:flutter/material.dart';
import '../models/sos_line.dart';
import '../models/player.dart';
import '../core/constants.dart';

class SOSPainter extends CustomPainter {
  final List<SOSLine> lines;
  final int gridSize;

  SOSPainter({required this.lines, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / gridSize;
    for (var line in lines) {
      final Paint paint = Paint()
        ..color = (line.owner == PlayerID.player1
                ? AppConstants.player1Color
                : AppConstants.player2Color)
            .withOpacity(0.8)
        ..strokeWidth = gridSize > 20 ? 1.0 : 2.5
        ..strokeCap = StrokeCap.round;

      int sIdx = line.indices.first;
      double sx = (sIdx % gridSize) * cellSize + (cellSize / 2);
      double sy = (sIdx ~/ gridSize) * cellSize + (cellSize / 2);

      int eIdx = line.indices.last;
      double ex = (eIdx % gridSize) * cellSize + (cellSize / 2);
      double ey = (eIdx ~/ gridSize) * cellSize + (cellSize / 2);

      canvas.drawLine(Offset(sx, sy), Offset(ex, ey), paint);
    }
  }

  @override
  bool shouldRepaint(SOSPainter old) => true;
}

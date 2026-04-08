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
        ..strokeWidth =
            gridSize > 20 ? 1.5 : 3.0 // Thinner lines for larger grids
        ..strokeCap = StrokeCap.round;

      // Get Start Cell Center
      int startIdx = line.indices.first;
      double startX = (startIdx % gridSize) * cellSize + (cellSize / 2);
      double startY = (startIdx ~/ gridSize) * cellSize + (cellSize / 2);

      // Get End Cell Center
      int endIdx = line.indices.last;
      double endX = (endIdx % gridSize) * cellSize + (cellSize / 2);
      double endY = (endIdx ~/ gridSize) * cellSize + (cellSize / 2);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SOSPainter oldDelegate) => true;
}

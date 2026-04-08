import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'grid_cell.dart';
import 'sos_painter.dart';

class GameBoard extends StatelessWidget {
  final int gridSize;
  const GameBoard({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    return LayoutBuilder(builder: (context, constraints) {
      double side = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight;
      return Center(
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 0.5)),
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Stack(
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    crossAxisSpacing: 0.2,
                    mainAxisSpacing: 0.2,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) => GridCell(index: index),
                ),
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(side, side),
                    painter:
                        SOSPainter(lines: game.sosLines, gridSize: gridSize),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

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

    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSide = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return Center(
          child: Container(
            width: boardSide,
            height: boardSide,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.white.withOpacity(1), width: 1), // Outer border
            ),
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Stack(
                // Use Stack to layer lines over the grid
                children: [
                  // Layer 1: The Grid Cells
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: gridSize > 20 ? 0.2 : 1.0,
                      mainAxisSpacing: gridSize > 20 ? 0.2 : 1.0,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) => GridCell(index: index),
                  ),

                  // Layer 2: The Strikethrough Lines
                  IgnorePointer(
                    // Lines shouldn't block taps
                    child: CustomPaint(
                      size: Size(boardSide, boardSide),
                      painter: SOSPainter(
                        lines: game.sosLines,
                        gridSize: gridSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

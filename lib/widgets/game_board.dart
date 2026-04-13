import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'grid_cell.dart';
import 'sos_painter.dart';
import 'proper_shake.dart'; // REQUIRED IMPORT

class GameBoard extends StatelessWidget {
  final int gridSize;
  const GameBoard({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    // Check if input is currently blocked
    bool isInputBlocked = game.isAiThinking ||
        game.isAnimating ||
        (game.isVsAI && game.currentPlayer.id != PlayerID.player1);

    return LayoutBuilder(builder: (context, constraints) {
      double side = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight;

      return Center(
        // --- NEW PROPER SHAKE ENGINE ---
        child: ProperShake(
          trigger: game.shakeTrigger,
          intensity: 10.0, // Higher value = more violent
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                  color: game.isAiThinking
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.5),
                  width: game.isAiThinking ? 2.0 : 0.5),
              boxShadow: game.isAiThinking
                  ? [
                      BoxShadow(
                          color: Colors.redAccent.withOpacity(0.3),
                          blurRadius: 20)
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      // The Grid
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
                      // The Lines
                      IgnorePointer(
                        child: CustomPaint(
                          size: Size(side, side),
                          painter: SOSPainter(
                              lines: game.sosLines, gridSize: gridSize),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tap Blocker
                if (isInputBlocked)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'grid_cell.dart';
import 'sos_painter.dart';

class GameBoard extends StatelessWidget {
  final int gridSize;
  const GameBoard({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    bool isInputBlocked = game.isAiThinking ||
        game.isAnimating ||
        (game.isVsAI && game.currentPlayer.id != PlayerID.player1);

    return LayoutBuilder(builder: (context, constraints) {
      double side = constraints.maxWidth < constraints.maxHeight
          ? constraints.maxWidth
          : constraints.maxHeight;

      return Center(
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: Colors.black,
            // Subtle White Border normally, Glowing Red when AI is moving
            border: Border.all(
                color: game.isAiThinking
                    ? Colors.red
                    : Colors.white.withOpacity(0.5),
                width: game.isAiThinking ? 2.0 : 0.5),
            boxShadow: game.isAiThinking
                ? [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: Stack(
            children: [
              // THE ACTUAL GRID (Always 1.0 Opacity now)
              InteractiveViewer(
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
                        painter: SOSPainter(
                            lines: game.sosLines, gridSize: gridSize),
                      ),
                    ),
                  ],
                ),
              ),

              // THE INVISIBLE BLOCKER (Prevents human from interfering)
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
      );
    });
  }
}

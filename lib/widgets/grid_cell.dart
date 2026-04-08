import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/cell_model.dart';
import '../models/player.dart';

class GridCell extends StatelessWidget {
  final int index;
  const GridCell({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Select specific data to optimize performance (only rebuilds when these specific values change)
    final cell = context.select((GameProvider p) => p.grid[index]);
    final isLastMove =
        context.select((GameProvider p) => p.lastMoveIndex == index);

    // 1. Build the visual container
    Widget content = Container(
      decoration: BoxDecoration(
        // Last move gets a slightly lighter background to highlight it
        color: isLastMove
            ? Colors.white.withOpacity(0.15)
            : (cell.isRevealed && cell.specialType != SpecialType.none
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFF151515)),

        border: Border.all(
          // Last move gets a thicker white border, SOS gets yellow, others get 0.5 white
          color: cell.isPartOfSOS
              ? Colors.yellow
              : (isLastMove ? Colors.white : Colors.white.withOpacity(0.3)),
          width: isLastMove ? 1.0 : 0.5,
        ),

        // Add a neon glow to the last move based on the player's color
        boxShadow: isLastMove
            ? [
                BoxShadow(
                  color: (cell.placedBy == PlayerID.player1
                          ? Colors.blue
                          : Colors.red)
                      .withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Center(
        child: cell.letter.isEmpty
            ? null
            : FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    cell.letter,
                    style: TextStyle(
                      fontWeight:
                          isLastMove ? FontWeight.w900 : FontWeight.bold,
                      color: cell.placedBy == PlayerID.player1
                          ? Colors.blue
                          : Colors.red,
                    ),
                  ),
                ),
              ),
      ),
    );

    // 2. Add Animations if it's the last move
    if (isLastMove) {
      content = content
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(duration: 1500.ms, color: Colors.white10)
          .boxShadow(
              begin: const BoxShadow(blurRadius: 2),
              end: const BoxShadow(blurRadius: 10));
    }

    // 3. CRITICAL: Wrap in GestureDetector to allow selection
    return GestureDetector(
      // behavior: HitTestBehavior.opaque allows tapping on the empty area of the cell
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Trigger the move logic in the Provider
        context.read<GameProvider>().playMove(index);
      },
      child: content,
    );
  }
}

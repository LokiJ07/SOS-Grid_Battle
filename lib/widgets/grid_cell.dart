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
    final cell = context.select((GameProvider p) => p.grid[index]);
    final isLastMove =
        context.select((GameProvider p) => p.lastMoveIndex == index);

    // Prepare hint icon for revealed, empty, special cells
    Widget? hintIcon;
    if (cell.isRevealed &&
        cell.letter.isEmpty &&
        cell.specialType != SpecialType.none) {
      hintIcon = Opacity(
        opacity: 0.4,
        child: Icon(
          // Different icons for Mines vs Perks
          cell.specialType == SpecialType.mine
              ? Icons.warning_amber_rounded
              : Icons.radar_rounded,
          size: 12,
          color: cell.specialType == SpecialType.mine
              ? Colors.redAccent
              : Colors.greenAccent,
        ),
      );
    }

    Widget content = Container(
      decoration: BoxDecoration(
        color: isLastMove
            ? Colors.white.withOpacity(0.15)
            : (cell.isRevealed
                ? Colors.white.withOpacity(0.05)
                : const Color(0xFF151515)),
        border: Border.all(
          color: cell.isPartOfSOS
              ? Colors.yellow
              : (isLastMove ? Colors.white : Colors.white.withOpacity(0.2)),
          width: isLastMove ? 1.0 : 0.5,
        ),
        boxShadow: isLastMove
            ? [
                BoxShadow(
                  color: (cell.placedBy == PlayerID.player1
                          ? Colors.blue
                          : Colors.red)
                      .withOpacity(0.4),
                  blurRadius: 8,
                )
              ]
            : [],
      ),
      child: Center(
        // Show Letter or the Hint Icon
        child: cell.letter.isEmpty
            ? hintIcon
            : FittedBox(
                child: Text(
                  cell.letter,
                  style: TextStyle(
                    fontWeight: isLastMove ? FontWeight.w900 : FontWeight.bold,
                    color: cell.placedBy == PlayerID.player1
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ),
      ),
    );

    // Pulsing Animation for the last move
    if (isLastMove) {
      content = content
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1500.ms)
          .boxShadow(
              begin: const BoxShadow(blurRadius: 2),
              end: const BoxShadow(blurRadius: 10));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.read<GameProvider>().playMove(index);
      },
      child: content,
    );
  }
}

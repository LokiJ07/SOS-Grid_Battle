import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../core/constants.dart';

class GridCell extends StatelessWidget {
  final int index;
  const GridCell({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // We use select to only rebuild this cell when its specific data changes
    final cell = context.select((GameProvider p) => p.grid[index]);

    return GestureDetector(
      onTap: () => context.read<GameProvider>().playMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: cell.isPartOfSOS
              ? [
                  BoxShadow(
                      color: AppConstants.highlightColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1)
                ]
              : [],
          border: cell.isPartOfSOS
              ? Border.all(color: AppConstants.highlightColor, width: 1)
              : null,
        ),
        child: Center(
          child: cell.letter.isEmpty
              ? null
              : Text(
                  cell.letter,
                  style: TextStyle(
                    color: cell.placedBy == PlayerID.player1
                        ? AppConstants.player1Color
                        : AppConstants.player2Color,
                    fontWeight: FontWeight.bold,
                    fontSize: _getFontSize(context),
                  ),
                ).animate().scale(duration: 200.ms).fadeIn(),
        ),
      ),
    );
  }

  double _getFontSize(BuildContext context) {
    int size = context.read<GameProvider>().gridSize;
    if (size <= 3) return 40;
    if (size <= 16) return 14;
    return 8;
  }
}

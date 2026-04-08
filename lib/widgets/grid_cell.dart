import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/cell_model.dart';
import '../models/player.dart';

class GridCell extends StatelessWidget {
  final int index;
  const GridCell({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final cell = context.select((GameProvider p) => p.grid[index]);

    return GestureDetector(
      onTap: () => context.read<GameProvider>().playMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: cell.isRevealed && cell.specialType != SpecialType.none
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF151515),
          // SHARP WHITE BORDER
          border: Border.all(
            color: cell.isPartOfSOS
                ? Colors.yellow
                : Colors.white.withOpacity(0.5),
            width: 0.5,
          ),
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
                        fontWeight: FontWeight.bold,
                        color: cell.placedBy == PlayerID.player1
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

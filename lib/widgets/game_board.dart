import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'grid_cell.dart';

class GameBoard extends StatelessWidget {
  final int gridSize;
  const GameBoard({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: gridSize > 20 ? 1 : 2,
              mainAxisSpacing: gridSize > 20 ? 1 : 2,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              return GridCell(index: index);
            },
          ),
        );
      },
    );
  }
}

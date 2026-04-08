import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/letter_selector.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isGameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ResultScreen()));
          });
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const ScoreBoard(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GameBoard(gridSize: game.gridSize),
                    ),
                  ),
                ),
                const LetterSelector(),
              ],
            ),
          ),
        );
      },
    );
  }
}

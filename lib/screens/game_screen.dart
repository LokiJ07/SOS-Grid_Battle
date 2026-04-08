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
    final game = context.watch<GameProvider>();
    if (game.isGameOver) {
      Future.microtask(() => Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ResultScreen())));
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScoreBoard(),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GameBoard(gridSize: game.gridSize))),
            const LetterSelector(),
          ],
        ),
      ),
    );
  }
}

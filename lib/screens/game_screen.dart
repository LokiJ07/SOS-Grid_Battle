import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/letter_selector.dart';
import '../widgets/battle_notification.dart'; // Import the new widget
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        if (game.isGameOver) {
          Future.microtask(() => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const ResultScreen())));
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              // Stack allows the notification to float
              children: [
                // Layer 1: Game UI
                Column(
                  children: [
                    const ScoreBoard(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: GameBoard(gridSize: game.gridSize),
                      ),
                    ),
                    const LetterSelector(),
                  ],
                ),

                // Layer 2: Floating Notification (Always on top)
                const BattleNotification(),
              ],
            ),
          ),
        );
      },
    );
  }
}

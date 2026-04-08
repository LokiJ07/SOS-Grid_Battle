import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';
import 'main_menu_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();

    String winMessage;
    String winReason;
    Color winnerColor;

    if (game.player1.lives <= 0) {
      winMessage = "PLAYER 2 WINS!";
      winReason = "Player 1 ran out of lives";
      winnerColor = AppConstants.player2Color;
    } else if (game.player2.lives <= 0) {
      winMessage = "PLAYER 1 WINS!";
      winReason = "Player 2 ran out of lives";
      winnerColor = AppConstants.player1Color;
    } else if (game.player1.score > game.player2.score) {
      winMessage = "PLAYER 1 WINS!";
      winReason = "Higher Score";
      winnerColor = AppConstants.player1Color;
    } else if (game.player2.score > game.player1.score) {
      winMessage = "PLAYER 2 WINS!";
      winReason = "Higher Score";
      winnerColor = AppConstants.player2Color;
    } else {
      winMessage = "IT'S A DRAW!";
      winReason = "Equal scores";
      winnerColor = Colors.white;
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Victory Icon
              Icon(Icons.emoji_events, size: 100, color: winnerColor)
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shake(duration: 500.ms),

              const SizedBox(height: 20),

              Text(
                winMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.normal,
                  color: winnerColor,
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),

              Text(
                winReason,
                style: const TextStyle(fontSize: 18, color: Colors.white54),
              ),

              const SizedBox(height: 40),

              // Score Display Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFinalScore("P1 Score", game.player1.score,
                        AppConstants.player1Color),
                    const VerticalDivider(color: Colors.white24, thickness: 1),
                    _buildFinalScore("P2 Score", game.player2.score,
                        AppConstants.player2Color),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 50),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: winnerColor == Colors.white
                        ? AppConstants.player1Color
                        : winnerColor,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: () {
                    // Re-init the game with the same settings
                    game.initGame(game.gridSize, game.timerLimit);
                    Navigator.pop(context);
                  },
                  child: const Text("PLAY AGAIN",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ).animate().slideX(begin: -0.2, delay: 600.ms).fadeIn(),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "BACK TO MAIN MENU",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(
          score.toString(),
          style: const TextStyle(
              fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}

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
    // We watch the provider to get the end-game state
    final game = context.read<GameProvider>();

    // 1. Determine Winner and Reason Logic
    String winTitle;
    String winReason;
    Color winnerColor;
    IconData resultIcon;

    if (game.player1.lives <= 0) {
      winTitle = "${game.player2.name.toUpperCase()} WINS!";
      winReason = "${game.player1.name} WAS ELIMINATED";
      winnerColor = AppConstants.player2Color;
      resultIcon = Icons.dangerous_rounded; // More compatible than skull
    } else if (game.player2.lives <= 0) {
      winTitle = "${game.player1.name.toUpperCase()} WINS!";
      winReason = "${game.player2.name} WAS ELIMINATED";
      winnerColor = AppConstants.player1Color;
      resultIcon = Icons.emoji_events_rounded;
    } else if (game.player1.score > game.player2.score) {
      winTitle = "PLAYER 1 VICTORIOUS!";
      winReason = "HIGHER TALLY SCORE";
      winnerColor = AppConstants.player1Color;
      resultIcon = Icons.military_tech_rounded;
    } else if (game.player2.score > game.player1.score) {
      winTitle = "${game.player2.name.toUpperCase()} WINS!";
      winReason = "HIGHER TALLY SCORE";
      winnerColor = AppConstants.player2Color;
      resultIcon = Icons.smart_toy_rounded;
    } else {
      winTitle = "STALEMATE!";
      winReason = "THE GRID IS AT PEACE";
      winnerColor = Colors.white70;
      resultIcon = Icons.balance_rounded;
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Background ambient glow animation
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: winnerColor.withOpacity(0.05),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.3, 1.3),
                duration: 3.seconds),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Animation
                  Icon(resultIcon, size: 100, color: winnerColor)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .then()
                      .shake(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Title and Win Reason
                  Text(
                    winTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900, // Corrected from .black
                      color: winnerColor,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

                  Text(
                    winReason,
                    style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 50),

                  // Score summary card with 0.5 white border
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFinalStat(
                            "P1 SCORE",
                            game.player1.score.toString(),
                            AppConstants.player1Color),
                        Container(width: 1, height: 40, color: Colors.white10),
                        _buildFinalStat(
                            "P2 SCORE",
                            game.player2.score.toString(),
                            AppConstants.player2Color),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

                  const SizedBox(height: 60),

                  // Action Button: Instant Rematch
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: winnerColor == Colors.white70
                            ? Colors.blueAccent
                            : winnerColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        // RE-INITIALIZE match using the same settings from the previous game
                        game.initGame(game.gridSize, game.timerLimit,
                            vsAI: game.isVsAI,
                            diff: game.aiDifficulty,
                            mode: game
                                .currentGameMode // Fixed: Ensure this exists in Provider
                            );
                        Navigator.pop(context);
                      },
                      child: const Text("INSTANT REMATCH",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 15),

                  // Return Button
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainMenuScreen()),
                          (route) => false);
                    },
                    child: const Text(
                      "EXIT TO MAIN MENU",
                      style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1),
                    ),
                  ).animate().fadeIn(delay: 900.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
      ],
    );
  }
}

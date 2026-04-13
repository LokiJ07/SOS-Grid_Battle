import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';
import '../widgets/menu_button.dart';
import 'main_menu_screen.dart';
import 'match_history_screen.dart'; // Ensure this file exists

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the game state without listening for continuous changes
    final game = context.read<GameProvider>();

    // 1. Determine Winner and Reason logic
    String winTitle;
    String winReason;
    Color winColor;
    IconData winIcon;

    if (game.player1.lives <= 0) {
      winTitle = "${game.player2.name.toUpperCase()} WINS!";
      winReason = "${game.player1.name} WAS ELIMINATED";
      winColor = AppConstants.player2Color;
      winIcon = Icons.dangerous_rounded;
    } else if (game.player2.lives <= 0) {
      winTitle = "${game.player1.name.toUpperCase()} WINS!";
      winReason = "${game.player2.name} WAS ELIMINATED";
      winColor = AppConstants.player1Color;
      winIcon = Icons.emoji_events_rounded;
    } else if (game.player1.score > game.player2.score) {
      winTitle = "VICTORY!";
      winReason = "HIGHER TALLY SCORE";
      winColor = AppConstants.player1Color;
      winIcon = Icons.military_tech_rounded;
    } else if (game.player2.score > game.player1.score) {
      winTitle = "${game.player2.name.toUpperCase()} WINS!";
      winReason = "HIGHER TALLY SCORE";
      winColor = AppConstants.player2Color;
      winIcon = Icons.smart_toy_rounded;
    } else {
      winTitle = "STALEMATE!";
      winReason = "THE GRID IS AT PEACE";
      winColor = Colors.white70;
      winIcon = Icons.balance_rounded;
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
                  shape: BoxShape.circle, color: winColor.withOpacity(0.05)),
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
                  // Icon with elastic animation
                  Icon(winIcon, size: 100, color: winColor)
                      .animate()
                      .scale(curve: Curves.elasticOut, duration: 600.ms),

                  const SizedBox(height: 20),

                  Text(
                    winTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900, // Corrected to w900
                        color: winColor,
                        letterSpacing: 2),
                  ).animate().fadeIn(),

                  Text(
                    winReason,
                    style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2),
                  ),

                  const SizedBox(height: 50),

                  // Score summary card with 0.5 white border
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 0.5)),
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
                  ).animate().slideY(begin: 0.2, duration: 400.ms),

                  const SizedBox(height: 50),

                  // Button 1: Instant Rematch
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: winColor == Colors.white70
                              ? Colors.blueAccent
                              : winColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        // RE-START Match with same settings
                        game.initGame(game.gridSize, game.timerLimit,
                            vsAI: game.isVsAI,
                            diff: game.aiDifficulty,
                            mode: game.currentGameMode // Corrected variable
                            );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "INSTANT REMATCH",
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Button 2: Review History (Replay)
                  MenuButton(
                    label: 'REVIEW THIS MATCH',
                    icon: Icons.history_edu_rounded,
                    isSecondary: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MatchHistoryScreen(
                            history: game.matchHistory, // Pass move list
                            gridSize: game.gridSize, // Pass board size
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // Button 3: Exit
                  TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainMenuScreen()),
                        (route) => false),
                    child: const Text(
                      "EXIT TO MAIN MENU",
                      style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1),
                    ),
                  ),
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

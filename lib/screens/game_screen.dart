import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/letter_selector.dart';
import '../widgets/battle_notification.dart';
import '../core/constants.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // --- 1. GAME OVER NAVIGATION ---
        if (game.isGameOver) {
          Future.microtask(() {
            if (Navigator.canPop(context)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ResultScreen()),
              );
            }
          });
        }

        // Determine the ambient color based on the current player's turn
        Color turnColor = game.currentPlayer.color.withOpacity(0.05);

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Stack(
            children: [
              // --- 2. AMBIENT TURN GLOW ---
              // This background pulses subtly in the color of the active player
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [turnColor, Colors.transparent],
                    center: Alignment.center,
                    radius: 1.5,
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    // --- 3. TOP SECTION: SCORES ---
                    const ScoreBoard()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.1, end: 0),

                    // --- 4. CENTER SECTION: THE BATTLE GRID ---
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10),
                        child: Center(
                          child: GameBoard(gridSize: game.gridSize),
                        ),
                      ),
                    ).animate().scale(
                        delay: 200.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutBack),

                    // --- 5. BOTTOM SECTION: CONTROL DECK ---
                    _buildControlDeck(context),
                  ],
                ),
              ),

              // --- 6. OVERLAY: BATTLE NOTIFICATIONS ---
              const BattleNotification(),
            ],
          ),
        );
      },
    );
  }

  /// Builds a professional 'Control Deck' at the bottom for letter selection
  Widget _buildControlDeck(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        // Sharp professional 0.5 white border
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tactical Handle
          Container(
            width: 30,
            height: 3,
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const LetterSelector(),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn();
  }
}

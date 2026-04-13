import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/letter_selector.dart';
import '../widgets/battle_notification.dart';
import '../widgets/skill_modal.dart';
import '../models/player.dart';
import '../models/cell_model.dart';
import '../core/constants.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // --- 1. SAFE NAVIGATION: GAME OVER ---
        if (game.isGameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.canPop(context)) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ResultScreen()),
              );
            }
          });
        }

        // --- 2. DYNAMIC AMBIENT COLOR ---
        // Glow matches the color of whoever's turn it is
        Color turnColor = game.currentPlayer.color.withOpacity(0.08);

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Stack(
            children: [
              // --- LAYER 1: AMBIENT GLOW ---
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [turnColor, Colors.transparent],
                    center: Alignment.center,
                    radius: 1.2,
                  ),
                ),
              ),

              // --- LAYER 2: MAIN INTERFACE ---
              SafeArea(
                child: Column(
                  children: [
                    // Score & Status Section
                    const ScoreBoard()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.1, end: 0),

                    // Central Battle Grid
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: Center(
                          child: GameBoard(gridSize: game.gridSize),
                        ),
                      ),
                    ).animate().scale(
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.easeOutBack),

                    // Input & Skills Control Deck
                    _buildControlDeck(context, game),
                  ],
                ),
              ),

              // --- LAYER 3: BATTLE NOTIFICATIONS ---
              // Floating overlay for mines/perks (Always on top)
              const BattleNotification(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the bottom 'Tactical Hub' containing Skills and Letter Selection
  Widget _buildControlDeck(BuildContext context, GameProvider game) {
    // Inventory check: Does the current player have the scanning skill?
    bool hasScanSkill =
        game.currentPlayer.inventory.contains(EffectType.revealRadius);

    // Turn check: Is it actually a human player's turn to act?
    bool isHumanTurn =
        !game.isVsAI || game.currentPlayer.id == PlayerID.player1;

    // Visibility Check: Block button if AI is moving or an animation is playing
    bool canUseSkills =
        hasScanSkill && isHumanTurn && !game.isAiThinking && !game.isAnimating;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
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
          // Tactical Drag Handle
          Container(
            width: 35,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // --- TACTICAL INTEL BUTTON ---
          if (canUseSkills)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => SkillModal(
                      onSelect: (type) => game.useScanSkill(type),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purpleAccent, width: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: -2,
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_alt_rounded,
                          color: Colors.purpleAccent, size: 20),
                      SizedBox(width: 12),
                      Text(
                        "ACTIVATE TACTICAL INTEL",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900, // Valid code
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ),

          // Letter Selector Buttons
          const LetterSelector(),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 400.ms).fadeIn();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/letter_selector.dart';
import '../widgets/battle_notification.dart';
import '../widgets/skill_modal.dart'; // REQUIRED IMPORT
import '../models/player.dart'; // REQUIRED IMPORT
import '../models/cell_model.dart'; // REQUIRED IMPORT
import '../core/constants.dart';
import 'result_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // --- Navigation: Game Over ---
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

        // Ambient turn glow color
        Color turnColor = game.currentPlayer.color.withOpacity(0.05);

        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          body: Stack(
            children: [
              // Layer 1: Ambient Background
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

              // Layer 2: Main UI
              SafeArea(
                child: Column(
                  children: [
                    const ScoreBoard().animate().fadeIn().slideY(begin: -0.1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 10),
                        child: GameBoard(gridSize: game.gridSize),
                      ),
                    ).animate().scale(
                        delay: 200.ms,
                        duration: 500.ms,
                        curve: Curves.easeOutBack),
                    _buildControlDeck(context, game),
                  ],
                ),
              ),

              // Layer 3: Overlay Notifications
              const BattleNotification(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlDeck(BuildContext context, GameProvider game) {
    // Correct variable naming
    bool hasScanSkill =
        game.currentPlayer.inventory.contains(EffectType.revealRadius);
    bool isMyTurn = !game.isVsAI || game.currentPlayer.id == PlayerID.player1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.5),
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
                color: Colors.white10, borderRadius: BorderRadius.circular(10)),
          ),

          // Skill Button
          if (hasScanSkill &&
              isMyTurn &&
              !game.isAiThinking &&
              !game.isAnimating)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => SkillModal(
                      onSelect: (type) => game.useScanSkill(type),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purpleAccent, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.psychology_alt_rounded,
                          color: Colors.purpleAccent, size: 18),
                      SizedBox(width: 10),
                      Text(
                        "ACTIVATE TACTICAL INTEL",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
            ),

          const LetterSelector(),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'difficulty_selection_screen.dart';
import 'timer_selection_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  final int gridSize;
  final bool isVsAI;

  const ModeSelectionScreen(
      {super.key, required this.gridSize, required this.isVsAI});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SELECT GAME STYLE",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Text
              const Text(
                "HOW DO YOU WANT TO BATTLE?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 40),

              // Mode 1: Classic
              _buildModeCard(
                context,
                title: "CLASSIC SOS",
                description:
                    "The pure strategy paper game. No traps, no perks, just skill.",
                icon: Icons.auto_stories_rounded,
                mode: GameMode.classic,
                accentColor: Colors.blueAccent,
                index: 0,
              ),

              const SizedBox(height: 20),

              // Mode 2: Battle
              _buildModeCard(
                context,
                title: "BATTLE MODE",
                description:
                    "Explosive SOS! Includes hidden Mines, Stuns, and Perk items.",
                icon: Icons.rocket_launch_rounded,
                mode: GameMode.battle,
                accentColor: Colors.orangeAccent,
                index: 1,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required GameMode mode,
    required Color accentColor,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        if (isVsAI) {
          // If playing against AI, choose difficulty next
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DifficultySelectionScreen(
                gridSize: gridSize,
                gameMode: mode,
              ),
            ),
          );
        } else {
          // If playing Local PvP, go straight to Timer Selection
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TimerSelectionScreen(
                gridSize: gridSize,
                isVsAI: false,
                gameMode: mode,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          // PROFESSIONAL: 0.5 white border as requested
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon with soft glow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            const SizedBox(width: 20),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 200).ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutQuad);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'timer_selection_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final int gridSize;
  final GameMode gameMode;

  const DifficultySelectionScreen(
      {super.key, required this.gridSize, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "AI CHALENGE",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Error-free weight
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "SELECT THE ENGINE INTELLIGENCE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 40),

            // Difficulty Cards
            _buildDiffCard(
                context,
                "EASY",
                "Neural pathways simplified. Good for practice.",
                AIDifficulty.easy,
                Colors.greenAccent,
                Icons.face_unlock_rounded,
                0),
            _buildDiffCard(
                context,
                "MODERATE",
                "Strategic thinking enabled. Can block your moves.",
                AIDifficulty.moderate,
                Colors.blueAccent,
                Icons.psychology_rounded,
                1),
            _buildDiffCard(
                context,
                "HARD",
                "Aggressive scoring. Hunts for perks and mines.",
                AIDifficulty.hard,
                Colors.orangeAccent,
                Icons.bolt_rounded,
                2),
            _buildDiffCard(
                context,
                "EXPERT",
                "Ultimate intelligence. Every move is calculated.",
                AIDifficulty.expert,
                Colors.redAccent,
                Icons.rocket_launch_rounded,
                3),

            const Spacer(),

            // Footer Status
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10, width: 0.5),
              ),
              child: Text(
                "ACTIVE PROTOCOL: ${gameMode.name.toUpperCase()} MODE",
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffCard(
    BuildContext context,
    String title,
    String desc,
    AIDifficulty diff,
    Color color,
    IconData icon,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TimerSelectionScreen(
              gridSize: gridSize,
              isVsAI: true,
              difficulty: diff,
              gameMode: gameMode,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          // PROFESSIONAL: 0.5 white border
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
          // Subtle glow based on difficulty color
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), Colors.transparent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            // Intensity Indicator
            Container(
              width: 4,
              height: 45,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1)
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Icon & Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900, // Error-free weight
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.1), size: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 150).ms, duration: 400.ms)
        .slideX(begin: 0.05, curve: Curves.easeOutQuad);
  }
}

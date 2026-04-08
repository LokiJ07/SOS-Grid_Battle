import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'timer_selection_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final int gridSize;
  final GameMode gameMode; // Carries Classic or Battle mode

  const DifficultySelectionScreen(
      {super.key, required this.gridSize, required this.gameMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("AI DIFFICULTY"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _diffItem(context, "EASY", "Random moves. For beginners.",
                AIDifficulty.easy, Colors.green),
            _diffItem(context, "MODERATE", "Looks for SOS points.",
                AIDifficulty.moderate, Colors.blue),
            _diffItem(context, "HARD", "Blocks you and hunts Perks.",
                AIDifficulty.hard, Colors.orange),
            _diffItem(context, "EXPERT", "Calculates every risk. Deadly.",
                AIDifficulty.expert, Colors.red),
            const Spacer(),
            Text(
              "PLAYING IN ${gameMode.name.toUpperCase()} MODE",
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diffItem(BuildContext context, String title, String desc,
      AIDifficulty diff, Color color) {
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
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(desc,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}

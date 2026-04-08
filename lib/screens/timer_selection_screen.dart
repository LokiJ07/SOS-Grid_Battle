import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';
import 'game_screen.dart';

class TimerSelectionScreen extends StatelessWidget {
  final int gridSize;
  final bool isVsAI;
  final AIDifficulty? difficulty;
  final GameMode gameMode;

  const TimerSelectionScreen(
      {super.key,
      required this.gridSize,
      required this.isVsAI,
      this.difficulty,
      required this.gameMode});

  void _startGame(BuildContext context, int? seconds) {
    // Collect all data and initialize the game provider
    context.read<GameProvider>().initGame(
          gridSize,
          seconds,
          vsAI: isVsAI,
          diff: difficulty ?? AIDifficulty.moderate,
          mode: gameMode,
        );

    // Navigate to the Game Screen and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("TURN TIMER"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Select how much time each player has per turn.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            _timerCard(context, "INFINITE", "Take your time. No pressure.",
                null, Icons.all_inclusive),
            _timerCard(
                context, "10 SECONDS", "Fast paced battle.", 10, Icons.bolt),
            _timerCard(context, "15 SECONDS", "Standard competitive time.", 15,
                Icons.timer),
            _timerCard(context, "30 SECONDS", "Strategic time limit.", 30,
                Icons.hourglass_top),
            const Spacer(),
            Text(
              "${gameMode.name.toUpperCase()} MODE • ${gridSize}x$gridSize GRID",
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerCard(BuildContext context, String title, String desc,
      int? seconds, IconData icon) {
    return GestureDetector(
      onTap: () => _startGame(context, seconds),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(desc,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

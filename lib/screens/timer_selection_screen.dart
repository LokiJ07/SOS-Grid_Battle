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

  const TimerSelectionScreen({
    super.key,
    required this.gridSize,
    required this.isVsAI,
    this.difficulty,
    required this.gameMode,
  });

  /// Initializes game and wipes navigation history so "Back" goes to Menu
  void _startGame(BuildContext context, int? seconds) {
    context.read<GameProvider>().initGame(
          gridSize,
          seconds,
          vsAI: isVsAI,
          diff: difficulty ?? AIDifficulty.moderate,
          mode: gameMode,
        );

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "TURN DURATION",
          style: TextStyle(
            fontWeight: FontWeight.w900, // Validated weight
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Ambient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.05),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.5, 1.5),
                duration: 4.seconds),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Choose your tactical pace.\nFast turns favor the bold.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(duration: 600.ms),

                const SizedBox(height: 40),

                // Timer Options
                _buildTimerCard(
                    context,
                    "INFINITE",
                    "Pure strategy. No time pressure.",
                    null,
                    Icons.all_inclusive_rounded,
                    Colors.blueAccent,
                    0),
                _buildTimerCard(
                    context,
                    "30 SECONDS",
                    "Strategic. For detailed planning.",
                    30,
                    Icons.hourglass_top_rounded,
                    Colors.cyanAccent,
                    1),
                _buildTimerCard(
                    context,
                    "15 SECONDS",
                    "Standard. Competitive match pace.",
                    15,
                    Icons.timer_outlined,
                    Colors.yellowAccent,
                    2),
                _buildTimerCard(
                    context,
                    "10 SECONDS",
                    "Blitz! Fastest reaction wins.",
                    10,
                    Icons.bolt_rounded,
                    Colors.orangeAccent,
                    3),

                const Spacer(),

                // Footer Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white10, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.layers_outlined,
                          size: 14, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 8),
                      Text(
                        "${gameMode.name.toUpperCase()} MODE • ${gridSize}x$gridSize GRID",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard(
    BuildContext context,
    String title,
    String desc,
    int? seconds,
    IconData icon,
    Color color,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _startGame(context, seconds),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          // PROFESSIONAL: 0.5 width white border
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Icon with glowing container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900, // Validated weight
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.play_arrow_rounded,
                color: Colors.white.withOpacity(0.2), size: 20),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 150).ms, duration: 400.ms)
        .slideX(begin: 0.1, curve: Curves.easeOutQuad);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import 'tally_painter.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI Thinking Status
        if (game.isAiThinking)
          _statusBar("COMPUTER IS THINKING...", Colors.red),

        // Timer Status Bar
        if (game.timerLimit != null)
          _statusBar(
              "TIME: ${game.remainingSeconds}s",
              game.remainingSeconds <= 3
                  ? Colors.red.shade900
                  : Colors.blueGrey.shade900),

        // Battle Mode Effect Banner
        if (game.lastEffectMessage.isNotEmpty)
          _statusBar(game.lastEffectMessage, Colors.orange,
              textColor: Colors.black),

        // Main Player Cards Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildPlayerCard(game.player1,
                      game.currentPlayer.id == PlayerID.player1, screenHeight)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
                child: Text("VS",
                    style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                  child: _buildPlayerCard(game.player2,
                      game.currentPlayer.id == PlayerID.player2, screenHeight)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBar(String text, Color bg, {Color textColor = Colors.white}) {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildPlayerCard(Player player, bool isActive, double screenHeight) {
    // Adaptive Sizing: Shrink tallies if score is high
    double tallyWidth = player.score > 40 ? 12.0 : 18.0;
    double tallyHeight = player.score > 40 ? 16.0 : 22.0;

    return Container(
      // Responsive constraint: Scoreboard never takes more than 15% of screen height
      constraints: BoxConstraints(maxHeight: screenHeight * 0.15),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive ? player.color.withOpacity(0.1) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? player.color : Colors.white.withOpacity(0.2),
          width: 0.5, // Standardized 0.5 white border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(player.name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: player.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10))),
              Text("${player.score}",
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white54)),
            ],
          ),
          const Divider(color: Colors.white10, height: 8),

          // SCROLLABLE TALLY AREA
          Expanded(
            child: Scrollbar(
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 3,
                  runSpacing: 3,
                  children: _generateTallies(
                      player.score, player.color, tallyWidth, tallyHeight),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Footer info (HP and Streak Multipliers)
          FittedBox(
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 10),
                const SizedBox(width: 3),
                Text(
                    'HP: ${player.lives.toStringAsFixed(player.lives % 1 == 0 ? 0 : 1)}',
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold)),

                // COMBO INDICATOR (Starts at Streak 4)
                if (player.streak >= 4) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'x${player.streak - 2} COMBO',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ] else if (player.streak > 1) ...[
                  const SizedBox(width: 6),
                  Text('Streak: ${player.streak} 🔥',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateTallies(int score, Color color, double w, double h) {
    if (score == 0)
      return [
        const Text("-", style: TextStyle(color: Colors.white24, fontSize: 10))
      ];

    return List.generate((score / 5).ceil(), (index) {
      int count = (index < score ~/ 5) ? 5 : (score % 5);
      if (count == 0) return const SizedBox.shrink();
      return CustomPaint(
        size: Size(w, h),
        painter: TallyPainter(count: count, color: color),
      );
    });
  }
}

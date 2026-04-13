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
    final h = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // 1. Top Status Bars
        if (game.isAiThinking)
          _statusBar("COMPUTER IS THINKING...", Colors.red),
        if (game.timerLimit != null)
          _statusBar(
              "TIME: ${game.remainingSeconds}s",
              game.remainingSeconds <= 3
                  ? Colors.red.shade900
                  : Colors.blueGrey.shade900),

        // 2. Score Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _playerCard(game.player1,
                      game.currentPlayer.id == PlayerID.player1, h)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
                child: Text("VS",
                    style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.w900)),
              ),
              Expanded(
                  child: _playerCard(game.player2,
                      game.currentPlayer.id == PlayerID.player2, h)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBar(String t, Color c) => Container(
      width: double.infinity,
      color: c,
      padding: const EdgeInsets.all(2),
      child: Text(t,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)));

  Widget _playerCard(Player p, bool active, double screenHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: active ? p.color.withOpacity(0.1) : Colors.black26,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: active ? p.color : Colors.white.withOpacity(0.2),
              width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name and Numerical Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(p.name.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: p.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 10))),
              // If score is negative, make it Red
              Text("${p.score}",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: p.score < 0 ? Colors.redAccent : Colors.white54)),
            ],
          ),
          const Divider(color: Colors.white10, height: 8),

          // SCORING AREA (Tally marks OR "LOSS" Text for negative)
          Expanded(
            child: p.score < 0
                ? Center(
                    child: Text("LOSS: ${p.score}",
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: 14)))
                : Scrollbar(
                    child: SingleChildScrollView(
                      child: Wrap(
                          spacing: 3,
                          runSpacing: 3,
                          children: _generateTallies(p.score, p.color)),
                    ),
                  ),
          ),

          const SizedBox(height: 4),

          // HP and Perk Info
          FittedBox(
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 9),
                const SizedBox(width: 3),
                Text('HP: ${p.lives.toStringAsFixed(p.lives % 1 == 0 ? 0 : 1)}',
                    style: const TextStyle(
                        fontSize: 9, fontWeight: FontWeight.bold)),
                if (p.hasShield)
                  const Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Icon(Icons.shield,
                          color: Colors.blueAccent, size: 9)),
                if (p.streak >= 4)
                  Text(' x${p.streak - 2} COMBO',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 8,
                          fontWeight: FontWeight.w900)),
              ],
            ),
          ),

          // VISUAL HEALTH BAR (Turns Cyan for over-heal > 10)
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (p.lives / 10)
                  .clamp(0.0, 2.0), // Allows bar to show up to double normal HP
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                p.lives > 10
                    ? Colors.cyanAccent
                    : (p.lives > 3 ? p.color : Colors.red),
              ),
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateTallies(int score, Color color) {
    if (score <= 0) return [const SizedBox.shrink()];

    return List.generate((score / 5).ceil(), (index) {
      int count = (index < score ~/ 5) ? 5 : (score % 5);
      if (count == 0) return const SizedBox.shrink();
      return CustomPaint(
        size: const Size(14, 18),
        painter: TallyPainter(count: count, color: color),
      );
    });
  }
}

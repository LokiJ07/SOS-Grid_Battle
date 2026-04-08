import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Responsive Timer Bar
        if (game.timerLimit != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            width: double.infinity,
            color: game.remainingSeconds <= 3
                ? Colors.red.shade900
                : Colors.blueGrey.shade900,
            child: Text(
              "TIME: ${game.remainingSeconds}s",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),

        // Effect Message (Notification Area)
        if (game.lastEffectMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(2),
            color: Colors.orange.withOpacity(0.8),
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                game.lastEffectMessage,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // Main Score Area
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                  child: _buildPlayerCard(
                      game.player1, game.currentPlayer.id == PlayerID.player1)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("VS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white24)),
              ),
              Expanded(
                  child: _buildPlayerCard(
                      game.player2, game.currentPlayer.id == PlayerID.player2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Player player, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? player.color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isActive ? player.color : Colors.white10, width: 2),
      ),
      child: Column(
        children: [
          FittedBox(
            child: Text(player.name,
                style: TextStyle(
                    color: player.color, fontWeight: FontWeight.bold)),
          ),
          FittedBox(
            child: Text('${player.score}',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.normal)),
          ),
          // Lives Display with dynamic decimal (e.g., 9.5)
          FittedBox(
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  'HP: ${player.lives.toStringAsFixed(player.lives % 1 == 0 ? 0 : 1)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Streak Indicator
          if (player.streak > 1)
            FittedBox(
              child: Text('${player.streak}x Streak',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

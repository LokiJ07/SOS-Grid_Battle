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
      children: [
        if (game.timerLimit != null)
          Container(
            padding: const EdgeInsets.all(8),
            color: game.remainingSeconds <= 3 ? Colors.red : Colors.blueGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, size: 18),
                const SizedBox(width: 8),
                Text(
                  "TIME LEFT: ${game.remainingSeconds}s",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerInfo(
                  game.player1, game.currentPlayer.id == PlayerID.player1),
              const Text('VS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildPlayerInfo(
                  game.player2, game.currentPlayer.id == PlayerID.player2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInfo(Player player, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? player.color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isActive ? player.color : Colors.white10),
      ),
      child: Column(
        children: [
          Text(player.name,
              style:
                  TextStyle(color: player.color, fontWeight: FontWeight.bold)),
          Text('${player.score}',
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Text('Lives: ${player.lives}',
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

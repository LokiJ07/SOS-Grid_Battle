import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(title: const Text("BATTLE STATS")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _statTile("GAMES PLAYED", AppConstants.keyGamesPlayed,
                Icons.videogame_asset, Colors.white),
            _statTile("PLAYER 1 WINS", AppConstants.keyP1Wins, Icons.person,
                Colors.blue),
            _statTile("P2 / AI WINS", AppConstants.keyP2Wins, Icons.computer,
                Colors.red),
            _statTile("HIGHEST SCORE", AppConstants.keyHighScore,
                Icons.emoji_events, Colors.yellow),
            const Spacer(),
            const Text("Stats are saved locally.",
                style: TextStyle(color: Colors.white24, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, String key, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 20),
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text(
            "${StorageService.getInt(key)}",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }
}

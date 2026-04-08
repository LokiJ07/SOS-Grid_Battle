import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _StatTile(
                label: "Games Played",
                value: StorageService.getInt(AppConstants.keyGamesPlayed)
                    .toString()),
            _StatTile(
                label: "Player 1 Wins",
                value:
                    StorageService.getInt(AppConstants.keyP1Wins).toString()),
            _StatTile(
                label: "Player 2 Wins",
                value:
                    StorageService.getInt(AppConstants.keyP2Wins).toString()),
            _StatTile(
                label: "Highest Score",
                value: StorageService.getInt(AppConstants.keyHighScore)
                    .toString()),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

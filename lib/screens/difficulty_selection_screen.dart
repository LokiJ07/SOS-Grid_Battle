import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'timer_selection_screen.dart';

class DifficultySelectionScreen extends StatelessWidget {
  final int gridSize;
  const DifficultySelectionScreen({super.key, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DIFFICULTY")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _item(context, "EASY", Colors.green, AIDifficulty.easy),
          _item(context, "MODERATE", Colors.blue, AIDifficulty.moderate),
          _item(context, "HARD", Colors.orange, AIDifficulty.hard),
          _item(context, "EXPERT", Colors.red, AIDifficulty.expert),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String t, Color c, AIDifficulty d) {
    return Card(
      child: ListTile(
        title: Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TimerSelectionScreen(
                    gridSize: gridSize, isVsAI: true, difficulty: d))),
      ),
    );
  }
}

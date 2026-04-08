import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';
import 'game_screen.dart';

class TimerSelectionScreen extends StatelessWidget {
  final int gridSize;
  final bool isVsAI;
  final AIDifficulty? difficulty;

  const TimerSelectionScreen(
      {super.key,
      required this.gridSize,
      required this.isVsAI,
      this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TURN TIMER")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _opt(context, "No Timer", null),
          _opt(context, "10 Seconds", 10),
          _opt(context, "15 Seconds", 15),
          _opt(context, "30 Seconds", 30),
        ],
      ),
    );
  }

  Widget _opt(BuildContext context, String l, int? s) {
    return Card(
      child: ListTile(
        title: Text(l),
        onTap: () {
          context.read<GameProvider>().initGame(gridSize, s,
              vsAI: isVsAI, diff: difficulty ?? AIDifficulty.moderate);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const GameScreen()),
              (route) => route.isFirst);
        },
      ),
    );
  }
}

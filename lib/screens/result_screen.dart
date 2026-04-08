import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    String res = game.player1.score > game.player2.score
        ? "P1 WINS!"
        : (game.player2.score > game.player1.score
            ? "${game.player2.name.toUpperCase()} WINS!"
            : "DRAW!");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(res,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("P1: ${game.player1.score} - P2: ${game.player2.score}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("BACK")),
          ],
        ),
      ),
    );
  }
}

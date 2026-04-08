import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Rule(
                text:
                    "1. Players take turns placing 'S' or 'O' in any empty square."),
            _Rule(
                text:
                    "2. If a player creates an SOS sequence (horizontal, vertical, or diagonal), they get a point."),
            _Rule(
                text:
                    "3. After forming an SOS, that player takes another turn."),
            _Rule(
                text:
                    "4. If no SOS is formed, the turn passes to the next player."),
            _Rule(text: "5. The game ends when the grid is full."),
            _Rule(text: "6. The player with the highest score wins."),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  final String text;
  const _Rule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}

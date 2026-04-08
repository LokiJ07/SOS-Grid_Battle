import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'timer_selection_screen.dart'; // Import the new screen

class BoardSizeScreen extends StatelessWidget {
  const BoardSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Board Size'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: AppConstants.gridSizes.length,
        itemBuilder: (context, index) {
          int size = AppConstants.gridSizes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              title: Text(
                '$size x $size Grid',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${size * size} total cells',
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
              ),
              onTap: () {
                // Navigate to Timer Selection instead of starting the game
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimerSelectionScreen(gridSize: size),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

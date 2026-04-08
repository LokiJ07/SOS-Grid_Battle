import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'difficulty_selection_screen.dart'; // Needed for VS AI mode
import 'timer_selection_screen.dart'; // Needed for Local PvP mode

class BoardSizeScreen extends StatelessWidget {
  // We add this variable to know if the user clicked "Solo" or "Multiplayer" in the Menu
  final bool isVsAI;

  const BoardSizeScreen({super.key, required this.isVsAI});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('SELECT BOARD SIZE'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: AppConstants.gridSizes.length,
        itemBuilder: (context, index) {
          int size = AppConstants.gridSizes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side:
                  BorderSide(color: Colors.white.withOpacity(0.5), width: 0.5),
            ),
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
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '${size * size} total cells',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 18,
              ),
              onTap: () {
                // BRANCHING LOGIC:
                if (isVsAI) {
                  // If playing against Computer, go to Difficulty Selection first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DifficultySelectionScreen(gridSize: size),
                    ),
                  );
                } else {
                  // If playing Local Multiplayer, go straight to Timer Selection
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimerSelectionScreen(
                        gridSize: size,
                        isVsAI: false,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

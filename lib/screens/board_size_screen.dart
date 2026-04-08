import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'mode_selection_screen.dart';

class BoardSizeScreen extends StatelessWidget {
  final bool isVsAI; // Tracks if the user chose Solo or Multiplayer in the menu

  const BoardSizeScreen({super.key, required this.isVsAI});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'SELECT BOARD SIZE',
          style: TextStyle(
              fontWeight: FontWeight.w500, letterSpacing: 2, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              isVsAI ? "CHALLENGE THE COMPUTER" : "LOCAL MULTIPLAYER MATCH",
              style: TextStyle(
                color: isVsAI
                    ? Colors.red.withOpacity(0.7)
                    : Colors.blue.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: AppConstants.gridSizes.length,
              itemBuilder: (context, index) {
                int size = AppConstants.gridSizes[index];
                return _buildSizeCard(context, size, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeCard(BuildContext context, int size, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to the next selection: Mode Selection (Classic vs Battle)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModeSelectionScreen(
              gridSize: size,
              isVsAI: isVsAI,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          // Sharp professional 0.5 white border
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon representing the grid density
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                size > 16 ? Icons.grid_on : Icons.grid_view_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$size x $size',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${size * size} TOTAL CELLS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
  }
}

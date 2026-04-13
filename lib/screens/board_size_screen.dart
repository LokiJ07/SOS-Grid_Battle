import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'mode_selection_screen.dart';

class BoardSizeScreen extends StatelessWidget {
  final bool isVsAI;

  const BoardSizeScreen({super.key, required this.isVsAI});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GRID SELECTION',
          style: TextStyle(
            fontWeight: FontWeight.w900, // Validated weight
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // --- MATCH STATUS BADGE ---
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isVsAI
                    ? Colors.redAccent.withOpacity(0.1)
                    : Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isVsAI
                      ? Colors.redAccent.withOpacity(0.5)
                      : Colors.blueAccent.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isVsAI ? Icons.computer_rounded : Icons.people_alt_rounded,
                    size: 14,
                    color: isVsAI ? Colors.redAccent : Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isVsAI ? "PROTOCOL: VS COMPUTER" : "PROTOCOL: LOCAL PVP",
                    style: TextStyle(
                      color: isVsAI ? Colors.redAccent : Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: -0.2, end: 0),

          const SizedBox(height: 30),

          // --- GRID OPTIONS LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: AppConstants.gridSizes.length,
              physics: const BouncingScrollPhysics(),
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
    // Dynamic icon based on grid complexity
    IconData gridIcon = size <= 6
        ? Icons.grid_view_rounded
        : (size <= 16 ? Icons.grid_4x4_rounded : Icons.grid_on_rounded);

    return GestureDetector(
      onTap: () {
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
          borderRadius: BorderRadius.circular(20),
          // PROFESSIONAL: 0.5 width white border
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
          // Subtle side gradient for depth
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.02), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Styled Icon Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(gridIcon, color: Colors.white70, size: 26),
            ),
            const SizedBox(width: 20),

            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$size x $size',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900, // Validated weight
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${size * size} TACTICAL CELLS',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.1),
              size: 16,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
        .slideX(begin: 0.05, curve: Curves.easeOutQuad);
  }
}

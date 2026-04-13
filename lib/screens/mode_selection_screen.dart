import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import 'difficulty_selection_screen.dart';
import 'timer_selection_screen.dart';
import '../widgets/mode_info_modal.dart'; // Import modal

class ModeSelectionScreen extends StatelessWidget {
  final int gridSize;
  final bool isVsAI;

  const ModeSelectionScreen(
      {super.key, required this.gridSize, required this.isVsAI});

  void _showRules(BuildContext context, GameMode mode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModeInfoModal(mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("SELECT GAME STYLE",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildModeCard(
              context,
              title: "CLASSIC SOS",
              description: "The pure strategy paper game. No traps.",
              icon: Icons.auto_stories_rounded,
              mode: GameMode.classic,
              accentColor: Colors.blueAccent,
              index: 0,
            ),
            const SizedBox(height: 20),
            _buildModeCard(
              context,
              title: "BATTLE MODE",
              description: "Hidden Mines, Stuns, and Perk items.",
              icon: Icons.rocket_launch_rounded,
              mode: GameMode.battle,
              accentColor: Colors.orangeAccent,
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required GameMode mode,
    required Color accentColor,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isVsAI) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DifficultySelectionScreen(
                            gridSize: gridSize, gameMode: mode)));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TimerSelectionScreen(
                            gridSize: gridSize,
                            isVsAI: false,
                            gameMode: mode)));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15)),
                    child: Icon(icon, color: accentColor, size: 32),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                        Text(description,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.4))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // MODAL TRIGGER BUTTON
          InkWell(
            onTap: () => _showRules(context, mode),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: accentColor),
                  const SizedBox(width: 8),
                  Text("HOW IT WORKS",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 200).ms).slideY(begin: 0.2);
  }
}

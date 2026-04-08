import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';

class LetterSelector extends StatelessWidget {
  const LetterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLetterButton(context, "S", game.selectedLetter == "S"),
          const SizedBox(width: 40),
          _buildLetterButton(context, "O", game.selectedLetter == "O"),
        ],
      ),
    );
  }

  Widget _buildLetterButton(
      BuildContext context, String letter, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<GameProvider>().selectLetter(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.player1Color
              : AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppConstants.player1Color.withOpacity(0.4),
                      blurRadius: 10)
                ]
              : [],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

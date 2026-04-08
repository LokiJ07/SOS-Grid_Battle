import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class LetterSelector extends StatelessWidget {
  const LetterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    // Use Media Query to adjust button size for smaller screens
    double screenWidth = MediaQuery.of(context).size.width;
    double btnSize = screenWidth > 600 ? 80 : 60;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBtn(context, "S", game.selectedLetter == "S",
              game.currentPlayer.color, btnSize),
          const SizedBox(width: 20),
          _buildBtn(context, "O", game.selectedLetter == "O",
              game.currentPlayer.color, btnSize),
        ],
      ),
    );
  }

  Widget _buildBtn(
      BuildContext context, String val, bool sel, Color color, double size) {
    return GestureDetector(
      onTap: () => context.read<GameProvider>().selectLetter(val),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: sel ? color : Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? Colors.white : Colors.transparent),
        ),
        child: Center(
          child: Text(val,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

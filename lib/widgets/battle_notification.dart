import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class BattleNotification extends StatelessWidget {
  const BattleNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    if (game.lastEffectMessage.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black
          .withOpacity(0.4), // Dims the grid so animation stands out
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Unique Icon for the item
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orangeAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.4),
                      blurRadius: 40)
                ],
              ),
              child: Icon(game.lastEffectIcon ?? Icons.bolt,
                  size: 64, color: Colors.orangeAccent),
            )
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .shake(delay: 500.ms),

            const SizedBox(height: 24),

            // The Consequence Message
            Text(
              game.lastEffectMessage.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

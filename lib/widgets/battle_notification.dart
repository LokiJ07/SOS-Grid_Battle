import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../core/constants.dart';

class BattleNotification extends StatelessWidget {
  const BattleNotification({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the lastEffectMessage from Provider
    final message = context.watch<GameProvider>().lastEffectMessage;

    if (message.isEmpty || message == "GAME START!")
      return const SizedBox.shrink();

    return IgnorePointer(
      // CRITICAL: This allows the player to click "through" the notification
      // so it doesn't block gameplay.
      child: Container(
        alignment: Alignment.topCenter,
        padding:
            const EdgeInsets.only(top: 100), // Positioned below the scoreboard
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Text(
                message.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        )
            .animate(
                key:
                    ValueKey(message)) // Restart animation when message changes
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack)
            .then(delay: 2.seconds) // Stay for 2 seconds
            .fadeOut(duration: 300.ms),
      ),
    );
  }
}

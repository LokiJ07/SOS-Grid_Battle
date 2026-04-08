import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';

class GameLogo extends StatelessWidget {
  final double size;
  const GameLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background Glow (Animated pulsing effect)
            Container(
              width: size * 1.2,
              height: size * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.player1Color.withOpacity(0.15),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                  BoxShadow(
                    color: AppConstants.player2Color.withOpacity(0.15),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2.seconds),

            // The SOS Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLetter('S', AppConstants.player1Color),
                _buildLetter('O', Colors.white),
                _buildLetter('S', AppConstants.player2Color),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Subtitle
        Text(
          "GRID BATTLE",
          style: GoogleFonts.blackOpsOne(
            color: Colors.white70,
            fontSize: size * 0.2,
            letterSpacing: 8,
          ),
        )
            .animate()
            .fadeIn(delay: 400.ms)
            .moveY(
                begin: 10,
                end:
                    0) // Replaced trackingSlightly with a smooth move animation
            .shimmer(
                delay: 1.seconds,
                duration: 1500.ms), // Added a professional shimmer effect
      ],
    );
  }

  Widget _buildLetter(String char, Color color) {
    return Text(
      char,
      style: GoogleFonts.russoOne(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: color.withOpacity(0.6), blurRadius: 25),
          const Shadow(color: Colors.black, offset: Offset(4, 4)),
        ],
      ),
    ).animate().scale(
          duration: 800.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
        );
  }
}

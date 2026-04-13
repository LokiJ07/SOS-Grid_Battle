import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';

class ModeInfoModal extends StatelessWidget {
  final GameMode mode;

  const ModeInfoModal({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    bool isBattle = mode == GameMode.battle;

    return Container(
      // Responsive height: Takes up 70% of the screen
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        // PROFESSIONAL: Sharp 0.5 white border
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 25),

          // Trendy Title with Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBattle
                    ? Icons.rocket_launch_rounded
                    : Icons.auto_stories_rounded,
                color: isBattle ? Colors.orangeAccent : Colors.blueAccent,
                size: 28,
              ),
              const SizedBox(width: 15),
              Text(
                isBattle ? "BATTLE GUIDE" : "CLASSIC RULES",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ],
          ).animate().fadeIn().scale(curve: Curves.easeOutBack),

          const SizedBox(height: 25),

          // Scrollable content area
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildModernSection(
                    context,
                    "THE OBJECTIVE",
                    [
                      "Connect S-O-S in a straight line (any direction).",
                      "Each SOS grants you an EXTRA TURN.",
                      "Forming SOS consecutively builds a STREAK."
                    ],
                    Icons.flag_rounded,
                    Colors.blueAccent,
                  ),
                  if (isBattle) ...[
                    _buildModernSection(
                      context,
                      "STREAK BONUSES",
                      [
                        "Streak 1 - 3: Normal scoring (1 pt).",
                        "Streak 4: X2 Multiplier active!",
                        "Streak 5+: X3, X4, X5 Multipliers!"
                      ],
                      Icons.trending_up_rounded,
                      Colors.yellowAccent,
                    ),
                    _buildModernSection(
                      context,
                      "DANGEROUS MINES",
                      [
                        "THE GREAT SWAP: Gives 50% of your score to enemy!",
                        "STUN: Forces you to skip your next turn.",
                        "POISON: Lethal damage (-1.5 HP).",
                        "SCORE WIPE: Instantly lose 5 points."
                      ],
                      Icons.dangerous_rounded,
                      Colors.redAccent,
                    ),
                    _buildModernSection(
                      context,
                      "STRATEGIC PERKS",
                      [
                        "SHIELD: Protects you from the next mine.",
                        "JACKPOT: Adds 5 points to your tally.",
                        "LIFE STEAL: Drain 1 HP from your opponent.",
                        "AREA REVEAL: See hidden items nearby."
                      ],
                      Icons.star_rounded,
                      Colors.greenAccent,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Modern "Got it" Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isBattle ? Colors.orangeAccent : Colors.blueAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "I'M READY TO BATTLE",
                style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 2),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildModernSection(BuildContext context, String title,
      List<String> rules, IconData sectionIcon, Color accentColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        // Sharp 0.5 white border for section boxes
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sectionIcon, color: accentColor, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white10, thickness: 0.5),
          ),
          ...rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                          color: accentColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rule,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05);
  }
}

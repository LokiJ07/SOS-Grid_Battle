import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Trendy Modern Collapsible Header
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppConstants.backgroundColor,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "BATTLE GUIDE",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.player1Color.withOpacity(0.3),
                      AppConstants.player2Color.withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_stories_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),

          // Rule Content List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle("THE CORE RULES"),
                _buildRuleCard(
                  icon: Icons.grid_3x3_rounded,
                  color: Colors.blueAccent,
                  title: "Place & Connect",
                  description:
                      "Tap empty cells to place 'S' or 'O'. Form the pattern S-O-S in any direction to score points.",
                ),
                _buildRuleCard(
                  icon: Icons.refresh_rounded,
                  color: Colors.cyanAccent,
                  title: "Bonus Actions",
                  description:
                      "Every SOS you complete grants you an immediate EXTRA TURN. Keep control of the board!",
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("COMBO SYSTEM"),
                _buildRuleCard(
                  icon: Icons.trending_up_rounded,
                  color: Colors.orangeAccent,
                  title: "Multiplier (Streak 4+)",
                  description:
                      "Forming SOS patterns consecutively builds a streak. At Streak 4, you get x2 points. Streak 5 is x3, and so on!",
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("BATTLE MECHANICS"),
                _buildRuleCard(
                  icon: Icons.dangerous_rounded,
                  color: Colors.redAccent,
                  title: "Deadly Mines",
                  description:
                      "Hidden traps! 'The Great Swap' gives half your score to the enemy. Stuns skip your turn. Poison drains HP.",
                ),
                _buildRuleCard(
                  icon: Icons.shield_rounded,
                  color: Colors.greenAccent,
                  title: "Power Perks",
                  description:
                      "Find Shields to block the next mine, Jackpot for +5 score, or Life Steal to drain enemy health.",
                ),

                const SizedBox(height: 25),
                _buildSectionTitle("SURVIVAL"),
                _buildRuleCard(
                  icon: Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                  title: "Unlimited HP",
                  description:
                      "Start with 10 HP. Some perks allow over-healing beyond 10! If HP hits zero, you are eliminated.",
                ),
                _buildRuleCard(
                  icon: Icons.history_rounded,
                  color: Colors.white,
                  title: "Match Replay",
                  description:
                      "Check the 'Match Archive' in the menu to review your moves and learn from your mistakes.",
                ),

                const SizedBox(height: 40),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "UNDERSTOOD",
                      style: TextStyle(
                          fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white38,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          fontSize: 12,
        ),
      ).animate().fadeIn().slideX(begin: -0.1),
    );
  }

  Widget _buildRuleCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        // Sharp professional 0.5 white border
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container with soft glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 18),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

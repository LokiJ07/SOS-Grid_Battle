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
        slivers: [
          // Trendy Modern Header
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            backgroundColor: AppConstants.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "HOW TO BATTLE",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.player1Color.withOpacity(0.2),
                      AppConstants.player2Color.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Content List
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle("THE BASICS"),
                _buildRuleCard(
                  icon: Icons.grid_3x3,
                  color: Colors.blue,
                  title: "Place Letters",
                  description:
                      "Tap an empty cell to place 'S' or 'O'. Form the pattern S-O-S in any direction to score.",
                ),
                _buildRuleCard(
                  icon: Icons.refresh,
                  color: Colors.green,
                  title: "Bonus Turns",
                  description:
                      "Every time you complete an SOS, you get a bonus turn. Keep the streak going!",
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("BATTLE MODE"),
                _buildRuleCard(
                  icon: Icons.bolt,
                  color: Colors.orange,
                  title: "Hidden Mines",
                  description:
                      "Some cells contain traps! Reveal them to get STUNNED (skip turn) or lose -0.5 HP.",
                ),
                _buildRuleCard(
                  icon: Icons.stars,
                  color: Colors.purple,
                  title: "Perks",
                  description:
                      "Finding a Perk allows you to drain your opponent's score or lives directly.",
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("STREAKS & LIVES"),
                _buildRuleCard(
                  icon: Icons.trending_up,
                  color: Colors.yellow,
                  title: "Multipliers",
                  description:
                      "Forming SOS patterns consecutively increases your Multiplier (2x, 3x...). Missing an SOS resets it.",
                ),
                _buildRuleCard(
                  icon: Icons.favorite,
                  color: Colors.red,
                  title: "Survival",
                  description:
                      "You start with 10 Lives. If the timer runs out or you hit a mine, you lose lives. 0 HP = Defeat.",
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("CONTROLS"),
                _buildRuleCard(
                  icon: Icons.zoom_in,
                  color: Colors.white,
                  title: "Zoom & Pan",
                  description:
                      "On large 32x32 grids, use two fingers to pinch and zoom. Drag to move around the board.",
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("UNDERSTOOD"),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 13,
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
      padding: const EdgeInsets.all(16),
// Inside _buildRuleCard, update the BoxDecoration:
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 0.5, // Sharp professional border
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.4,
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

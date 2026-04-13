import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve data from storage
    final int totalGames = StorageService.getInt(AppConstants.keyGamesPlayed);
    final int p1Wins = StorageService.getInt(AppConstants.keyP1Wins);
    final int p2Wins = StorageService.getInt(AppConstants.keyP2Wins);
    final int highScore = StorageService.getInt(AppConstants.keyHighScore);

    // Calculate Win Percentages
    double p1WinRate = totalGames > 0 ? (p1Wins / totalGames) : 0.0;
    double p2WinRate = totalGames > 0 ? (p2Wins / totalGames) : 0.0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "BATTLE RECORDS",
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TOP HIGHLIGHT: TOTAL GAMES ---
            _buildMainStatCard(
              "TOTAL BATTLES",
              totalGames.toString(),
              Icons.bolt_rounded,
              Colors.orangeAccent,
            ),

            const SizedBox(height: 30),
            _buildSectionLabel("WIN DISTRIBUTION"),

            // --- WIN RATE BARS ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: Colors.white.withOpacity(0.4), width: 0.5),
              ),
              child: Column(
                children: [
                  _buildWinRow(
                      "PLAYER 1", p1Wins, p1WinRate, AppConstants.player1Color),
                  const SizedBox(height: 20),
                  _buildWinRow("PLAYER 2 / AI", p2Wins, p2WinRate,
                      AppConstants.player2Color),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 30),
            _buildSectionLabel("PERFORMANCE"),

            // --- GRID STATS: HIGH SCORE & DRAWS ---
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard(
                    "BEST SCORE",
                    highScore.toString(),
                    Icons.emoji_events_rounded,
                    Colors.yellowAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStatCard(
                    "STALEMATES",
                    (totalGames - (p1Wins + p2Wins)).toString(),
                    Icons.balance_rounded,
                    Colors.white54,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 50),
            const Center(
              child: Text(
                "DATA SYNCHRONIZED OFFLINE",
                style: TextStyle(
                  color: Colors.white10,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildMainStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ],
          ),
          Icon(icon, color: color.withOpacity(0.5), size: 50),
        ],
      ),
    ).animate().fadeIn().scale(curve: Curves.easeOutBack);
  }

  Widget _buildMiniStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRow(String player, int count, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(player,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900)),
            Text(
              "$count WINS (${(percent * 100).toInt()}%)",
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

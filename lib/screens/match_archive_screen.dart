import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../models/move_model.dart';
import '../models/sos_line.dart';
import '../core/constants.dart';
import 'match_history_screen.dart';

class MatchArchiveScreen extends StatelessWidget {
  const MatchArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Retrieve the list of matches from offline storage
    final List<dynamic> archive = StorageService.getMatchArchive();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "MATCH ARCHIVE",
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: archive.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: archive.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final match = archive[index];

                // 2. Decode moves and SOS lines from the JSON data
                final List<MoveModel> moves = (match['moves'] as List)
                    .map((m) => MoveModel.fromJson(m))
                    .toList();

                // Handle SOS lines (check if key exists for backwards compatibility)
                final List<SOSLine> lines = match['sosLines'] != null
                    ? (match['sosLines'] as List)
                        .map((s) => SOSLine.fromJson(s))
                        .toList()
                    : [];

                return _buildMatchCard(context, match, moves, lines, index);
              },
            ),
    );
  }

  /// Placeholder shown when no matches have been played yet
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded,
              size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            "NO MATCHES RECORDED",
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual card for a past match
  Widget _buildMatchCard(BuildContext context, dynamic match,
      List<MoveModel> moves, List<SOSLine> lines, int index) {
    String result = match['result'] ?? "Unknown";
    int gridSize = match['gridSize'] ?? 0;

    return GestureDetector(
      onTap: () {
        // Navigate to replay screen with all reconstructed data
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MatchHistoryScreen(
                    history: moves, sosLines: lines, gridSize: gridSize)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          // PROFESSIONAL: Sharp 0.5 white border
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.play_circle_filled_rounded,
                  color: Colors.blueAccent, size: 24),
            ),
            const SizedBox(width: 20),

            // Match Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${gridSize}x$gridSize GRID • ${moves.length} TOTAL MOVES",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Date or Arrow
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.2)),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
        .slideX(begin: 0.1);
  }
}

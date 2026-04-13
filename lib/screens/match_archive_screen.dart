import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/move_model.dart';
import '../core/constants.dart';
import 'match_history_screen.dart';

class MatchArchiveScreen extends StatelessWidget {
  const MatchArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archive = StorageService.getMatchArchive();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("MATCH ARCHIVE",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: archive.isEmpty
          ? const Center(
              child: Text("No matches saved yet.",
                  style: TextStyle(color: Colors.white24)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: archive.length,
              itemBuilder: (context, index) {
                final match = archive[index];
                final List<MoveModel> moves = (match['moves'] as List)
                    .map((m) => MoveModel.fromJson(m))
                    .toList();

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MatchHistoryScreen(
                                history: moves, gridSize: match['gridSize'])));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_toggle_off_rounded,
                            color: Colors.blueAccent.withOpacity(0.5)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(match['result'].toString().toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 14)),
                              Text(
                                  "${match['gridSize']}x${match['gridSize']} • ${moves.length} MOVES",
                                  style: const TextStyle(
                                      color: Colors.white24,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Icon(Icons.play_arrow_rounded,
                            color: Colors.white24),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

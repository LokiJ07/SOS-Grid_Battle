import 'package:flutter/material.dart';
import '../models/move_model.dart';
import '../models/player.dart';
import '../core/constants.dart';

class MatchHistoryScreen extends StatefulWidget {
  final List<MoveModel> history;
  final int gridSize;

  const MatchHistoryScreen(
      {super.key, required this.history, required this.gridSize});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  int _currentStep = -1; // -1 = start of game

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("MATCH REPLAY",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildInfoPanel(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildReplayBoard(),
            ),
          ),
          _buildControls(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    if (_currentStep == -1) {
      return const Padding(
        padding: EdgeInsets.all(25),
        child: Text("BOARD INITIALIZED",
            style: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2)),
      );
    }
    final move = widget.history[_currentStep];
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("STEP ${_currentStep + 1} / ${widget.history.length}",
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(move.playerName.toUpperCase(),
                  style: TextStyle(
                      color: move.playerID == PlayerID.player1
                          ? Colors.blue
                          : Colors.red,
                      fontWeight: FontWeight.w900)),
              const Text(" PLACED ",
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              Text(move.letter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplayBoard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: InteractiveViewer(
        maxScale: 4.0,
        child: GridView.builder(
          itemCount: widget.gridSize * widget.gridSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.gridSize,
            crossAxisSpacing: 0.5,
            mainAxisSpacing: 0.5,
          ),
          itemBuilder: (context, index) {
            MoveModel? moveAtCell;
            // Check if this cell was filled at or before the current step
            for (int i = 0; i <= _currentStep; i++) {
              if (widget.history[i].index == index) {
                moveAtCell = widget.history[i];
              }
            }

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1), width: 0.2),
              ),
              child: Center(
                child: moveAtCell == null
                    ? null
                    : FittedBox(
                        child: Text(
                          moveAtCell.letter,
                          style: TextStyle(
                            color: moveAtCell.playerID == PlayerID.player1
                                ? Colors.blue
                                : Colors.red,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn(Icons.first_page, () => setState(() => _currentStep = -1)),
        const SizedBox(width: 10),
        _btn(Icons.chevron_left, () {
          if (_currentStep > -1) setState(() => _currentStep--);
        }),
        const SizedBox(width: 20),
        _btn(Icons.chevron_right, () {
          if (_currentStep < widget.history.length - 1)
            setState(() => _currentStep++);
        }),
        const SizedBox(width: 10),
        _btn(Icons.last_page,
            () => setState(() => _currentStep = widget.history.length - 1)),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

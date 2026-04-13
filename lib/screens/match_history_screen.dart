import 'package:flutter/material.dart';
import '../models/move_model.dart';
import '../models/sos_line.dart';
import '../models/player.dart';
import '../core/constants.dart';
import '../widgets/sos_painter.dart';

class MatchHistoryScreen extends StatefulWidget {
  final List<MoveModel> history;
  final List<SOSLine> sosLines;
  final int gridSize;

  const MatchHistoryScreen({
    super.key,
    required this.history,
    required this.sosLines,
    required this.gridSize,
  });

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  // -1 represents the board state before the first move was made
  int _currentStep = -1;

  @override
  Widget build(BuildContext context) {
    // FILTER: Only show SOS lines that were formed on or before the current step
    List<SOSLine> visibleLines = widget.sosLines
        .where((line) => line.moveIndex <= _currentStep)
        .toList();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "MATCH REPLAY",
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Move information display
          _buildInfoPanel(),

          // 2. The Replay Board area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(builder: (context, constraints) {
                double side = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth
                    : constraints.maxHeight;

                return Center(
                  child: Container(
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        // Layer 1: The Letters Grid
                        _buildReplayGrid(),

                        // Layer 2: The SOS Strikethrough Lines
                        IgnorePointer(
                          child: CustomPaint(
                            size: Size(side, side),
                            painter: SOSPainter(
                                lines: visibleLines, gridSize: widget.gridSize),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // 3. Navigation Controls
          _buildControls(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Displays move details: Who played what and the current progress
  Widget _buildInfoPanel() {
    if (_currentStep == -1) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Text(
          "BOARD INITIALIZED",
          style: TextStyle(
            color: Colors.white.withOpacity(0.2),
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 12,
          ),
        ),
      );
    }

    final move = widget.history[_currentStep];
    final Color playerColor = move.playerID == PlayerID.player1
        ? AppConstants.player1Color
        : AppConstants.player2Color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Text(
            "MOVE ${_currentStep + 1} OF ${widget.history.length}",
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                move.playerName.toUpperCase(),
                style: TextStyle(
                  color: playerColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const Text(
                " PLACED ",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  move.letter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reconstructs the grid state based on moves up to [_currentStep]
  Widget _buildReplayGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.gridSize * widget.gridSize,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridSize,
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
      ),
      itemBuilder: (context, index) {
        MoveModel? cellMove;

        // Find if this cell was filled at or before the current step
        for (int i = 0; i <= _currentStep; i++) {
          if (widget.history[i].index == index) {
            cellMove = widget.history[i];
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border:
                Border.all(color: Colors.white.withOpacity(0.05), width: 0.2),
          ),
          child: Center(
            child: cellMove == null
                ? null
                : FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        cellMove.letter,
                        style: TextStyle(
                          color: cellMove.playerID == PlayerID.player1
                              ? AppConstants.player1Color
                              : AppConstants.player2Color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Bottom control bar to navigate through time
  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Jump to Start
        _btn(Icons.first_page_rounded, () {
          setState(() => _currentStep = -1);
        }),
        const SizedBox(width: 12),
        // Step Backward
        _btn(Icons.chevron_left_rounded, () {
          if (_currentStep > -1) setState(() => _currentStep--);
        }),
        const SizedBox(width: 24),
        // Step Forward
        _btn(Icons.chevron_right_rounded, () {
          if (_currentStep < widget.history.length - 1) {
            setState(() => _currentStep++);
          }
        }),
        const SizedBox(width: 12),
        // Jump to End
        _btn(Icons.last_page_rounded, () {
          setState(() => _currentStep = widget.history.length - 1);
        }),
      ],
    );
  }

  /// Reusable styled button for replay controls
  Widget _btn(IconData icon, VoidCallback tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(15),
          // Consistent 0.5 white border
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

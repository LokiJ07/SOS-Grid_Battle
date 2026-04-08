import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/cell_model.dart';
import '../models/sos_line.dart';
import '../game_logic/sos_detector.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/storage_service.dart';

class GameProvider extends ChangeNotifier {
  late List<CellModel> grid;
  late int gridSize;
  late Player player1;
  late Player player2;
  late Player currentPlayer;

  String selectedLetter = "S";
  bool isGameOver = false;
  List<SOSLine> sosLines = [];

  // Timer properties
  Timer? _timer;
  int? timerLimit; // null means "No Timer"
  int remainingSeconds = 0;

  GameProvider() {
    player1 =
        Player(id: PlayerID.player1, name: "Player 1", color: Colors.blue);
    player2 = Player(id: PlayerID.player2, name: "Player 2", color: Colors.red);
  }

  void initGame(int size, int? limit) {
    gridSize = size;
    timerLimit = limit;

    grid = List.generate(
        size * size,
        (index) => CellModel(
              index: index,
              row: index ~/ size,
              col: index % size,
            ));

    player1.reset(10);
    player2.reset(10);
    currentPlayer = player1;
    sosLines = [];
    isGameOver = false;

    _startNewTurnTimer();
    notifyListeners();
  }

  void _startNewTurnTimer() {
    _timer?.cancel();
    if (timerLimit == null) return;

    remainingSeconds = timerLimit!;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    _timer?.cancel();
    currentPlayer.lives--;

    VibrationService.vibrate();

    if (currentPlayer.lives <= 0) {
      _endGameByDeath();
    } else {
      _switchTurn();
      _startNewTurnTimer();
    }
    notifyListeners();
  }

  void playMove(int index) {
    if (isGameOver || !grid[index].isEmpty) return;

    grid[index].letter = selectedLetter;
    grid[index].placedBy = currentPlayer.id;

    SoundService.playSound('placement.mp3');

    List<SOSLine> newSOS = SOSDetector.checkNewSOS(grid, index, gridSize);

    if (newSOS.isNotEmpty) {
      currentPlayer.score += newSOS.length;
      sosLines.addAll(newSOS);
      for (var line in newSOS) {
        for (var idx in line.indices) {
          grid[idx].isPartOfSOS = true;
        }
      }
      SoundService.playSound('score.mp3');
      VibrationService.vibrate();
      // Player gets another turn - reset timer
      _startNewTurnTimer();
    } else {
      _switchTurn();
      _startNewTurnTimer();
    }

    _checkBoardFull();
    notifyListeners();
  }

  void _switchTurn() {
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;
  }

  void _checkBoardFull() {
    if (grid.every((cell) => !cell.isEmpty)) {
      _finishGame();
    }
  }

  void _endGameByDeath() {
    isGameOver = true;
    _finishGame();
  }

  void _finishGame() {
    _timer?.cancel();
    isGameOver = true;

    int winnerId = 0;
    if (player1.lives <= 0)
      winnerId = 2;
    else if (player2.lives <= 0)
      winnerId = 1;
    else if (player1.score > player2.score)
      winnerId = 1;
    else if (player2.score > player1.score) winnerId = 2;

    StorageService.recordWin(winnerId, player1.score, player2.score);
    SoundService.playSound('victory.mp3');
  }

  void selectLetter(String letter) {
    selectedLetter = letter;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

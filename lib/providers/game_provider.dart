import 'dart:async';
import 'dart:math';
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

  Timer? _timer;
  int? timerLimit;
  int remainingSeconds = 0;
  String lastEffectMessage = "";

  GameProvider() {
    player1 =
        Player(id: PlayerID.player1, name: "Player 1", color: Colors.blue);
    player2 = Player(id: PlayerID.player2, name: "Player 2", color: Colors.red);
    currentPlayer = player1;
  }

  void initGame(int size, int? limit) {
    gridSize = size;
    timerLimit = limit;
    lastEffectMessage = "";
    isGameOver = false;
    sosLines = [];
    selectedLetter = "S";

    final random = Random();
    grid = List.generate(size * size, (index) {
      final cell =
          CellModel(index: index, row: index ~/ size, col: index % size);

      double chance = random.nextDouble();
      if (chance < 0.10) {
        // 10% Mines
        cell.specialType = SpecialType.mine;
        cell.effectType = [
          EffectType.stun,
          EffectType.halfLife,
          EffectType.minusScore
        ][random.nextInt(3)];
      } else if (chance < 0.15) {
        // 5% Perks
        cell.specialType = SpecialType.perk;
        cell.effectType = [
          EffectType.drainOpponentLife,
          EffectType.drainOpponentScore
        ][random.nextInt(2)];
      }
      return cell;
    });

    player1.reset(10.0); // Lives as double for half-heart support
    player2.reset(10.0);
    currentPlayer = player1;

    _startNewTurnTimer();
    notifyListeners();
  }

  void playMove(int index) {
    if (isGameOver || !grid[index].isEmpty) return;

    final cell = grid[index];
    cell.letter = selectedLetter;
    cell.placedBy = currentPlayer.id;
    cell.isRevealed = true;

    // 1. Process Battle Effects
    _applyCellEffects(cell);

    // 2. Check for SOS
    List<SOSLine> newSOS =
        SOSDetector.checkNewSOS(grid, index, gridSize, currentPlayer.id);

    if (newSOS.isNotEmpty) {
      // Points with Streak Multiplier
      int points = newSOS.length * currentPlayer.streak;
      currentPlayer.score += points;
      currentPlayer.streak++; // Level up streak

      sosLines.addAll(newSOS);
      for (var line in newSOS) {
        for (var idx in line.indices) grid[idx].isPartOfSOS = true;
      }

      SoundService.playSound('score.mp3');
      VibrationService.vibrate();
      _startNewTurnTimer(); // Keep turn, reset timer
    } else {
      currentPlayer.streak = 1; // Reset streak on miss
      _switchTurn();
    }

    _checkGameOver();
    notifyListeners();
  }

  void _applyCellEffects(CellModel cell) {
    lastEffectMessage = "";
    final opponent = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    if (cell.specialType == SpecialType.mine) {
      VibrationService.vibrate();
      if (cell.effectType == EffectType.stun) {
        currentPlayer.isStunned = true;
        lastEffectMessage = "STUNNED! TURN SKIP NEXT";
      } else if (cell.effectType == EffectType.halfLife) {
        currentPlayer.lives =
            max(0.0, currentPlayer.lives - 0.5); // Literal half-life
        lastEffectMessage = "MINE! -0.5 HP";
      } else if (cell.effectType == EffectType.minusScore) {
        currentPlayer.score = max(0, currentPlayer.score - 1);
        lastEffectMessage = "MINE! -1 SCORE";
      }
    } else if (cell.specialType == SpecialType.perk) {
      SoundService.playSound('score.mp3');
      if (cell.effectType == EffectType.drainOpponentLife) {
        opponent.lives = max(0.0, opponent.lives - 0.5); // Drain half-life
        lastEffectMessage = "PERK! OPPONENT -0.5 HP";
      } else if (cell.effectType == EffectType.drainOpponentScore) {
        opponent.score = max(0, opponent.score - 1);
        lastEffectMessage = "PERK! OPPONENT -1 SCORE";
      }
    }
  }

  void _switchTurn() {
    _timer?.cancel();
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    if (currentPlayer.isStunned) {
      currentPlayer.isStunned = false;
      lastEffectMessage = "${currentPlayer.name} STUNNED: SKIPPED";
      _switchTurn();
      return;
    }
    _startNewTurnTimer();
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
    currentPlayer.lives = max(0.0, currentPlayer.lives - 1.0);
    currentPlayer.streak = 1;
    lastEffectMessage = "TIMEOUT! -1 HP";
    if (currentPlayer.lives <= 0)
      _checkGameOver();
    else
      _switchTurn();
    notifyListeners();
  }

  void _checkGameOver() {
    bool isGridFull = grid.every((cell) => !cell.isEmpty);
    bool playerDied = player1.lives <= 0 || player2.lives <= 0;

    if (isGridFull || playerDied) {
      isGameOver = true;
      _timer?.cancel();

      int winnerId = 0;
      if (player1.lives <= 0)
        winnerId = 2;
      else if (player2.lives <= 0)
        winnerId = 1;
      else if (player1.score > player2.score)
        winnerId = 1;
      else if (player2.score > player1.score) winnerId = 2;

      StorageService.recordWin(
          winnerId, player1.score, (player2.score).toInt());
      SoundService.playSound('victory.mp3');
    }
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

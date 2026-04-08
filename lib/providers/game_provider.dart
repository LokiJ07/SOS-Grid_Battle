import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/cell_model.dart';
import '../models/sos_line.dart';
import '../game_logic/sos_detector.dart';
import '../game_logic/ai_engine.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class GameProvider extends ChangeNotifier {
  late List<CellModel> grid;
  late int gridSize;
  late Player player1;
  late Player player2;
  late Player currentPlayer;

  String selectedLetter = "S";
  bool isGameOver = false;
  List<SOSLine> sosLines = [];
  int? lastMoveIndex;

  Timer? _timer;
  int? timerLimit;
  int remainingSeconds = 0;
  String lastEffectMessage = "";

  bool isVsAI = false;
  AIDifficulty aiDifficulty = AIDifficulty.moderate;
  bool isAiThinking = false;
  GameMode currentGameMode = GameMode.battle;

  GameProvider() {
    player1 =
        Player(id: PlayerID.player1, name: "Player 1", color: Colors.blue);
    player2 = Player(id: PlayerID.player2, name: "Computer", color: Colors.red);
    currentPlayer = player1;
  }

  void initGame(int size, int? limit,
      {bool vsAI = false,
      AIDifficulty diff = AIDifficulty.moderate,
      GameMode mode = GameMode.battle}) {
    gridSize = size;
    timerLimit = limit;
    isVsAI = vsAI;
    aiDifficulty = diff;
    currentGameMode = mode;
    isAiThinking = false;
    lastEffectMessage = "";
    isGameOver = false;
    sosLines = [];
    selectedLetter = "S";
    lastMoveIndex = null;

    final random = Random();
    grid = List.generate(size * size, (index) {
      final cell =
          CellModel(index: index, row: index ~/ size, col: index % size);
      if (mode == GameMode.battle) {
        double chance = random.nextDouble();
        if (chance < 0.10) {
          cell.specialType = SpecialType.mine;
          cell.effectType = [
            EffectType.stun,
            EffectType.halfLife,
            EffectType.minusScore
          ][random.nextInt(3)];
        } else if (chance < 0.15) {
          cell.specialType = SpecialType.perk;
          cell.effectType = [
            EffectType.drainOpponentLife,
            EffectType.drainOpponentScore
          ][random.nextInt(2)];
        }
      }
      return cell;
    });

    player1.reset(10.0);
    player2.reset(10.0);
    player2 = Player(
        id: PlayerID.player2,
        name: vsAI ? "Computer" : "Player 2",
        color: Colors.red);

    currentPlayer = player1;
    _startNewTurnTimer();
    notifyListeners();
  }

  void playMove(int index) {
    // Prevent moves if game is over, AI is thinking, or cell is full
    if (isGameOver || isAiThinking || !grid[index].isEmpty) return;

    _executeMove(index);

    // After human move, if it's now the AI's turn, trigger it
    if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
      _triggerAITurn();
    }
  }

  Future<void> _triggerAITurn() async {
    // 1. Check if AI is stunned BEFORE thinking
    if (currentPlayer.isStunned) {
      await Future.delayed(const Duration(milliseconds: 1000));
      currentPlayer.isStunned = false;
      lastEffectMessage = "COMPUTER IS STUNNED! SKIP TURN";
      _switchTurn();
      notifyListeners();
      return;
    }

    isAiThinking = true;
    notifyListeners();

    // AI thinking delay
    await Future.delayed(Duration(milliseconds: 800 + Random().nextInt(500)));

    final bestMove = AIEngine.computeBestMove(grid, gridSize, aiDifficulty);
    if (bestMove.isNotEmpty) {
      selectedLetter = bestMove["letter"];
      _executeMove(bestMove["index"]);
    }

    isAiThinking = false;
    notifyListeners();
  }

  void _executeMove(int index) {
    lastMoveIndex = index;
    final cell = grid[index];
    cell.letter = selectedLetter;
    cell.placedBy = currentPlayer.id;
    cell.isRevealed = true;

    _applyCellEffects(cell);

    List<SOSLine> newSOS =
        SOSDetector.checkNewSOS(grid, index, gridSize, currentPlayer.id);

    if (newSOS.isNotEmpty) {
      // SCORING: Streak 4 = x2, Streak 5 = x3
      int multiplier =
          currentPlayer.streak >= 4 ? (currentPlayer.streak - 2) : 1;
      int pointsEarned = newSOS.length * multiplier;

      currentPlayer.score += pointsEarned;
      currentPlayer.streak++;

      for (var line in newSOS) {
        sosLines.add(line);
        for (var idx in line.indices) grid[idx].isPartOfSOS = true;
      }

      SoundService.playSound('score.mp3');
      VibrationService.vibrate();

      // Bonus turn logic: Reset timer but don't switch players
      _startNewTurnTimer();

      // If AI scored, it triggers another move
      if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
        _triggerAITurn();
      }
    } else {
      currentPlayer.streak = 1;
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
        lastEffectMessage =
            "${currentPlayer.name.toUpperCase()} HIT A STUN MINE!";
      } else if (cell.effectType == EffectType.halfLife) {
        currentPlayer.lives = max(0.0, currentPlayer.lives - 0.5);
        lastEffectMessage = "MINE! ${currentPlayer.name.toUpperCase()} -0.5 HP";
      } else if (cell.effectType == EffectType.minusScore) {
        currentPlayer.score = max(0, currentPlayer.score - 1);
        lastEffectMessage =
            "MINE! ${currentPlayer.name.toUpperCase()} -1 SCORE";
      }
    } else if (cell.specialType == SpecialType.perk) {
      if (cell.effectType == EffectType.drainOpponentLife) {
        opponent.lives = max(0.0, opponent.lives - 0.5);
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

    // If it's the Human's turn and they are stunned, skip them
    if (currentPlayer.id == PlayerID.player1 && currentPlayer.isStunned) {
      currentPlayer.isStunned = false;
      lastEffectMessage = "YOU ARE STUNNED! SKIP TURN";
      _switchTurn();
      return;
    }

    // For AI, the skip is handled inside _triggerAITurn to prevent logic loops
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
    lastEffectMessage = "${currentPlayer.name.toUpperCase()} TIMEOUT! -1 HP";

    if (currentPlayer.lives <= 0) {
      _checkGameOver();
    } else {
      _switchTurn();
      // If computer was waiting for turn and human timed out, trigger AI
      if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
        _triggerAITurn();
      }
    }
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
      StorageService.recordWin(winnerId, player1.score, player2.score.toInt());
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

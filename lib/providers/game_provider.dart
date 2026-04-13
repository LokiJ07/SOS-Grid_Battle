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
  Timer? _notifTimer; // Timer for clearing notifications
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

  /// Initializes the game state
  void initGame(int size, int? limit,
      {bool vsAI = false,
      AIDifficulty diff = AIDifficulty.moderate,
      GameMode mode = GameMode.battle}) {
    gridSize = size;
    timerLimit = limit;
    isVsAI = vsAI;
    aiDifficulty = diff;
    currentGameMode = mode;
    isGameOver = false;
    sosLines = [];
    selectedLetter = "S";
    lastMoveIndex = null;
    lastEffectMessage = "BATTLE START!";

    // 1. Generate empty grid
    grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    // 2. Populate Battle Mode Items (Mines/Perks)
    if (mode == GameMode.battle) {
      _generateBattleItems(size);
    }

    // 3. Setup Players
    player1.reset(10.0);
    player2 = Player(
        id: PlayerID.player2,
        name: vsAI ? "Computer" : "Player 2",
        color: Colors.red);
    player2.reset(10.0);

    currentPlayer = player1;

    _startNewTurnTimer();
    _showNotification("GAME START!", 2);
    notifyListeners();
  }

  void _generateBattleItems(int size) {
    final random = Random();
    int totalCells = size * size;
    // 15% density for battle items
    int itemCount = (totalCells * 0.15).clamp(2, 200).toInt();
    List<int> availableIndices = List.generate(totalCells, (i) => i)..shuffle();

    List<EffectType> mines = [
      EffectType.stun,
      EffectType.halfLife,
      EffectType.minusScore,
      EffectType.theGreatSwap,
      EffectType.streakReset,
      EffectType.poison,
      EffectType.vampireTrap,
      EffectType.bombRadius,
      EffectType.timePressure,
      EffectType.scoreWipe
    ];
    List<EffectType> perks = [
      EffectType.drainOpponentLife,
      EffectType.drainOpponentScore,
      EffectType.lifeSteal,
      EffectType.extraHeart,
      EffectType.comboBooster,
      EffectType.jackpot,
      EffectType.shield,
      EffectType.revealRadius,
      EffectType.doublePoints,
      EffectType.timerBonus
    ];

    for (int i = 0; i < itemCount; i++) {
      int idx = availableIndices[i];
      bool isMine = random.nextBool();
      grid[idx].specialType = isMine ? SpecialType.mine : SpecialType.perk;
      grid[idx].effectType = isMine
          ? mines[random.nextInt(mines.length)]
          : perks[random.nextInt(perks.length)];
    }
  }

  /// Triggered when a player taps a cell
  void playMove(int index) {
    if (isGameOver || isAiThinking || !grid[index].isEmpty) return;
    _executeMove(index);

    if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
      _triggerAITurn();
    }
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
      // Streak Multiplier: Streak 4 = x2, 5 = x3, etc.
      int mult = currentPlayer.streak >= 4 ? (currentPlayer.streak - 2) : 1;
      currentPlayer.score += newSOS.length * mult;
      currentPlayer.streak++;

      for (var line in newSOS) {
        sosLines.add(line);
        for (var idx in line.indices) grid[idx].isPartOfSOS = true;
      }

      SoundService.playSound('score.mp3');
      VibrationService.vibrate();
      _startNewTurnTimer(); // Bonus Turn: Reset timer but don't switch players

      // If AI scored, it continues its turn
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
    if (cell.specialType == SpecialType.none) return;

    // SHIELD LOGIC: Blocks mines
    if (cell.specialType == SpecialType.mine && currentPlayer.hasShield) {
      currentPlayer.hasShield = false;
      _showNotification("SHIELD BLOCKED MINE!", 3);
      return;
    }

    final opponent = (currentPlayer.id == PlayerID.player1) ? player2 : player1;
    VibrationService.vibrate();

    switch (cell.effectType) {
      case EffectType.theGreatSwap:
        int stolen = (currentPlayer.score / 2).floor();
        currentPlayer.score -= stolen;
        opponent.score += stolen;
        _showNotification("SCORE SWAP TRIGGERED!", 3);
        break;
      case EffectType.stun:
        currentPlayer.isStunned = true;
        _showNotification("${currentPlayer.name} STUNNED!", 3);
        break;
      case EffectType.halfLife:
        currentPlayer.lives = max(0.0, currentPlayer.lives - 0.5);
        _showNotification("MINE: -0.5 HP", 2);
        break;
      case EffectType.jackpot:
        currentPlayer.score += 5;
        _showNotification("JACKPOT: +5 SCORE!", 2);
        break;
      case EffectType.extraHeart:
        currentPlayer.lives = min(10.0, currentPlayer.lives + 2.0);
        _showNotification("RECOVERED +2 HP", 2);
        break;
      case EffectType.shield:
        currentPlayer.hasShield = true;
        _showNotification("SHIELD ACTIVATED!", 2);
        break;
      case EffectType.revealRadius:
        _showNotification("AREA REVEALED!", 2);
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = cell.row + dr, nc = cell.col + dc;
            if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
              grid[nr * gridSize + nc].isRevealed = true;
            }
          }
        }
        break;
      case EffectType.poison:
        currentPlayer.lives = max(0.0, currentPlayer.lives - 1.5);
        _showNotification("POISONED: -1.5 HP", 2);
        break;
      case EffectType.lifeSteal:
        currentPlayer.lives = min(10.0, currentPlayer.lives + 1.0);
        opponent.lives = max(0.0, opponent.lives - 1.0);
        _showNotification("LIFE STEAL!", 2);
        break;
      default:
        _showNotification("ITEM TRIGGERED!", 2);
    }
  }

  void _showNotification(String msg, int seconds) {
    _notifTimer?.cancel();
    lastEffectMessage = msg;
    notifyListeners();
    _notifTimer = Timer(Duration(seconds: seconds), () {
      lastEffectMessage = "";
      notifyListeners();
    });
  }

  Future<void> _triggerAITurn() async {
    if (isGameOver) return;

    // Check for AI Stun
    if (currentPlayer.isStunned) {
      isAiThinking = true; // Visual feedback
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 1500));
      currentPlayer.isStunned = false;
      _showNotification("COMPUTER STUNNED: SKIPPING", 2);
      isAiThinking = false;
      _switchTurn();
      return;
    }

    isAiThinking = true;
    notifyListeners();

    // AI "Thinking" delay
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(600)));

    final best = AIEngine.computeBestMove(grid, gridSize, aiDifficulty);
    if (best.isNotEmpty) {
      selectedLetter = best["letter"];
      _executeMove(best["index"]);
    }

    isAiThinking = false;
    notifyListeners();
  }

  void _switchTurn() {
    _timer?.cancel();
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    // Human Stun Check
    if (currentPlayer.id == PlayerID.player1 && currentPlayer.isStunned) {
      currentPlayer.isStunned = false;
      _showNotification("YOU ARE STUNNED: SKIPPING", 2);
      _switchTurn();
      return;
    }

    _startNewTurnTimer();
  }

  void _startNewTurnTimer() {
    _timer?.cancel();
    if (timerLimit == null) return;
    remainingSeconds = timerLimit!;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
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
    _showNotification("${currentPlayer.name} TIMEOUT: -1 HP", 2);

    if (currentPlayer.lives <= 0) {
      _checkGameOver();
    } else {
      _switchTurn();
      if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
        _triggerAITurn();
      }
    }
    notifyListeners();
  }

  void _checkGameOver() {
    bool full = grid.every((c) => !c.isEmpty);
    bool dead = player1.lives <= 0 || player2.lives <= 0;

    if (full || dead) {
      isGameOver = true;
      _timer?.cancel();
      _notifTimer?.cancel();

      int winId = 0;
      if (player1.lives <= 0)
        winId = 2;
      else if (player2.lives <= 0)
        winId = 1;
      else if (player1.score > player2.score)
        winId = 1;
      else if (player2.score > player1.score) winId = 2;

      StorageService.recordWin(winId, player1.score, player2.score.toInt());
      SoundService.playSound('victory.mp3');
    }
  }

  void selectLetter(String l) {
    selectedLetter = l;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notifTimer?.cancel();
    super.dispose();
  }
}

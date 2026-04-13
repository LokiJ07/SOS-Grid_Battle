import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/cell_model.dart';
import '../models/sos_line.dart';
import '../models/move_model.dart';
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
  bool isAnimating = false;
  List<SOSLine> sosLines = [];
  List<MoveModel> matchHistory = [];
  int? lastMoveIndex;

  Timer? _timer;
  int? timerLimit;
  int remainingSeconds = 0;
  String lastEffectMessage = "";
  IconData? lastEffectIcon;

  bool isVsAI = false;
  AIDifficulty aiDifficulty = AIDifficulty.moderate;
  bool isAiThinking = false;
  bool _isProcessing = false;
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
    isGameOver = false;
    isAnimating = false;
    isAiThinking = false;
    _isProcessing = false;
    sosLines = [];
    matchHistory = [];
    selectedLetter = "S";
    lastMoveIndex = null;
    lastEffectMessage = "";

    grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    if (mode == GameMode.battle) {
      _generateBattleItems(size);
    }

    player1.reset(10.0);
    player2 = Player(
        id: PlayerID.player2,
        name: vsAI ? "Computer" : "Player 2",
        color: Colors.red);
    player2.reset(10.0);

    currentPlayer = player1;
    _startNewTurnTimer();
    notifyListeners();
  }

  void _generateBattleItems(int size) {
    final random = Random();
    int count = (size * size * 0.15).clamp(2, 200).toInt();
    List<int> available = List.generate(size * size, (i) => i)..shuffle();

    for (int i = 0; i < count; i++) {
      int idx = available[i];
      bool isMine = random.nextBool();
      grid[idx].specialType = isMine ? SpecialType.mine : SpecialType.perk;

      // Select from the first 20 effects (excluding 'none')
      grid[idx].effectType = EffectType.values[random.nextInt(20)];
    }
  }

  void playMove(int index) {
    if (isGameOver ||
        isAiThinking ||
        isAnimating ||
        _isProcessing ||
        !grid[index].isEmpty) return;
    if (isVsAI && currentPlayer.id == PlayerID.player2) return;
    _handleMoveSequence(index);
  }

  Future<void> _handleMoveSequence(int index) async {
    _isProcessing = true;
    bool scored = await _executeMoveLogic(index);
    if (!isGameOver && isVsAI && currentPlayer.id == PlayerID.player2) {
      _isProcessing = false;
      _triggerAITurn();
    } else {
      _isProcessing = false;
    }
    notifyListeners();
  }

  Future<bool> _executeMoveLogic(int index) async {
    lastMoveIndex = index;
    final cell = grid[index];
    cell.letter = selectedLetter;
    cell.placedBy = currentPlayer.id;
    cell.isRevealed = true;

    matchHistory.add(MoveModel(
      index: index,
      letter: selectedLetter,
      playerID: currentPlayer.id,
      playerName: currentPlayer.name,
    ));

    _timer?.cancel();

    if (cell.specialType != SpecialType.none) {
      await _applyCellEffects(cell);
    }

    if (isGameOver) return false;

    List<SOSLine> newSOS =
        SOSDetector.checkNewSOS(grid, index, gridSize, currentPlayer.id);

    if (newSOS.isNotEmpty) {
      int mult = currentPlayer.streak >= 4 ? (currentPlayer.streak - 2) : 1;
      currentPlayer.score += (newSOS.length * mult);
      double soundSpeed = (1.0 + (currentPlayer.streak * 0.15)).clamp(1.0, 2.5);
      SoundService.playSound('score.mp3', speed: soundSpeed);
      VibrationService.vibrate();

      currentPlayer.streak++;
      for (var line in newSOS) {
        // Create line and tag it with the current move number
        final taggedLine = SOSLine(
            indices: line.indices,
            owner: currentPlayer.id,
            moveIndex: matchHistory.length - 1);
        sosLines.add(taggedLine);
        for (var idx in line.indices) grid[idx].isPartOfSOS = true;
      }
      _startNewTurnTimer();
      notifyListeners();
      return true;
    } else {
      SoundService.playSound('placement.mp3');
      currentPlayer.streak = 1;
      _switchTurn();
      notifyListeners();
      return false;
    }
  }

  Future<void> _applyCellEffects(CellModel cell) async {
    isAnimating = true;
    final opponent = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    if (cell.specialType == SpecialType.mine && currentPlayer.hasShield) {
      currentPlayer.hasShield = false;
      await _showBattleAnimation("SHIELD BLOCKED!", Icons.security);
      isAnimating = false;
      return;
    }

    String msg = "";
    IconData icon = Icons.bolt;

    switch (cell.effectType) {
      case EffectType.stun:
        currentPlayer.isStunned = true;
        msg = "STUNNED! SKIP TURN";
        icon = Icons.timer_off;
        break;
      case EffectType.halfLife:
        currentPlayer.lives -= 0.5;
        msg = "HALF-LIFE! -0.5 HP";
        icon = Icons.heart_broken;
        break;
      case EffectType.minusScore:
        currentPlayer.score -= 2;
        msg = "-2 SCORE LOSS";
        icon = Icons.trending_down;
        break;
      case EffectType.theGreatSwap:
        int stolen = (currentPlayer.score / 2).floor();
        currentPlayer.score -= stolen;
        opponent.score += stolen;
        msg = "THE GREAT SWAP!";
        icon = Icons.swap_horizontal_circle;
        break;
      case EffectType.streakReset:
        currentPlayer.streak = 1;
        msg = "STREAK RESET!";
        icon = Icons.layers_clear;
        break;
      case EffectType.poison:
        currentPlayer.lives -= 1.5;
        msg = "POISONED! -1.5 HP";
        icon = Icons.biotech;
        break;
      case EffectType.vampireTrap:
        currentPlayer.lives -= 1.0;
        opponent.lives += 1.0;
        msg = "VAMPIRE TRAP!";
        icon = Icons.bloodtype;
        break;
      case EffectType.bombRadius:
        currentPlayer.score -= 3;
        msg = "BOMB EXPLOSION!";
        icon = Icons.settings_input_antenna;
        break;
      case EffectType.timePressure:
        remainingSeconds = (remainingSeconds / 2).floor();
        msg = "TIME PRESSURE!";
        icon = Icons.speed;
        break;
      case EffectType.scoreWipe:
        currentPlayer.score -= 5;
        msg = "SCORE WIPE! -5";
        icon = Icons.delete_forever;
        break;
      case EffectType.drainOpponentLife:
        opponent.lives -= 1.0;
        msg = "ENEMY -1 HP";
        icon = Icons.heart_broken_outlined;
        break;
      case EffectType.drainOpponentScore:
        opponent.score -= 2;
        msg = "ENEMY -2 SCORE";
        icon = Icons.money_off;
        break;
      case EffectType.lifeSteal:
        currentPlayer.lives += 1.0;
        opponent.lives -= 1.0;
        msg = "LIFE STEAL!";
        icon = Icons.health_and_safety;
        break;
      case EffectType.extraHeart:
        currentPlayer.lives += 2.0;
        msg = "EXTRA HEART! +2 HP";
        icon = Icons.add_box;
        break;
      case EffectType.comboBooster:
        currentPlayer.streak += 3;
        msg = "STREAK BOOSTER +3";
        icon = Icons.rocket_launch;
        break;
      case EffectType.jackpot:
        currentPlayer.score += 5;
        msg = "JACKPOT! +5 SCORE";
        icon = Icons.stars;
        break;
      case EffectType.shield:
        currentPlayer.hasShield = true;
        msg = "SHIELD EQUIPPED";
        icon = Icons.shield;
        break;
      case EffectType.revealRadius:
        msg = "AREA REVEALED";
        icon = Icons.visibility;
        _revealNearby(cell.row, cell.col);
        break;
      case EffectType.doublePoints:
        currentPlayer.score += 2;
        msg = "DOUBLE POINTS!";
        icon = Icons.looks_two;
        break;
      case EffectType.timerBonus:
        remainingSeconds += 10;
        msg = "TIMER BONUS +10S";
        icon = Icons.more_time;
        break;
      case EffectType.none:
        msg = "ITEM FOUND!";
        icon = Icons.bolt;
        break;
    }

    VibrationService.vibrate();
    notifyListeners();
    await _showBattleAnimation(msg, icon);
    isAnimating = false;
  }

  void _revealNearby(int r, int c) {
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        int nr = r + dr, nc = c + dc;
        if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
          grid[nr * gridSize + nc].isRevealed = true;
        }
      }
    }
  }

  Future<void> _showBattleAnimation(String msg, IconData icon) async {
    lastEffectMessage = msg;
    lastEffectIcon = icon;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 2000));
    lastEffectMessage = "";
    lastEffectIcon = null;
    notifyListeners();
  }

  Future<void> _triggerAITurn() async {
    if (isGameOver || isAiThinking) return;
    isAiThinking = true;
    notifyListeners();

    while (!isGameOver && currentPlayer.id == PlayerID.player2) {
      if (currentPlayer.isStunned) {
        await Future.delayed(const Duration(milliseconds: 1000));
        currentPlayer.isStunned = false;
        await _showBattleAnimation("COMPUTER STUNNED!", Icons.timer_off);
        _switchTurn();
        break;
      }
      await Future.delayed(
          Duration(milliseconds: 1000 + Random().nextInt(500)));
      final best = AIEngine.computeBestMove(grid, gridSize, aiDifficulty);
      if (best.isNotEmpty) {
        selectedLetter = best["letter"];
        bool scoredAgain = await _executeMoveLogic(best["index"]);
        if (scoredAgain && !isGameOver)
          await Future.delayed(const Duration(milliseconds: 800));
      } else
        break;
    }
    isAiThinking = false;
    _checkGameOver();
    notifyListeners();
  }

  void _switchTurn() {
    _timer?.cancel();
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;
    if (currentPlayer.id == PlayerID.player1 && currentPlayer.isStunned) {
      currentPlayer.isStunned = false;
      _showBattleAnimation("YOU ARE STUNNED!", Icons.timer_off)
          .then((_) => _switchTurn());
      return;
    }
    _startNewTurnTimer();
  }

  void _startNewTurnTimer() {
    _timer?.cancel();
    if (timerLimit == null || isAnimating || isAiThinking) return;
    remainingSeconds = timerLimit!;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else
        _handleTimeout();
    });
  }

  void _handleTimeout() {
    currentPlayer.lives -= 1.0;
    currentPlayer.streak = 1;
    _showBattleAnimation("TIMEOUT: -1 HP", Icons.hourglass_disabled).then((_) {
      if (currentPlayer.lives <= 0)
        _checkGameOver();
      else
        _switchTurn();
    });
  }

  void _checkGameOver() {
    bool full = grid.every((c) => !c.isEmpty);
    bool dead = player1.lives <= 0 || player2.lives <= 0;
    if (full || dead) {
      isGameOver = true;
      _timer?.cancel();
      int winId = (player1.lives <= 0)
          ? 2
          : (player2.lives <= 0
              ? 1
              : (player1.score > player2.score
                  ? 1
                  : (player2.score > player1.score ? 2 : 0)));
      String resText = winId == 1
          ? "Player 1 Wins"
          : (winId == 2 ? "${player2.name} Wins" : "Draw");
      StorageService.saveMatchToArchive(
          history: matchHistory,
          sosLines: sosLines,
          gridSize: gridSize,
          result: resText);
      StorageService.recordWin(winId, player1.score, player2.score.toInt());
      SoundService.playSound('victory.mp3');
    }
  }

  void selectLetter(String l) {
    if (!isAiThinking && !isAnimating) {
      selectedLetter = l;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

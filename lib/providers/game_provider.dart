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
  // --- Core Game State ---
  late List<CellModel> grid;
  late int gridSize;
  late Player player1;
  late Player player2;
  late Player currentPlayer;

  // --- Match Logic Flags ---
  String selectedLetter = "S";
  bool isGameOver = false;
  bool isAnimating = false; // Blocks input during battle effects
  bool isAiThinking = false; // Blocks input during Computer Turn
  bool _isProcessing = false; // Internal lock for move sequence
  int shakeTrigger = 0; // Increments to trigger board shake

  // --- Match Data ---
  List<SOSLine> sosLines = [];
  List<MoveModel> matchHistory = [];
  int? lastMoveIndex;

  // --- Timers & Sabotage ---
  Timer? _timer;
  int? timerLimit;
  int remainingSeconds = 0;
  bool _nextTurnHalfTime = false; // For the Time Pressure sabotage mine

  // --- UI Notifications ---
  String lastEffectMessage = "";
  IconData? lastEffectIcon;

  // --- Settings & Mode ---
  bool isVsAI = false;
  AIDifficulty aiDifficulty = AIDifficulty.moderate;
  GameMode currentGameMode = GameMode.battle;

  GameProvider() {
    player1 =
        Player(id: PlayerID.player1, name: "Player 1", color: Colors.blue);
    player2 = Player(id: PlayerID.player2, name: "Computer", color: Colors.red);
    currentPlayer = player1;
  }

  /// Initializes a new game session with all features enabled
  void initGame(int size, int? limit,
      {bool vsAI = false,
      AIDifficulty diff = AIDifficulty.moderate,
      GameMode mode = GameMode.battle}) {
    gridSize = size;
    timerLimit = limit;
    isVsAI = vsAI;
    aiDifficulty = diff;
    currentGameMode = mode;

    // Reset Logic Flags
    isGameOver = false;
    isAnimating = false;
    isAiThinking = false;
    _isProcessing = false;
    _nextTurnHalfTime = false;
    shakeTrigger = 0;

    // Reset Data Storage
    sosLines = [];
    matchHistory = [];
    selectedLetter = "S";
    lastMoveIndex = null;
    lastEffectMessage = "";

    // Generate Fresh Grid
    grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    // Populate Battle Items with 15% density
    if (mode == GameMode.battle) {
      _generateBattleItems(size);
    }

    // Initialize Players (Supports over-healing and inventory)
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

  /// Randomly scatters a mix of the 20 unique battle effects
  void _generateBattleItems(int size) {
    final random = Random();
    int totalCells = size * size;
    int count = (totalCells * 0.15).clamp(2, 200).toInt();
    List<int> available = List.generate(totalCells, (i) => i)..shuffle();

    for (int i = 0; i < count; i++) {
      int idx = available[i];
      bool isMine = random.nextBool();
      grid[idx].specialType = isMine ? SpecialType.mine : SpecialType.perk;
      // Pull randomly from all 20 types defined in EffectType enum
      grid[idx].effectType = EffectType.values[random.nextInt(20)];
    }
  }

  /// Main player input handler
  void playMove(int index) {
    // GUARD: Reject if busy, game over, or not player's turn
    if (isGameOver ||
        isAiThinking ||
        isAnimating ||
        _isProcessing ||
        !grid[index].isEmpty) return;
    if (isVsAI && currentPlayer.id == PlayerID.player2) return;

    _handleMoveSequence(index);
  }

  /// Orchestrates the async sequence of a single move
  Future<void> _handleMoveSequence(int index) async {
    _isProcessing = true;

    bool scored = await _executeMoveLogic(index);

    // Check if the board became full during this move
    if (_checkGameOver()) {
      _isProcessing = false;
      return;
    }

    // AI Trigger Failsafe: Trigger AI if it's now their turn
    if (isVsAI && currentPlayer.id == PlayerID.player2) {
      _isProcessing = false;
      _triggerAITurn();
    } else {
      _isProcessing = false;
    }
    notifyListeners();
  }

  /// Detailed move execution: Records history, resolves items, checks SOS
  Future<bool> _executeMoveLogic(int index) async {
    lastMoveIndex = index;
    final cell = grid[index];
    cell.letter = selectedLetter;
    cell.placedBy = currentPlayer.id;
    cell.isRevealed = true;

    // Permanent Record for Replay System
    matchHistory.add(MoveModel(
      index: index,
      letter: selectedLetter,
      playerID: currentPlayer.id,
      playerName: currentPlayer.name,
    ));

    _timer?.cancel(); // Pause clock during resolution

    // 1. Resolve Special Items (Mines/Perks)
    if (cell.specialType != SpecialType.none) {
      await _applyCellEffects(cell);
    }

    if (_checkGameOver()) return false;

    // 2. SOS Detection logic
    List<SOSLine> newSOS =
        SOSDetector.checkNewSOS(grid, index, gridSize, currentPlayer.id);

    if (newSOS.isNotEmpty) {
      _triggerShake(); // Physical impact feedback

      // Combo Math: Streak 4 = x2, 5 = x3, 6 = x4...
      int mult = currentPlayer.streak >= 4 ? (currentPlayer.streak - 2) : 1;
      currentPlayer.score += (newSOS.length * mult);

      // Streak-based sound speed
      double soundSpeed = (1.0 + (currentPlayer.streak * 0.15)).clamp(1.0, 2.5);
      SoundService.playSound('score.mp3', speed: soundSpeed);
      VibrationService.vibrate();

      currentPlayer.streak++;

      for (var line in newSOS) {
        final tagged = SOSLine(
            indices: line.indices,
            owner: currentPlayer.id,
            moveIndex: matchHistory.length - 1);
        sosLines.add(tagged);
        for (var idx in line.indices) grid[idx].isPartOfSOS = true;
      }

      if (_checkGameOver()) return true;

      _startNewTurnTimer(); // Reset timer for bonus turn
      notifyListeners();
      return true; // Extra turn granted
    } else {
      SoundService.playSound('placement.mp3');
      currentPlayer.streak = 1; // Reset multiplier on miss
      _switchTurn();
      notifyListeners();
      return false; // Turn ended
    }
  }

  /// FULL IMPLEMENTATION: Logic for all 20 unique battle effects
  Future<void> _applyCellEffects(CellModel cell) async {
    isAnimating = true;
    final opponent = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    // Shield Mechanic: Consumes shield and cancels mine
    if (cell.specialType == SpecialType.mine && currentPlayer.hasShield) {
      currentPlayer.hasShield = false;
      await _showBattleAnimation("SHIELD BLOCKED MINE!", Icons.security);
      isAnimating = false;
      return;
    }

    if (cell.specialType == SpecialType.mine) _triggerShake();

    String msg = "";
    IconData icon = Icons.bolt;

    switch (cell.effectType) {
      // --- 10 MINES (TRAPS) ---
      case EffectType.stun:
        currentPlayer.isStunned = true;
        msg = "STUNNED! SKIP TURN";
        icon = Icons.timer_off;
        break;
      case EffectType.halfLife:
        currentPlayer.lives -= 0.5; // Supports Negatives
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
        msg = "BOMB EXPLOSION! -3";
        icon = Icons.settings_input_antenna;
        break;
      case EffectType.timePressure:
        _nextTurnHalfTime = true; // Sabotage opponent next turn
        msg = "SABOTAGE: HALF TIME";
        icon = Icons.speed;
        break;
      case EffectType.scoreWipe:
        currentPlayer.score -= 5;
        msg = "SCORE WIPE! -5";
        icon = Icons.delete_forever;
        break;

      // --- 10 PERKS (POWER-UPS) ---
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
        currentPlayer.lives += 2.0; // Unlimited Over-heal
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
        currentPlayer.inventory.add(EffectType.revealRadius); // Tactical skill
        msg = "TACTICAL INTEL EARNED";
        icon = Icons.psychology_alt;
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

      default:
        break;
    }

    VibrationService.vibrate();
    notifyListeners(); // Update ScoreBoard immediately
    await _showBattleAnimation(msg, icon);
    isAnimating = false;
  }

  /// Automated Computer Intelligence processing loop
  Future<void> _triggerAITurn() async {
    if (isGameOver || isAiThinking) return;
    isAiThinking = true;
    notifyListeners();

    while (!isGameOver && currentPlayer.id == PlayerID.player2) {
      // 1. AI Stun Check
      if (currentPlayer.isStunned) {
        await Future.delayed(const Duration(milliseconds: 1000));
        currentPlayer.isStunned = false;
        await _showBattleAnimation("COMPUTER STUNNED!", Icons.timer_off);
        _switchTurn();
        break;
      }

      // 2. Artificial thinking delay for visibility
      await Future.delayed(
          Duration(milliseconds: 1000 + Random().nextInt(500)));

      // 3. Compute optimal move based on set difficulty
      final best = AIEngine.computeBestMove(grid, gridSize, aiDifficulty);
      if (best.isNotEmpty) {
        selectedLetter = best["letter"];
        bool scored = await _executeMoveLogic(best["index"]);
        if (isGameOver) break;
        // Brief pause between AI combo moves so player can follow along
        if (scored) await Future.delayed(const Duration(milliseconds: 800));
      } else
        break;
    }

    isAiThinking = false;
    _checkGameOver();
    notifyListeners();
  }

  /// Logic for the Tactical Intel Scan skill
  Future<void> useScanSkill(EffectType target) async {
    isAnimating = true;
    _timer?.cancel();
    bool found = false;
    for (var cell in grid) {
      if (cell.effectType == target && !cell.isRevealed) {
        cell.isRevealed = true;
        found = true;
      }
    }
    currentPlayer.inventory.remove(EffectType.revealRadius);
    await _showBattleAnimation(found ? "SCAN SUCCESSFUL!" : "SCAN FAILED",
        found ? Icons.radar : Icons.search_off);
    isAnimating = false;

    // Resume flow
    _startNewTurnTimer();
    if (isVsAI && currentPlayer.id == PlayerID.player2) _triggerAITurn();
    notifyListeners();
  }

  /// Switches active player and handles stun skips
  void _switchTurn() {
    _timer?.cancel();
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;

    // Stun logic: If the next player is stunned, skip them recursively
    if (currentPlayer.isStunned) {
      currentPlayer.isStunned = false;
      _showBattleAnimation(
              "${currentPlayer.name.toUpperCase()} STUNNED!", Icons.timer_off)
          .then((_) {
        _switchTurn();
      });
      return;
    }

    // Failsafe: Trigger AI if it's their turn
    if (isVsAI && currentPlayer.id == PlayerID.player2 && !isGameOver) {
      _triggerAITurn();
    }

    _startNewTurnTimer();
    notifyListeners();
  }

  /// Handles the turn countdown timer and sabotage effects
  void _startNewTurnTimer() {
    _timer?.cancel();
    if (timerLimit == null || isAnimating || isAiThinking) return;

    int baseTime = timerLimit!;
    // Apply sabotage if Time Pressure mine was hit previously
    if (_nextTurnHalfTime) {
      baseTime = (baseTime / 2).floor().clamp(3, 30);
      _nextTurnHalfTime = false;
    }

    remainingSeconds = baseTime;
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
    currentPlayer.lives -= 1.0;
    currentPlayer.streak = 1;
    _showBattleAnimation("${currentPlayer.name.toUpperCase()} TIMEOUT!",
            Icons.hourglass_disabled)
        .then((_) {
      if (!_checkGameOver()) _switchTurn();
    });
  }

  /// Global end-of-game monitor
  bool _checkGameOver() {
    bool isBoardFull = grid.every((c) => !c.isEmpty);
    bool isAnyoneDead = player1.lives <= 0 || player2.lives <= 0;

    if (isBoardFull || isAnyoneDead) {
      isGameOver = true;
      _timer?.cancel();

      int winId = 0;
      if (player1.lives <= 0)
        winId = 2;
      else if (player2.lives <= 0)
        winId = 1;
      else if (player1.score > player2.score)
        winId = 1;
      else if (player2.score > player1.score) winId = 2;

      String res = winId == 1
          ? "Player 1 Wins"
          : (winId == 2 ? "${player2.name} Wins" : "Draw");

      // AUTO SAVE DATA PERMANENTLY
      StorageService.saveMatchToArchive(
          history: matchHistory,
          sosLines: sosLines,
          gridSize: gridSize,
          result: res);
      StorageService.recordWin(winId, player1.score, player2.score.toInt());
      SoundService.playSound('victory.mp3');
      notifyListeners();
      return true;
    }
    return false;
  }

  void _triggerShake() {
    shakeTrigger++;
    VibrationService.heavyVibrate();
    notifyListeners();
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

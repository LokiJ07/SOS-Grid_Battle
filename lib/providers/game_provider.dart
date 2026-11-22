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
  bool isAiThinking = false;
  bool _isProcessing = false;
  bool _timeoutInProgress = false;
  int _matchGeneration = 0;
  int shakeTrigger = 0;

  List<SOSLine> sosLines = [];
  List<MoveModel> matchHistory = [];
  int? lastMoveIndex;

  Timer? _timer;
  int? timerLimit;
  int remainingSeconds = 0;
  final Map<PlayerID, int> _pendingTimeBonuses = {};
  final Map<PlayerID, bool> _pendingHalfTime = {};

  String lastEffectMessage = "";
  IconData? lastEffectIcon;

  AIDifficulty aiDifficulty = AIDifficulty.moderate;
  bool isVsAI = false;
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
    _matchGeneration++;
    gridSize = size;
    timerLimit = limit;
    isVsAI = vsAI;
    aiDifficulty = diff;
    currentGameMode = mode;
    isGameOver = false;
    isAnimating = false;
    isAiThinking = false;
    _isProcessing = false;
    _timeoutInProgress = false;
    _pendingTimeBonuses.clear();
    _pendingHalfTime.clear();
    remainingSeconds = 0;
    shakeTrigger = 0;
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
      final effects = isMine ? BattleEffectPools.mines : BattleEffectPools.perks;
      grid[idx].effectType = effects[random.nextInt(effects.length)];
    }
  }

  void playMove(int index) {
    if (isGameOver ||
        isAiThinking ||
        isAnimating ||
        _isProcessing ||
        _timeoutInProgress ||
        index < 0 ||
        index >= grid.length ||
        !grid[index].isEmpty) return;
    if (isVsAI && currentPlayer.id == PlayerID.player2) return;
    _handleMoveSequence(index);
  }

  Future<void> _handleMoveSequence(int index) async {
    final generation = _matchGeneration;
    _isProcessing = true;
    await _executeMoveLogic(index);
    // An old move must not mutate a rematch started during an animation.
    if (generation != _matchGeneration) return;
    _isProcessing = false;
    if (_checkGameOver()) return;
    if (isVsAI && currentPlayer.id == PlayerID.player2 && !isAiThinking) {
      _triggerAITurn();
    }
    notifyListeners();
  }

  Future<bool> _executeMoveLogic(int index) async {
    final generation = _matchGeneration;
    lastMoveIndex = index;
    final cell = grid[index];
    cell.letter = selectedLetter;
    cell.placedBy = currentPlayer.id;
    cell.isRevealed = true;

    matchHistory.add(MoveModel(
        index: index,
        letter: selectedLetter,
        playerID: currentPlayer.id,
        playerName: currentPlayer.name));

    _timer?.cancel();
    if (cell.specialType != SpecialType.none) {
      await _applyCellEffects(cell);
      if (generation != _matchGeneration) return false;
    }

    // Always score the placed letter before checking for a full board.
    List<SOSLine> newSOS =
        SOSDetector.checkNewSOS(grid, index, gridSize, currentPlayer.id);

    if (newSOS.isNotEmpty) {
      _triggerShake();
      int mult = currentPlayer.streak >= 4 ? (currentPlayer.streak - 2) : 1;
      currentPlayer.score += (newSOS.length * mult);
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
      _startNewTurnTimer();
      if (isVsAI && currentPlayer.id == PlayerID.player2) _triggerAITurn();
      notifyListeners();
      return true;
    } else {
      SoundService.playSound('placement.mp3');
      currentPlayer.streak = 1;
      if (!_checkGameOver()) _switchTurn();
      notifyListeners();
      return false;
    }
  }

  Future<void> _applyCellEffects(CellModel cell) async {
    final generation = _matchGeneration;
    isAnimating = true;
    final opponent = (currentPlayer.id == PlayerID.player1) ? player2 : player1;
    if (cell.specialType == SpecialType.mine && currentPlayer.hasShield) {
      currentPlayer.hasShield = false;
      await _showBattleAnimation("SHIELD BLOCKED!", Icons.security);
      if (generation != _matchGeneration) return;
      isAnimating = false;
      return;
    }
    if (cell.specialType == SpecialType.mine) _triggerShake();

    String msg = "";
    IconData icon = Icons.bolt;
    switch (cell.effectType) {
      case EffectType.theGreatSwap:
        int stolen = (currentPlayer.score / 2).floor();
        currentPlayer.score -= stolen;
        opponent.score += stolen;
        msg = "THE GREAT SWAP!";
        icon = Icons.swap_horizontal_circle;
        break;
      case EffectType.stun:
        currentPlayer.isStunned = true;
        msg = "STUNNED!";
        icon = Icons.timer_off;
        break;
      case EffectType.halfLife:
        currentPlayer.lives -= 0.5;
        msg = "-0.5 HP";
        icon = Icons.heart_broken;
        break;
      case EffectType.minusScore:
        currentPlayer.score -= 2;
        msg = "-2 SCORE";
        icon = Icons.trending_down;
        break;
      case EffectType.streakReset:
        currentPlayer.streak = 1;
        msg = "RESET!";
        icon = Icons.layers_clear;
        break;
      case EffectType.poison:
        currentPlayer.lives -= 1.5;
        msg = "POISON! -1.5 HP";
        icon = Icons.biotech;
        break;
      case EffectType.vampireTrap:
        currentPlayer.lives -= 1.0;
        opponent.lives += 1.0;
        msg = "VAMPIRE!";
        icon = Icons.bloodtype;
        break;
      case EffectType.bombRadius:
        currentPlayer.score -= 3;
        msg = "EXPLOSION!";
        icon = Icons.settings_input_antenna;
        break;
      case EffectType.timePressure:
        if (timerLimit == null) {
          currentPlayer.lives -= 0.5;
          msg = "TRAP: -0.5 HP";
        } else {
          _pendingHalfTime[currentPlayer.id] = true;
          msg = "HALF TIME NEXT TURN";
        }
        icon = Icons.speed;
        break;
      case EffectType.scoreWipe:
        currentPlayer.score -= 5;
        msg = "WIPE! -5";
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
        msg = "EXTRA HEART!";
        icon = Icons.add_box;
        break;
      case EffectType.comboBooster:
        currentPlayer.streak += 3;
        msg = "COMBO +3";
        icon = Icons.rocket_launch;
        break;
      case EffectType.jackpot:
        currentPlayer.score += 5;
        msg = "JACKPOT! +5";
        icon = Icons.stars;
        break;
      case EffectType.shield:
        currentPlayer.hasShield = true;
        msg = "SHIELD ACTIVE";
        icon = Icons.shield;
        break;
      case EffectType.revealRadius:
        currentPlayer.inventory.add(EffectType.revealRadius);
        msg = "INTEL ACQUIRED";
        icon = Icons.psychology_alt;
        break;
      case EffectType.doublePoints:
        currentPlayer.score += 2;
        msg = "BONUS POINTS";
        icon = Icons.looks_two;
        break;
      case EffectType.timerBonus:
        if (timerLimit == null ||
            (isVsAI && currentPlayer.id == PlayerID.player2)) {
          // A time bonus should never be wasted in an untimed/AI turn.
          currentPlayer.score += 2;
          msg = "BONUS SCORE +2";
        } else {
          _pendingTimeBonuses[currentPlayer.id] =
              (_pendingTimeBonuses[currentPlayer.id] ?? 0) + 10;
          msg = "NEXT TURN +10S";
        }
        icon = Icons.more_time;
        break;
      default:
        break;
    }
    VibrationService.vibrate();
    notifyListeners();
    await _showBattleAnimation(msg, icon);
    if (generation != _matchGeneration) return;
    isAnimating = false;
  }

  /// NEW: AI Brain Enhancement for skills
  Future<void> _aiCheckAndUseSkills() async {
    final generation = _matchGeneration;
    if (!currentPlayer.inventory.contains(EffectType.revealRadius)) return;

    // AI DECISION LOGIC
    EffectType aiTarget = EffectType.jackpot; // Default
    if (currentPlayer.lives < 5.0) {
      aiTarget = EffectType.extraHeart; // Prioritize survival
    } else if (currentPlayer.score < player1.score) {
      aiTarget = EffectType.jackpot; // Prioritize points
    } else {
      aiTarget = EffectType.shield; // Prioritize protection
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    if (generation != _matchGeneration || isGameOver) return;
    await _showBattleAnimation("AI ACTIVATING INTEL...", Icons.psychology_alt);
    if (generation != _matchGeneration || isGameOver) return;
    await useScanSkill(aiTarget);
  }

  Future<void> _triggerAITurn() async {
    if (isGameOver || isAiThinking) return;
    final generation = _matchGeneration;
    isAiThinking = true;
    notifyListeners();

    if (currentPlayer.inventory.contains(EffectType.revealRadius)) {
      await _aiCheckAndUseSkills();
    }
    if (generation != _matchGeneration) return;

    while (!isGameOver && currentPlayer.id == PlayerID.player2) {
      if (currentPlayer.isStunned) {
        // A scored turn may leave the AI stunned for its next action.
        currentPlayer.isStunned = false;
        _switchTurn();
        break;
      }
      await Future.delayed(
          Duration(milliseconds: 1200 + Random().nextInt(500)));
      if (generation != _matchGeneration || isGameOver ||
          currentPlayer.id != PlayerID.player2) break;
      final best = AIEngine.computeBestMove(grid, gridSize, aiDifficulty);
      if (best.isEmpty) break;
      selectedLetter = best["letter"] as String;
      final scored = await _executeMoveLogic(best["index"] as int);
      if (generation != _matchGeneration || isGameOver) break;
      if (scored) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (generation != _matchGeneration) break;
      }
    }
    if (generation != _matchGeneration) return;
    isAiThinking = false;
    if (!_checkGameOver() && currentPlayer.id == PlayerID.player1) {
      _startNewTurnTimer();
    }
    notifyListeners();
  }

  Future<void> useScanSkill(EffectType target) async {
    if (isGameOver || isAnimating || _timeoutInProgress || _isProcessing ||
        !currentPlayer.inventory.contains(EffectType.revealRadius)) return;
    if (isVsAI && currentPlayer.id == PlayerID.player1 && isAiThinking) return;
    final generation = _matchGeneration;
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
    if (generation != _matchGeneration) return;
    isAnimating = false;
    _startNewTurnTimer();
    notifyListeners();
  }

  void _switchTurn() {
    _timer?.cancel();
    if (isGameOver) return;
    currentPlayer = (currentPlayer.id == PlayerID.player1) ? player2 : player1;
    if (currentPlayer.isStunned) {
      final generation = _matchGeneration;
      final stunnedPlayer = currentPlayer;
      isAnimating = true; // Block taps until the skipped turn is finished.
      notifyListeners();
      _showBattleAnimation("${stunnedPlayer.name} STUNNED!", Icons.timer_off)
          .then((_) {
        if (generation != _matchGeneration || isGameOver) return;
        stunnedPlayer.isStunned = false;
        isAnimating = false;
        _switchTurn();
      });
      return;
    }
    if (isVsAI && currentPlayer.id == PlayerID.player2) {
      _triggerAITurn();
    }
    _startNewTurnTimer();
    notifyListeners();
  }

  void _startNewTurnTimer() {
    _timer?.cancel();
    if (timerLimit == null || isAnimating || isAiThinking || isGameOver) return;
    int base = timerLimit!;
    if (_pendingHalfTime.remove(currentPlayer.id) == true) {
      base = (base / 2).floor().clamp(3, 30);
    }
    base += _pendingTimeBonuses.remove(currentPlayer.id) ?? 0;
    remainingSeconds = base;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isGameOver) {
        t.cancel();
        return;
      }
      if (remainingSeconds > 0) remainingSeconds--;
      if (remainingSeconds == 0) {
        _handleTimeout();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> _handleTimeout() async {
    if (isGameOver || _timeoutInProgress || _isProcessing || isAnimating) return;
    final generation = _matchGeneration;
    _timeoutInProgress = true;
    isAnimating = true;
    _timer?.cancel();
    remainingSeconds = 0;
    currentPlayer.lives -= 1.0;
    notifyListeners();
    await _showBattleAnimation("TIMEOUT: -1 HP", Icons.hourglass_disabled);
    if (generation != _matchGeneration) return;
    _timeoutInProgress = false;
    isAnimating = false;
    if (!_checkGameOver()) _switchTurn();
  }

  bool _checkGameOver() {
    // Saving a match or its statistics must happen exactly once.
    if (isGameOver) return true;
    bool full = grid.every((c) => !c.isEmpty);
    bool dead = player1.lives <= 0 || player2.lives <= 0;
    if (full || dead) {
      isGameOver = true;
      _timer?.cancel();
      int winId = player1.lives <= 0
          ? 2
          : (player2.lives <= 0
              ? 1
              : (player1.score > player2.score
                  ? 1
                  : (player2.score > player1.score ? 2 : 0)));
      String res = winId == 1
          ? "Player 1 Wins"
          : (winId == 2 ? "${player2.name} Wins" : "Draw");
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
    final generation = _matchGeneration;
    await Future.delayed(const Duration(milliseconds: 2000));
    if (generation != _matchGeneration) return;
    lastEffectMessage = "";
    lastEffectIcon = null;
    notifyListeners();
  }

  void selectLetter(String l) {
    if (!isAiThinking && !isAnimating && !_isProcessing &&
        !_timeoutInProgress && !isGameOver) {
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

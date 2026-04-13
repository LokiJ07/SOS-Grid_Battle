import 'player.dart';

enum SpecialType { none, mine, perk }

// EXACTLY 20 TYPES
enum EffectType {
  stun,
  halfLife,
  minusScore,
  theGreatSwap,
  streakReset,
  poison,
  vampireTrap,
  bombRadius,
  timePressure,
  scoreWipe,
  drainOpponentLife,
  drainOpponentScore,
  lifeSteal,
  extraHeart,
  comboBooster,
  jackpot,
  shield,
  revealRadius,
  doublePoints,
  timerBonus,
  none // Added a 'none' value as a safety fallback
}

class CellModel {
  final int index;
  final int row;
  final int col;
  String letter;
  PlayerID? placedBy;
  bool isPartOfSOS;
  SpecialType specialType;
  EffectType effectType;
  bool isRevealed;

  CellModel({
    required this.index,
    required this.row,
    required this.col,
    this.letter = "",
    this.placedBy,
    this.isPartOfSOS = false,
    this.specialType = SpecialType.none,
    this.effectType = EffectType.none,
    this.isRevealed = false,
  });

  bool get isEmpty => letter.isEmpty;
}

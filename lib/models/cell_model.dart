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

/// Battle loot tables are intentionally disjoint:
/// mines are harmful and perks are beneficial.
class BattleEffectPools {
  static const List<EffectType> mines = [
    EffectType.stun,
    EffectType.halfLife,
    EffectType.minusScore,
    EffectType.theGreatSwap,
    EffectType.streakReset,
    EffectType.poison,
    EffectType.vampireTrap,
    EffectType.bombRadius,
    EffectType.timePressure,
    EffectType.scoreWipe,
  ];

  static const List<EffectType> perks = [
    EffectType.drainOpponentLife,
    EffectType.drainOpponentScore,
    EffectType.lifeSteal,
    EffectType.extraHeart,
    EffectType.comboBooster,
    EffectType.jackpot,
    EffectType.shield,
    EffectType.revealRadius,
    EffectType.doublePoints,
    EffectType.timerBonus,
  ];
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

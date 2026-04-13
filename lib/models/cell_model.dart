import 'player.dart';

enum SpecialType { none, mine, perk }

enum EffectType {
  // 10 MINES (Traps)
  stun, // Skip turn
  halfLife, // -0.5 HP
  minusScore, // -2 Score
  theGreatSwap, // YOUR SCORE / 2 -> GIVEN TO OPPONENT (Game Changer)
  streakReset, // Streak back to 1
  poison, // -1.5 HP instantly
  vampireTrap, // Opponent gains 1 HP from you
  bombRadius, // -1 score for every letter you placed adjacent
  timePressure, // Next turn timer is halved
  scoreWipe, // Lose 5 points instantly
  none,

  // 10 PERKS (Buffs)
  drainOpponentLife, // Opponent -1 HP
  drainOpponentScore, // Opponent -2 Score
  lifeSteal, // You +1 HP, Opponent -1 HP
  extraHeart, // +2 HP
  comboBooster, // Streak +3 instantly
  jackpot, // +5 points instantly
  shield, // Gain protection (Next mine ignored - handled in logic)
  revealRadius, // Reveal items in 3x3 area
  doublePoints, // Next SOS gives x2 points
  timerBonus // +10s to current turn
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

import 'player.dart';

enum SpecialType { none, mine, perk }

enum EffectType {
  none,
  stun,
  halfLife,
  minusScore,
  drainOpponentLife,
  drainOpponentScore
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

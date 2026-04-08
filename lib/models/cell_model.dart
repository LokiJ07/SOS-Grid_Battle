import 'player.dart';

class CellModel {
  final int index;
  final int row;
  final int col;
  String letter; // "S", "O", or ""
  PlayerID? placedBy;
  bool isPartOfSOS;

  CellModel({
    required this.index,
    required this.row,
    required this.col,
    this.letter = "",
    this.placedBy,
    this.isPartOfSOS = false,
  });

  bool get isEmpty => letter.isEmpty;
}

import 'dart:math';
import '../models/cell_model.dart';
import '../models/player.dart';
import '../core/constants.dart';
import 'sos_detector.dart';

class AIEngine {
  static Map<String, dynamic> computeBestMove(
      List<CellModel> grid, int size, AIDifficulty diff) {
    List<int> empty = [];
    for (int i = 0; i < grid.length; i++) if (grid[i].isEmpty) empty.add(i);
    if (empty.isEmpty) return {};

    if (diff == AIDifficulty.easy) {
      return {
        "index": empty[Random().nextInt(empty.length)],
        "letter": Random().nextBool() ? "S" : "O"
      };
    }

    int bestScore = -999999;
    int bestIndex = empty[0];
    String bestLetter = "S";
    empty.shuffle();

    for (int index in empty) {
      for (String letter in ["S", "O"]) {
        int score = _evaluate(grid, index, letter, size, diff);
        if (score > bestScore) {
          bestScore = score;
          bestIndex = index;
          bestLetter = letter;
        }
      }
    }
    return {"index": bestIndex, "letter": bestLetter};
  }

  static int _evaluate(List<CellModel> grid, int index, String letter, int size,
      AIDifficulty diff) {
    int score = 0;
    grid[index].letter = letter;
    var found = SOSDetector.checkNewSOS(grid, index, size, PlayerID.player2);
    score += found.length * 1000;

    if (diff == AIDifficulty.hard || diff == AIDifficulty.expert) {
      if (grid[index].specialType == SpecialType.perk) score += 200;
      if (grid[index].specialType == SpecialType.mine) score -= 400;

      grid[index].letter = (letter == "S") ? "O" : "S";
      var opponentChance =
          SOSDetector.checkNewSOS(grid, index, size, PlayerID.player1);
      score += opponentChance.length * 500;
    }

    grid[index].letter = "";
    return score;
  }
}

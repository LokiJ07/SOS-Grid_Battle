import 'dart:math';
import '../models/cell_model.dart';
import '../models/player.dart';
import '../core/constants.dart';
import 'sos_detector.dart';

class AIEngine {
  /// Entry point for AI decision making
  static Map<String, dynamic> computeBestMove(
      List<CellModel> grid, int size, AIDifficulty diff, {Random? random}) {
    final rng = random ?? Random();
    List<int> empty = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i].isEmpty) empty.add(i);
    }

    if (empty.isEmpty) return {};

    // --- LEVEL: EASY ---
    // Completely random placement
    if (diff == AIDifficulty.easy) {
      return {
        "index": empty[rng.nextInt(empty.length)],
        "letter": rng.nextBool() ? "S" : "O"
      };
    }

    int bestScore = -9999999;
    int bestIndex = empty[0];
    String bestLetter = "S";

    // Shuffle empty indices to make AI feel more natural/less robotic
    empty.shuffle(rng);

    // Iterate through every possibility (Empty Cell + S or O)
    for (int index in empty) {
      for (String letter in ["S", "O"]) {
        int score = _evaluateMove(grid, index, letter, size, diff, rng);

        if (score > bestScore) {
          bestScore = score;
          bestIndex = index;
          bestLetter = letter;
        }
      }
    }

    return {"index": bestIndex, "letter": bestLetter};
  }

  /// Heuristic evaluation function to score a potential move
  static int _evaluateMove(List<CellModel> grid, int index, String letter,
      int size, AIDifficulty diff, Random rng) {
    int score = 0;
    final cell = grid[index];

    // 1. SOS COMPLETION (Primary Goal)
    // Temporarily simulate the move
    String originalLetter = cell.letter;
    cell.letter = letter;
    var foundSOS = SOSDetector.checkNewSOS(grid, index, size, PlayerID.player2);
    cell.letter = originalLetter; // Revert simulation

    // Huge reward for scoring points
    score += foundSOS.length * 5000;

    // 2. DEFENSIVE BLOCKING (Moderate and above)
    // AI checks if the player could have made an SOS in this same spot
    if (diff != AIDifficulty.easy) {
      cell.letter = (letter == "S") ? "O" : "S"; // Simulate opponent letter
      var opponentSOS =
          SOSDetector.checkNewSOS(grid, index, size, PlayerID.player1);
      cell.letter = originalLetter; // Revert

      // Block player if they were about to score
      score += opponentSOS.length * 2000;
    }

    // Never peek at undisclosed mines or perks. Both players must use
    // only the information visible on the board.
    if ((diff == AIDifficulty.hard || diff == AIDifficulty.expert) &&
        cell.isRevealed && cell.specialType != SpecialType.none) {
      score += _scoreSpecificItem(cell.effectType, cell.specialType);
    }

    // 4. RISK CALCULATION (Expert only)
    if (diff == AIDifficulty.expert) {
      // AI checks if placing this letter creates an "S _ S" or "S O _"
      // setup that the player can exploit on their very next turn.
      score -= _calculateSetupRisk(grid, index, letter, size, rng);
    }

    return score;
  }

  /// Assigns precise values to items if they are REVEALED on the board
  static int _scoreSpecificItem(EffectType effect, SpecialType type) {
    if (type == SpecialType.mine) {
      switch (effect) {
        case EffectType.theGreatSwap:
          return -8000; // Extremely dangerous
        case EffectType.poison:
          return -6000;
        case EffectType.scoreWipe:
          return -5000;
        case EffectType.stun:
          return -4000;
        default:
          return -3000;
      }
    } else {
      switch (effect) {
        case EffectType.jackpot:
          return 7000; // High priority
        case EffectType.extraHeart:
          return 6000;
        case EffectType.lifeSteal:
          return 5500;
        case EffectType.shield:
          return 5000;
        case EffectType.revealRadius:
          return 4000;
        default:
          return 2000;
      }
    }
  }

  /// Expert logic to avoid helping the player
  static int _calculateSetupRisk(
      List<CellModel> grid, int index, String letter, int size, Random rng) {
    int risk = 0;
    // Simple heuristic: Placing an 'O' is generally riskier than an 'S'
    // because SOS patterns usually end with 'S'.
    if (letter == "O") risk += 100;

    // Add a layer of randomness so the Expert AI isn't 100% predictable
    risk += rng.nextInt(50);

    return risk;
  }
}

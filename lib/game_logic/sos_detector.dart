import '../models/cell_model.dart';
import '../models/sos_line.dart';
import '../models/player.dart';

class SOSDetector {
  /// Checks for new SOS patterns only around the last placed cell.
  /// Returns a list of SOSLine objects containing indices and the owner.
  static List<SOSLine> checkNewSOS(List<CellModel> grid, int lastIndex,
      int gridSize, PlayerID currentPlayerId) {
    List<SOSLine> newLines = [];
    final cell = grid[lastIndex];
    final String letter = cell.letter;

    // Directions: [rowDelta, colDelta]
    final directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal Right (Down-Right)
      [1, -1], // Diagonal Left (Down-Left)
    ];

    if (letter == "S") {
      // If S is placed, it could be the START of an SOS or the END of an SOS
      for (var dir in directions) {
        // Check forward (S is start)
        newLines.addAll(_checkSAsEndpoint(grid, cell.row, cell.col, dir[0],
            dir[1], gridSize, currentPlayerId));
        // Check backward (S is end)
        newLines.addAll(_checkSAsEndpoint(grid, cell.row, cell.col, -dir[0],
            -dir[1], gridSize, currentPlayerId));
      }
    } else if (letter == "O") {
      // If O is placed, it must be the CENTER of an SOS
      for (var dir in directions) {
        newLines.addAll(_checkOAsCenter(grid, cell.row, cell.col, dir[0],
            dir[1], gridSize, currentPlayerId));
      }
    }

    return newLines;
  }

  static List<SOSLine> _checkSAsEndpoint(List<CellModel> grid, int r, int c,
      int dr, int dc, int size, PlayerID owner) {
    int r1 = r + dr, c1 = c + dc;
    int r2 = r + 2 * dr, c2 = c + 2 * dc;

    if (_isValid(r1, c1, size) && _isValid(r2, c2, size)) {
      if (grid[r1 * size + c1].letter == "O" &&
          grid[r2 * size + c2].letter == "S") {
        return [
          SOSLine(
              indices: [r * size + c, r1 * size + c1, r2 * size + c2],
              owner: owner)
        ];
      }
    }
    return [];
  }

  static List<SOSLine> _checkOAsCenter(List<CellModel> grid, int r, int c,
      int dr, int dc, int size, PlayerID owner) {
    int r1 = r - dr, c1 = c - dc;
    int r2 = r + dr, c2 = c + dc;

    if (_isValid(r1, c1, size) && _isValid(r2, c2, size)) {
      if (grid[r1 * size + c1].letter == "S" &&
          grid[r2 * size + c2].letter == "S") {
        return [
          SOSLine(
              indices: [r1 * size + c1, r * size + c, r2 * size + c2],
              owner: owner)
        ];
      }
    }
    return [];
  }

  static bool _isValid(int r, int c, int size) {
    return r >= 0 && r < size && c >= 0 && c < size;
  }
}

import '../models/cell_model.dart';
import '../models/sos_line.dart';

class SOSDetector {
  static List<SOSLine> checkNewSOS(
      List<CellModel> grid, int lastIndex, int gridSize) {
    List<SOSLine> newLines = [];
    final cell = grid[lastIndex];
    final String letter = cell.letter;

    // Directions: [rowDelta, colDelta]
    final directions = [
      [0, 1], // Horizontal
      [1, 0], // Vertical
      [1, 1], // Diagonal Right
      [1, -1], // Diagonal Left
    ];

    if (letter == "S") {
      // Check for S-O-S where S is the endpoint
      for (var dir in directions) {
        newLines.addAll(_checkSAsEndpoint(
            grid, cell.row, cell.col, dir[0], dir[1], gridSize));
        newLines.addAll(_checkSAsEndpoint(
            grid, cell.row, cell.col, -dir[0], -dir[1], gridSize));
      }
    } else if (letter == "O") {
      // Check for S-O-S where O is the center
      for (var dir in directions) {
        newLines.addAll(_checkOAsCenter(
            grid, cell.row, cell.col, dir[0], dir[1], gridSize));
      }
    }

    return newLines;
  }

  static List<SOSLine> _checkSAsEndpoint(
      List<CellModel> grid, int r, int c, int dr, int dc, int size) {
    // Look for O at (r+dr, c+dc) and S at (r+2dr, c+2dc)
    int r1 = r + dr, c1 = c + dc;
    int r2 = r + 2 * dr, c2 = c + 2 * dc;

    if (_isValid(r1, c1, size) && _isValid(r2, c2, size)) {
      if (grid[r1 * size + c1].letter == "O" &&
          grid[r2 * size + c2].letter == "S") {
        return [
          SOSLine([r * size + c, r1 * size + c1, r2 * size + c2])
        ];
      }
    }
    return [];
  }

  static List<SOSLine> _checkOAsCenter(
      List<CellModel> grid, int r, int c, int dr, int dc, int size) {
    // Look for S at (r-dr, c-dc) and S at (r+dr, c+dc)
    int r1 = r - dr, c1 = c - dc;
    int r2 = r + dr, c2 = c + dc;

    if (_isValid(r1, c1, size) && _isValid(r2, c2, size)) {
      if (grid[r1 * size + c1].letter == "S" &&
          grid[r2 * size + c2].letter == "S") {
        return [
          SOSLine([r1 * size + c1, r * size + c, r2 * size + c2])
        ];
      }
    }
    return [];
  }

  static bool _isValid(int r, int c, int size) {
    return r >= 0 && r < size && c >= 0 && c < size;
  }
}

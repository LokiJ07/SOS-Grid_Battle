import '../models/cell_model.dart';
import '../models/sos_line.dart';
import '../models/player.dart';

class SOSDetector {
  static List<SOSLine> checkNewSOS(
      List<CellModel> grid, int lastIndex, int size, PlayerID owner) {
    List<SOSLine> lines = [];
    final cell = grid[lastIndex];
    final String letter = cell.letter;
    final directions = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1]
    ];

    if (letter == "S") {
      for (var dir in directions) {
        lines.addAll(
            _check(grid, cell.row, cell.col, dir[0], dir[1], size, owner));
        lines.addAll(
            _check(grid, cell.row, cell.col, -dir[0], -dir[1], size, owner));
      }
    } else if (letter == "O") {
      for (var dir in directions) {
        int r1 = cell.row - dir[0], c1 = cell.col - dir[1];
        int r2 = cell.row + dir[0], c2 = cell.col + dir[1];
        if (_v(r1, c1, size) && _v(r2, c2, size)) {
          if (grid[r1 * size + c1].letter == "S" &&
              grid[r2 * size + c2].letter == "S") {
            lines.add(SOSLine(
                indices: [r1 * size + c1, lastIndex, r2 * size + c2],
                owner: owner));
          }
        }
      }
    }
    return lines;
  }

  static List<SOSLine> _check(
      List<CellModel> g, int r, int c, int dr, int dc, int s, PlayerID o) {
    int r1 = r + dr, c1 = c + dc, r2 = r + 2 * dr, c2 = c + 2 * dc;
    if (_v(r1, c1, s) && _v(r2, c2, s)) {
      if (g[r1 * s + c1].letter == "O" && g[r2 * s + c2].letter == "S") {
        return [
          SOSLine(indices: [r * s + c, r1 * s + c1, r2 * s + c2], owner: o)
        ];
      }
    }
    return [];
  }

  static bool _v(int r, int c, int s) => r >= 0 && r < s && c >= 0 && c < s;
}

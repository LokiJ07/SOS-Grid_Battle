import 'package:flutter_test/flutter_test.dart';
import 'package:sos_grid_battle/game_logic/sos_detector.dart';
import 'package:sos_grid_battle/models/cell_model.dart';
import 'package:sos_grid_battle/models/player.dart'; // Added import for PlayerID

void main() {
  const PlayerID testPlayer = PlayerID.player1;

  test('Detects SOS horizontally', () {
    const int size = 3;
    List<CellModel> grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    // Create S - O - S
    grid[0].letter = "S";
    grid[1].letter = "O";
    grid[2].letter = "S";

    // Pass the required PlayerID argument
    final results = SOSDetector.checkNewSOS(grid, 2, size, testPlayer);

    expect(results.length, 1);
    expect(results[0].indices, [0, 1, 2]);
    expect(results[0].owner, testPlayer); // Verify the owner is correct
  });

  test('Detects SOS vertically', () {
    const int size = 3;
    List<CellModel> grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    grid[0].letter = "S";
    grid[3].letter = "O";
    grid[6].letter = "S";

    // Pass the required PlayerID argument
    final results = SOSDetector.checkNewSOS(grid, 6, size, testPlayer);

    expect(results.length, 1);
    expect(results[0].indices, [0, 3, 6]);
  });

  test('Detects SOS diagonally', () {
    const int size = 3;
    List<CellModel> grid = List.generate(
        size * size,
        (index) =>
            CellModel(index: index, row: index ~/ size, col: index % size));

    grid[0].letter = "S";
    grid[4].letter = "O";
    grid[8].letter = "S";

    // Pass the required PlayerID argument
    // Checking SOS with 'O' in the middle (index 4)
    final results = SOSDetector.checkNewSOS(grid, 4, size, testPlayer);

    expect(results.length, 1);
    expect(results[0].indices, [0, 4, 8]);
  });
}

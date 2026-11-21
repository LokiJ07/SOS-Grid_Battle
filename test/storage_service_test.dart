import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_grid_battle/core/constants.dart';
import 'package:sos_grid_battle/services/storage_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('A damaged archive does not crash loading or saving matches', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageService.keyMatchArchive, '{broken json');

    expect(StorageService.getMatchArchive(), isEmpty);

    await StorageService.saveMatchToArchive(
      history: [],
      sosLines: [],
      gridSize: 3,
      result: 'Draw',
    );
    expect(StorageService.getMatchArchive(), hasLength(1));
  });

  test('Reset All Data clears wins, high score and saved matches', () async {
    await StorageService.setInt(AppConstants.keyGamesPlayed, 4);
    await StorageService.setInt(AppConstants.keyP1Wins, 2);
    await StorageService.setInt(AppConstants.keyP2Wins, 1);
    await StorageService.setInt(AppConstants.keyHighScore, 50);
    await StorageService.saveMatchToArchive(
      history: [],
      sosLines: [],
      gridSize: 3,
      result: 'Draw',
    );

    await StorageService.resetAllData();

    expect(StorageService.getInt(AppConstants.keyGamesPlayed), 0);
    expect(StorageService.getInt(AppConstants.keyP1Wins), 0);
    expect(StorageService.getInt(AppConstants.keyP2Wins), 0);
    expect(StorageService.getInt(AppConstants.keyHighScore), 0);
    expect(StorageService.getMatchArchive(), isEmpty);
  });
}

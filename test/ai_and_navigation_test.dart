import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_grid_battle/core/constants.dart';
import 'package:sos_grid_battle/game_logic/ai_engine.dart';
import 'package:sos_grid_battle/models/cell_model.dart';
import 'package:sos_grid_battle/providers/game_provider.dart';
import 'package:sos_grid_battle/screens/game_screen.dart';
import 'package:sos_grid_battle/screens/result_screen.dart';
import 'package:sos_grid_battle/services/storage_service.dart';

List<CellModel> sampleBoard() => List.generate(
  9,
  (index) => CellModel(
    index: index,
    row: index ~/ 3,
    col: index % 3,
    letter: index < 2 ? '' : 'O',
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keySoundEnabled: false,
      AppConstants.keyVibrationEnabled: false,
    });
    await StorageService.init();
  });

  test('Hard and Expert decisions are not affected by secret items', () {
    for (final difficulty in [AIDifficulty.hard, AIDifficulty.expert]) {
      final first = sampleBoard();
      final second = sampleBoard();

      first[0].specialType = SpecialType.perk;
      first[0].effectType = EffectType.jackpot;
      first[1].specialType = SpecialType.mine;
      first[1].effectType = EffectType.poison;

      second[0].specialType = SpecialType.mine;
      second[0].effectType = EffectType.poison;
      second[1].specialType = SpecialType.perk;
      second[1].effectType = EffectType.jackpot;

      final moveA = AIEngine.computeBestMove(first, 3, difficulty,
          random: Random(17));
      final moveB = AIEngine.computeBestMove(second, 3, difficulty,
          random: Random(17));
      expect(moveA, moveB);
    }
  });

  test('Hard AI may strategically prefer a revealed perk', () {
    final grid = sampleBoard();
    grid[0]
      ..isRevealed = true
      ..specialType = SpecialType.mine
      ..effectType = EffectType.poison;
    grid[1]
      ..isRevealed = true
      ..specialType = SpecialType.perk
      ..effectType = EffectType.jackpot;

    final move = AIEngine.computeBestMove(grid, 3, AIDifficulty.hard,
        random: Random(17));
    expect(move['index'], 1);
  });

  testWidgets('Instant Rematch opens GameScreen rather than the menu',
      (tester) async {
    final game = GameProvider()..initGame(3, null, mode: GameMode.classic);
    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: game,
        child: const MaterialApp(home: ResultScreen()),
      ),
    );

    await tester.ensureVisible(find.text('INSTANT REMATCH'));
    await tester.tap(find.text('INSTANT REMATCH'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(game.isGameOver, isFalse);

    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });
}

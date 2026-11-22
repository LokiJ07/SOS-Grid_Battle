import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos_grid_battle/core/constants.dart';
import 'package:sos_grid_battle/models/cell_model.dart';
import 'package:sos_grid_battle/models/player.dart';
import 'package:sos_grid_battle/providers/game_provider.dart';
import 'package:sos_grid_battle/services/storage_service.dart';
import 'package:sos_grid_battle/widgets/grid_cell.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keySoundEnabled: false,
      AppConstants.keyVibrationEnabled: false,
    });
    await StorageService.init();
  });

  testWidgets('final placement scores SOS before the board ends',
      (tester) async {
    final game = GameProvider()..initGame(3, null, mode: GameMode.classic);
    for (final cell in game.grid) {
      if (cell.index != 2) cell.letter = 'O';
    }
    game.grid[0].letter = 'S';
    game.grid[1].letter = 'O';

    game.playMove(2);
    await tester.pump();

    expect(game.isGameOver, isTrue);
    expect(game.player1.score, 1);
    expect(game.sosLines.any((line) =>
        line.indices.join(',') == '0,1,2'), isTrue);
    expect(game.matchHistory.length, 1);
    game.dispose();
  });

  test('battle items always match the mine/perk reward pool', () {
    final game = GameProvider()..initGame(10, null, mode: GameMode.battle);
    final items = game.grid.where((c) => c.specialType != SpecialType.none);
    expect(items, isNotEmpty);
    for (final cell in items) {
      if (cell.specialType == SpecialType.mine) {
        expect(BattleEffectPools.mines, contains(cell.effectType));
        expect(BattleEffectPools.perks, isNot(contains(cell.effectType)));
      } else {
        expect(BattleEffectPools.perks, contains(cell.effectType));
        expect(BattleEffectPools.mines, isNot(contains(cell.effectType)));
      }
    }
    game.dispose();
  });

  testWidgets('timer bonus is awarded to the collector on their next turn',
      (tester) async {
    final game = GameProvider()..initGame(3, 10, mode: GameMode.battle);
    for (final cell in game.grid) {
      cell.specialType = SpecialType.none;
      cell.effectType = EffectType.none;
    }
    game.grid[0].specialType = SpecialType.perk;
    game.grid[0].effectType = EffectType.timerBonus;

    game.playMove(0); // Player 1 picks up +10s.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(game.currentPlayer.id, PlayerID.player2);

    game.playMove(1); // Player 2 completes a non-scoring turn.
    await tester.pump();
    expect(game.currentPlayer.id, PlayerID.player1);
    expect(game.remainingSeconds, 20);
    game.dispose();
  });

  testWidgets('stunned player cannot tap during the skipped-turn animation',
      (tester) async {
    final game = GameProvider()..initGame(3, null, mode: GameMode.battle);
    for (final cell in game.grid) {
      cell.specialType = SpecialType.none;
      cell.effectType = EffectType.none;
    }
    game.grid[0].specialType = SpecialType.mine;
    game.grid[0].effectType = EffectType.stun;

    game.playMove(0);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(game.currentPlayer.id, PlayerID.player2);

    game.playMove(1); // P2 turn ends, P1 gets stunned.
    await tester.pump();
    expect(game.isAnimating, isTrue);
    game.playMove(2); // Must not land during stun animation.
    expect(game.grid[2].letter, isEmpty);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(game.currentPlayer.id, PlayerID.player2);
    expect(game.grid[2].letter, isEmpty);
    game.dispose();
  });

  testWidgets('timeout subtracts exactly one HP and locks input',
      (tester) async {
    final game = GameProvider()..initGame(3, 1, mode: GameMode.classic);
    await tester.pump(const Duration(seconds: 1));
    expect(game.player1.lives, 9);
    game.playMove(0);
    expect(game.grid[0].letter, isEmpty);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(game.player1.lives, 9);
    expect(game.currentPlayer.id, PlayerID.player2);
    game.dispose();
  });

  testWidgets('outdated AI callback cannot move in a freshly started match',
      (tester) async {
    final game = GameProvider()
      ..initGame(3, null, vsAI: true, mode: GameMode.classic);
    game.playMove(0);
    await tester.pump();
    expect(game.isAiThinking, isTrue);
    game.initGame(3, null, vsAI: false, mode: GameMode.classic);
    await tester.pump(const Duration(seconds: 3));
    expect(game.matchHistory, isEmpty);
    expect(game.grid.every((cell) => cell.isEmpty), isTrue);
    expect(game.currentPlayer.id, PlayerID.player1);
    game.dispose();
  });

  testWidgets('reveal hint updates when cells mutate in place',
      (tester) async {
    final game = GameProvider()..initGame(3, null, mode: GameMode.classic);
    game.grid[0].specialType = SpecialType.perk;
    game.grid[0].effectType = EffectType.jackpot;

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: game,
        child: const MaterialApp(home: Scaffold(body: GridCell(index: 0))),
      ),
    );
    expect(find.byIcon(Icons.radar_rounded), findsNothing);
    game.grid[0].isRevealed = true;
    game.notifyListeners();
    await tester.pump();
    expect(find.byIcon(Icons.radar_rounded), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    game.dispose();
  });
}

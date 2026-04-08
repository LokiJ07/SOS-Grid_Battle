import 'package:flutter_test/flutter_test.dart';
import 'package:sos_grid_battle/main.dart';
import 'package:sos_grid_battle/widgets/game_logo.dart';
import 'package:sos_grid_battle/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Setup for SharedPreferences to prevent the test from crashing during init
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('App smoke test - verifies splash screen and logo load',
      (WidgetTester tester) async {
    // 1. Build our app (SOSGridBattle is the class name in main.dart)
    await tester.pumpWidget(const SOSGridBattle());

    // 2. Verify that the GameLogo widget is present on the splash screen
    expect(find.byType(GameLogo), findsOneWidget);

    // 3. Verify that the text "GRID BATTLE" is visible
    expect(find.text('GRID BATTLE'), findsOneWidget);

    // 4. Verify that counter-related widgets from the old test DON'T exist
    expect(find.text('0'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_grid_battle/main.dart';
import 'package:sos_grid_battle/screens/splash_screen.dart';
import 'package:sos_grid_battle/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('App opens on splash and navigates to the main menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SOSGridBattle());

    // The current splash uses a PNG logo, not the old GameLogo widget.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('LoKiJ PRESENTS'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);

    // Advance the 4-second splash delay and the 1-second route animation.
    // Avoid pumpAndSettle: the splash intentionally repeats an animation.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('SOLO VS COMPUTER'), findsOneWidget);
  });
}

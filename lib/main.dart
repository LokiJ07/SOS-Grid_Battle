import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const SOSGridBattle(),
    ),
  );
}

class SOSGridBattle extends StatelessWidget {
  const SOSGridBattle({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Grid Battle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

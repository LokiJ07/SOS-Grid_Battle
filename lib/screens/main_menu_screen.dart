import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/menu_button.dart';
import 'board_size_screen.dart';
import 'how_to_play_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 140, height: 140),
              const SizedBox(height: 40),
              MenuButton(
                  label: 'SOLO VS COMPUTER',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BoardSizeScreen(isVsAI: true)))),
              MenuButton(
                  label: 'LOCAL MULTIPLAYER',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BoardSizeScreen(isVsAI: false)))),
              MenuButton(
                  label: 'HOW TO PLAY',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen()))),
              MenuButton(
                  label: 'STATISTICS',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StatisticsScreen()))),
              MenuButton(
                  label: 'SETTINGS',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen()))),
              MenuButton(label: 'EXIT', onPressed: () => SystemNavigator.pop()),
            ],
          ),
        ),
      ),
    );
  }
}

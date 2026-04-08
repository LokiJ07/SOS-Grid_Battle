import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'board_size_screen.dart';
import 'how_to_play_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import '../widgets/menu_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Small logo at the top of the menu
                Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 40),

                MenuButton(
                  label: 'PLAY',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BoardSizeScreen())),
                ),
                MenuButton(
                  label: 'HOW TO PLAY',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen())),
                ),
                MenuButton(
                  label: 'STATISTICS',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StatisticsScreen())),
                ),
                MenuButton(
                  label: 'SETTINGS',
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                ),
                MenuButton(
                  label: 'EXIT',
                  onPressed: () => SystemNavigator.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

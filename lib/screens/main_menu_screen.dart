import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
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
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                Image.asset(
                  'assets/logo.png',
                  width: 140,
                  height: 140,
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(curve: Curves.elasticOut),

                const SizedBox(height: 10),

                const Text(
                  "BATTLE FOR THE GRID",
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 10,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 60),

                // Main Game Modes
                MenuButton(
                  label: 'SOLO VS COMPUTER',
                  icon: Icons.computer_rounded, // ICON ADDED
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BoardSizeScreen(isVsAI: true))),
                ),

                MenuButton(
                  label: 'LOCAL MULTIPLAYER',
                  icon: Icons.people_alt_rounded, // ICON ADDED
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const BoardSizeScreen(isVsAI: false))),
                ),

                const SizedBox(height: 20),

                // Sub Menus
                MenuButton(
                  label: 'HOW TO PLAY',
                  icon: Icons.help_outline_rounded, // ICON ADDED
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HowToPlayScreen())),
                ),

                MenuButton(
                  label: 'STATISTICS',
                  icon: Icons.bar_chart_rounded, // ICON ADDED
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const StatisticsScreen())),
                ),

                MenuButton(
                  label: 'SETTINGS',
                  icon: Icons.settings_rounded, // ICON ADDED
                  isSecondary: true,
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsScreen())),
                ),

                const SizedBox(height: 20),

                MenuButton(
                  label: 'EXIT GAME',
                  icon: Icons.power_settings_new_rounded, // ICON ADDED
                  isSecondary: true,
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

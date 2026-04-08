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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SOS',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 50),
              MenuButton(
                label: 'PLAY',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BoardSizeScreen())),
              ),
              MenuButton(
                label: 'HOW TO PLAY',
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HowToPlayScreen())),
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
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
              MenuButton(
                label: 'EXIT',
                onPressed: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

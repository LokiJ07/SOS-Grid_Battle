import 'package:flutter/material.dart';

enum AIDifficulty { easy, moderate, hard, expert }

class AppConstants {
  static const String appName = 'SOS Grid Battle';
  static const Color player1Color = Colors.blue;
  static const Color player2Color = Colors.red;
  static const Color backgroundColor = Color(0xFF0F0F0F);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  // Expanded to 6 board sizes as requested
  static const List<int> gridSizes = [3, 6, 10, 16, 24, 32];

  // Storage Keys
  static const String keyGamesPlayed = 'games_played';
  static const String keyP1Wins = 'p1_wins';
  static const String keyP2Wins = 'p2_wins';
  static const String keyHighScore = 'high_score';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
}

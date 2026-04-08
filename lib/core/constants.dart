import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SOS Grid Battle';

  // Colors
  static const Color player1Color = Colors.blue;
  static const Color player2Color = Colors.red;
  static const Color highlightColor = Colors.yellow;
  static const Color backgroundColor = Color.fromARGB(0, 8, 0, 0);
  static const Color surfaceColor = Color(0xFF1E1E1E);

  // Board Sizes
  static const List<int> gridSizes = [3, 16, 32];

  // Storage Keys
  static const String keyGamesPlayed = 'games_played';
  static const String keyP1Wins = 'p1_wins';
  static const String keyP2Wins = 'p2_wins';
  static const String keyHighScore = 'high_score';
  static const String keySoundEnabled = 'sound_enabled';
  static const String keyVibrationEnabled = 'vibration_enabled';
}

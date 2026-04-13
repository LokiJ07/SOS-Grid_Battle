import 'package:flutter/material.dart';
import 'player.dart';

enum PlayerID { player1, player2 }

class Player {
  final PlayerID id;
  final String name;
  final Color color;
  int score;
  double lives;
  int streak;
  bool isStunned;
  bool hasShield; // NEW: Added this property

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.score = 0,
    this.lives = 10.0,
    this.streak = 1,
    this.isStunned = false,
    this.hasShield = false, // Default to false
  });

  /// Resets the player for a new game
  void reset(double initialLives) {
    score = 0;
    lives = initialLives;
    streak = 1;
    isStunned = false;
    hasShield = false; // Reset shield status
  }
}

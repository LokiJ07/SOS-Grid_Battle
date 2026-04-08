import 'package:flutter/material.dart';

enum PlayerID { player1, player2 }

class Player {
  final PlayerID id;
  final String name;
  final Color color;
  int score;
  int lives; // NEW: 10 lives system

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.score = 0,
    this.lives = 10,
  });

  void reset(int initialLives) {
    score = 0;
    lives = initialLives;
  }
}

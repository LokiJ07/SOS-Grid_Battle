import 'player.dart';

class MoveModel {
  final int index;
  final String letter;
  final PlayerID playerID;
  final String playerName;

  MoveModel({
    required this.index,
    required this.letter,
    required this.playerID,
    required this.playerName,
  });

  // Convert to JSON for offline storage
  Map<String, dynamic> toJson() => {
        'index': index,
        'letter': letter,
        'playerID': playerID.index,
        'playerName': playerName,
      };

  // Create from JSON when loading from storage
  factory MoveModel.fromJson(Map<String, dynamic> json) => MoveModel(
        index: json['index'],
        letter: json['letter'],
        playerID: PlayerID.values[json['playerID']],
        playerName: json['playerName'],
      );
}

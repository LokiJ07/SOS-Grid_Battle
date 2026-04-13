import 'player.dart';

class SOSLine {
  final List<int> indices;
  final PlayerID owner;
  final int moveIndex; // NEW: The move number when this SOS was formed

  SOSLine({required this.indices, required this.owner, this.moveIndex = 0});

  // For JSON storage
  Map<String, dynamic> toJson() => {
        'indices': indices,
        'owner': owner.index,
        'moveIndex': moveIndex,
      };

  factory SOSLine.fromJson(Map<String, dynamic> json) => SOSLine(
        indices: List<int>.from(json['indices']),
        owner: PlayerID.values[json['owner']],
        moveIndex: json['moveIndex'],
      );
}

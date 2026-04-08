import 'player.dart';

class SOSLine {
  final List<int> indices;
  final PlayerID owner; // New: Tracks who formed the SOS

  SOSLine({required this.indices, required this.owner});
}

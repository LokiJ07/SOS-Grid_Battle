import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';
import '../core/constants.dart';

class SoundService {
  /// We use multiple players to allow sounds to overlap without cutting each other off.
  static final List<AudioPlayer> _playerPool = [];

  static Future<void> playSound(String fileName, {double speed = 1.0}) async {
    if (!StorageService.getBool(AppConstants.keySoundEnabled)) return;

    try {
      // Find an idle player or create a new one
      AudioPlayer player = AudioPlayer();
      _playerPool.add(player);

      // Set playback speed (also increases pitch for combos)
      await player.setPlaybackRate(speed);

      // Play the sound
      await player.play(AssetSource('sounds/$fileName'));

      // Clean up the player once the sound is finished to save memory
      player.onPlayerComplete.listen((_) {
        player.dispose();
        _playerPool.remove(player);
      });
    } catch (e) {
      print("Audio Engine Error: $e");
    }
  }

  /// Stops all currently playing sounds (useful for game over)
  static void stopAll() {
    for (var player in _playerPool) {
      player.stop();
      player.dispose();
    }
    _playerPool.clear();
  }
}

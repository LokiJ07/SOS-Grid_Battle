import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';
import '../core/constants.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playSound(String fileName) async {
    if (!StorageService.getBool(AppConstants.keySoundEnabled)) return;
    try {
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print("Sound error: $e");
    }
  }
}

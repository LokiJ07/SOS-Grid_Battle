import 'package:flutter/services.dart';
import 'storage_service.dart';
import '../core/constants.dart';

class VibrationService {
  /// Uses Flutter's native HapticFeedback to ensure compatibility
  /// and fix the 'PluginRegistry.Registrar' build error.
  static Future<void> vibrate() async {
    final bool isEnabled =
        StorageService.getBool(AppConstants.keyVibrationEnabled);

    if (isEnabled) {
      // HapticFeedback works on both Android and iOS without external plugins
      await HapticFeedback.vibrate();
    }
  }

  /// Optional: Use a heavier impact for victories
  static Future<void> heavyVibrate() async {
    final bool isEnabled =
        StorageService.getBool(AppConstants.keyVibrationEnabled);

    if (isEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }
}

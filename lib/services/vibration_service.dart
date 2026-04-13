import 'package:flutter/services.dart';
import 'storage_service.dart';
import '../core/constants.dart';

class VibrationService {
  /// Standard vibration for turn switches or small actions
  static Future<void> vibrate() async {
    if (StorageService.getBool(AppConstants.keyVibrationEnabled)) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Stronger vibration for Mines and SOS formations
  static Future<void> heavyVibrate() async {
    if (StorageService.getBool(AppConstants.keyVibrationEnabled)) {
      await HapticFeedback.heavyImpact();
    }
  }
}

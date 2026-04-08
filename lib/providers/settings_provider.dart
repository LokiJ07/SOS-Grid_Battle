import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _soundEnabled = StorageService.getBool(AppConstants.keySoundEnabled);
  bool _vibrationEnabled =
      StorageService.getBool(AppConstants.keyVibrationEnabled);

  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  void toggleSound(bool value) {
    _soundEnabled = value;
    StorageService.setBool(AppConstants.keySoundEnabled, value);
    notifyListeners();
  }

  void toggleVibration(bool value) {
    _vibrationEnabled = value;
    StorageService.setBool(AppConstants.keyVibrationEnabled, value);
    notifyListeners();
  }
}

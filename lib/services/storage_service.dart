import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static int getInt(String key) => _prefs.getInt(key) ?? 0;
  static Future<void> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  static bool getBool(String key, {bool defaultValue = true}) =>
      _prefs.getBool(key) ?? defaultValue;
  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static Future<void> recordWin(int winnerId, int p1Score, int p2Score) async {
    // Increment total games
    await setInt(
        AppConstants.keyGamesPlayed, getInt(AppConstants.keyGamesPlayed) + 1);

    // Increment specific player wins
    if (winnerId == 1) {
      await setInt(AppConstants.keyP1Wins, getInt(AppConstants.keyP1Wins) + 1);
    } else if (winnerId == 2) {
      await setInt(AppConstants.keyP2Wins, getInt(AppConstants.keyP2Wins) + 1);
    }

    // Update high score if current match exceeds it
    int currentHigh = getInt(AppConstants.keyHighScore);
    int matchMax = p1Score > p2Score ? p1Score : p2Score;
    if (matchMax > currentHigh) {
      await setInt(AppConstants.keyHighScore, matchMax);
    }
  }
}

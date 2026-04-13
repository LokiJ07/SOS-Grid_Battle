import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/move_model.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static const String keyMatchArchive = 'match_archive_v1';

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

  // --- ARCHIVE LOGIC ---

  static Future<void> saveMatchToArchive(
      {required List<MoveModel> history,
      required int gridSize,
      required String result}) async {
    // 1. Load existing archive
    List<dynamic> archive = [];
    String? existingData = _prefs.getString(keyMatchArchive);
    if (existingData != null) {
      archive = jsonDecode(existingData);
    }

    // 2. Add new match to the top
    Map<String, dynamic> newMatch = {
      'date': DateTime.now().toIso8601String(),
      'gridSize': gridSize,
      'result': result,
      'moves': history.map((m) => m.toJson()).toList(),
    };
    archive.insert(0, newMatch);

    // 3. Limit to last 10 games to save space
    if (archive.length > 10) archive.removeLast();

    // 4. Save back to local storage
    await _prefs.setString(keyMatchArchive, jsonEncode(archive));
  }

  static List<dynamic> getMatchArchive() {
    String? data = _prefs.getString(keyMatchArchive);
    if (data == null) return [];
    return jsonDecode(data);
  }

  static Future<void> recordWin(int winnerId, int p1Score, int p2Score) async {
    await setInt(
        AppConstants.keyGamesPlayed, getInt(AppConstants.keyGamesPlayed) + 1);
    if (winnerId == 1)
      await setInt(AppConstants.keyP1Wins, getInt(AppConstants.keyP1Wins) + 1);
    if (winnerId == 2)
      await setInt(AppConstants.keyP2Wins, getInt(AppConstants.keyP2Wins) + 1);
    int currentHigh = getInt(AppConstants.keyHighScore);
    if (p1Score > currentHigh) await setInt(AppConstants.keyHighScore, p1Score);
    if (p2Score > currentHigh) await setInt(AppConstants.keyHighScore, p2Score);
  }
}

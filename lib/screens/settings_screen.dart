import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "SETTINGS",
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader("AUDIO & HAPTICS"),
          _settingCard(
            title: "SOUND EFFECTS",
            subtitle: "In-game clicks and scoring music",
            value: settings.soundEnabled,
            icon: Icons.volume_up_rounded,
            onChanged: (v) => settings.toggleSound(v),
            accentColor: Colors.blueAccent,
          ),
          _settingCard(
            title: "HAPTIC VIBRATION",
            subtitle: "Physical feedback during battle",
            value: settings.vibrationEnabled,
            icon: Icons.vibration_rounded,
            onChanged: (v) => settings.toggleVibration(v),
            accentColor: Colors.cyanAccent,
          ),
          const SizedBox(height: 30),
          _buildSectionHeader("DATA MANAGEMENT"),
          _actionCard(
            context,
            title: "RESET ALL STATISTICS",
            subtitle: "Clear wins, scores, and match history",
            icon: Icons.delete_forever_rounded,
            color: Colors.redAccent,
            onTap: () => _showResetDialog(context),
          ),
          const SizedBox(height: 40),
          _buildSectionHeader("ABOUT GAME"),
          _infoCard("VERSION", "1.0.0 (BETA)"),
          _infoCard("ENGINE", "FLUTTER 3.0 (DART 3)"),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              "CREATED FOR SOS GRID BATTLE",
              style: TextStyle(
                  color: Colors.white10,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _settingCard({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color accentColor,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        // Sharp professional 0.5 white border
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 0.5),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        activeTrackColor: accentColor.withOpacity(0.3),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }

  Widget _actionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          color: color.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _infoCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 11,
                  fontWeight: FontWeight.w900)),
          Text(value,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white10)),
        title: const Text("ERASE ALL DATA?",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        content: const Text(
            "This will permanently delete your match archive and win records.",
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("CANCEL", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              // Implementation of data clearing (needs to be added to StorageService)
              // For now, it resets keys
              await StorageService.setInt(AppConstants.keyGamesPlayed, 0);
              await StorageService.setInt(AppConstants.keyP1Wins, 0);
              await StorageService.setInt(AppConstants.keyP2Wins, 0);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("DELETE EVERYTHING",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

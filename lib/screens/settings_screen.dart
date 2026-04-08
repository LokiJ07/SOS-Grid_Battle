import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Toggle game sounds'),
            value: settings.soundEnabled,
            onChanged: (val) => settings.toggleSound(val),
          ),
          SwitchListTile(
            title: const Text('Vibration'),
            subtitle: const Text('Haptic feedback on score'),
            value: settings.vibrationEnabled,
            onChanged: (val) => settings.toggleVibration(val),
          ),
        ],
      ),
    );
  }
}

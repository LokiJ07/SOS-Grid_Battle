import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/cell_model.dart';

class SkillModal extends StatelessWidget {
  final Function(EffectType) onSelect;

  const SkillModal({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    // Definition of targetable items
    final List<Map<String, dynamic>> scanOptions = [
      {
        'type': EffectType.jackpot,
        'name': 'SCAN FOR JACKPOT (+5)',
        'icon': Icons.stars_rounded
      },
      {
        'type': EffectType.shield,
        'name': 'SCAN FOR SHIELD',
        'icon': Icons.shield_rounded
      },
      {
        'type': EffectType.extraHeart,
        'name': 'SCAN FOR EXTRA HEART',
        'icon': Icons.add_box_rounded
      },
      {
        'type': EffectType.lifeSteal,
        'name': 'SCAN FOR LIFE STEAL',
        'icon': Icons.health_and_safety_rounded
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),

          const Text("TACTICAL SCAN",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 2)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
                "Choose one specific item type to reveal.\nIf that item isn't on the board, the skill is wasted.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white38, fontSize: 11, height: 1.4)),
          ),

          const SizedBox(height: 10),

          // Generating the list items from scanOptions
          ...scanOptions.map((opt) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 0.5),
                ),
                child: ListTile(
                  leading:
                      Icon(opt['icon'], color: Colors.blueAccent, size: 22),
                  title: Text(opt['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 12,
                          letterSpacing: 1)),
                  trailing: const Icon(Icons.radar_rounded,
                      color: Colors.white10, size: 18),
                  onTap: () {
                    onSelect(opt['type']); // Trigger the scan logic in Provider
                    Navigator.pop(context); // Close the modal
                  },
                ),
              )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

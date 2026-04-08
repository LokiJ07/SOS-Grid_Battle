import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData icon; // Required parameter
  final bool isSecondary;

  const MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon, // Constructor updated
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: isSecondary ? 14 : 18, horizontal: 20),
          decoration: BoxDecoration(
            color: isSecondary
                ? Colors.white.withOpacity(0.03)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSecondary
                  ? Colors.white.withOpacity(0.3)
                  : Colors.white.withOpacity(0.6),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: isSecondary ? 18 : 22,
                  color: isSecondary ? Colors.white38 : Colors.blueAccent),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  fontSize: isSecondary ? 14 : 16,
                  fontWeight: isSecondary ? FontWeight.normal : FontWeight.w500,
                  color: isSecondary ? Colors.white70 : Colors.white,
                  letterSpacing: isSecondary ? 1.2 : 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }
}

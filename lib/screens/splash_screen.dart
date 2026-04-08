import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main_menu_screen.dart';
import '../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to main menu after a short delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Fixed: Corrected from MainValueAlignment
          children: [
            Text(
              'SOS',
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppConstants.player1Color,
                letterSpacing: 10,
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(),
            const SizedBox(height: 10),
            Text(
              'GRID BATTLE',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 4,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}

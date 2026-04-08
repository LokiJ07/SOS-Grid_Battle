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
    // Navigate to Menu after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainMenuScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your logo image from assets
            Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(delay: 200.ms, curve: Curves.elasticOut),

            const SizedBox(height: 20),

            // Subtitle text
            const Text(
              "GRID BATTLE",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 1.seconds),
          ],
        ),
      ),
    );
  }
}

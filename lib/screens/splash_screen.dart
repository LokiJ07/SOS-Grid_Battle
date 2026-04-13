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

    // Transition to Main Menu after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainMenuScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background Ambient Glow (Pulsing)
          Container(
            decoration: BoxDecoration(
              // FIXED: Changed 'radialGradient' to 'gradient'
              gradient: RadialGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.1),
                  Colors.transparent,
                ],
                radius: 1.2,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(1, 1),
              end: const Offset(1.4, 1.4),
              duration: 3.seconds,
              curve: Curves.easeInOut),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. Main Logo with Glow and Shimmer
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 50,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Image.asset(
                  'assets/logo.png',
                  width: 160,
                  height: 160,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms)
                  .shimmer(
                      delay: 1200.ms, duration: 1500.ms, color: Colors.white24),

              const SizedBox(height: 30),

              // 3. Studio Subtitle
              Text(
                "LoKiJ PRESENTS",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  letterSpacing: 8,
                  fontWeight: FontWeight.w900, // Correct heavy weight
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0),

              const SizedBox(height: 60),

              // 4. Stylized Loading Bar
              _buildLoadingBar(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBar() {
    return SizedBox(
      width: 180,
      height: 2,
      child: Stack(
        children: [
          // Background Track
          Container(
            width: double.infinity,
            height: 2,
            color: Colors.white.withOpacity(0.05),
          ),
          // Animated Loading Streak
          Container(
            width: 60, // Width of the moving streak
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0),
                  Colors.blueAccent,
                  Colors.blueAccent.withOpacity(0),
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).moveX(
              begin: -60, end: 180, duration: 1200.ms, curve: Curves.easeInOut),
        ],
      ),
    ).animate().fadeIn(delay: 1500.ms);
  }
}

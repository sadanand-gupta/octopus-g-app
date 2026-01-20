import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    _lineWidthAnimation = Tween<double>(begin: 0.0, end: 100.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 3500), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. THE LOGO
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Image.asset(
                    'assets/icon/icon_1024.png', // Ensure this is your black logo
                    width: 130,
                  ),
                ),

                const SizedBox(height: 20),

                // 2. THE GOLD ACCENT LINE
                AnimatedBuilder(
                  animation: _lineWidthAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 2,
                      width: _lineWidthAnimation.value,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.accentLight
                          ],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 3. THE TEXT
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "OCTOPUS G",
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom subtle branding
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Text(
                  "V 1.0.1",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

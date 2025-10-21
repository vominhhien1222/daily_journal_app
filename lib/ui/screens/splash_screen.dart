import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // ⏳ Chuyển sang Home sau 2.5s
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: settings.isDarkMode
          ? const Color(0xFF3E3A36)
          : const Color(0xFFFDF6EC),
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🐾 Logo hoặc hình biểu tượng vintage
              Image.asset(
                'assets/images/diary_logo.png', // logo
              ),
              const SizedBox(height: 20),
              Text(
                "Daily Journal & Mood",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: "DancingScript",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: settings.isDarkMode
                      ? const Color(0xFFF8E8C8)
                      : const Color(0xFF6B4F3F),
                ),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFBFA67A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

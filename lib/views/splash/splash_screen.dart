import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Simulate loading or check auth status here
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Navigate to Login Screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Image.asset(
            'assets/logo/logo-app.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback text if the image asset is missing during development
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Noctoriagoras Cosrent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

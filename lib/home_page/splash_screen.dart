import 'package:flutter/material.dart';
import 'package:robowars_app/theme/app_theme.dart';
import 'package:robowars_app/widgets/cyber_marquee.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward().then((_) {
      _progressController.forward().then((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 6),
            // Top Marquee: moving Right to Left (reverse: false)
            const CyberMarquee(reverse: false),

            // Center Splash Content
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Red robot logo
                        Image.asset(
                          'assets/images/app_logo.png',
                          height: 110,
                          width: 110,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 28),
                        // ROBOWARS title — matching website exactly
                        const Text(
                          'ROBOWARS',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 6.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle — matches website "GRAVITAS '26 · VIT VELLORE"
                        const Text(
                          "GRAVITAS '26  ·  VIT VELLORE",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Progress bar — website style
                        SizedBox(
                          width: 220,
                          child: AnimatedBuilder(
                            animation: _progressAnim,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      // Track
                                      Container(
                                        height: 2,
                                        width: 220,
                                        decoration: BoxDecoration(
                                          color: AppColors.border,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      // Fill
                                      Container(
                                        height: 2,
                                        width: 220 * _progressAnim.value,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryGlow.withValues(alpha: 0.6),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${(_progressAnim.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Marquee: moving Left to Right (reverse: true)
            const CyberMarquee(reverse: true),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}


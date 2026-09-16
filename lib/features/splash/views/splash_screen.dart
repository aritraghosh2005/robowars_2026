import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/shell/views/main_layout.dart';
import 'package:robowars_app/shared/widgets/cyber_marquee.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _masterController;

  late Animation<Alignment> _iconAlign;
  late Animation<Alignment> _textAlign;
  late Animation<double> _textFade;
  late Animation<double> _progressAnim;
  late Animation<Offset> _topMarqueeSlide;
  late Animation<Offset> _bottomMarqueeSlide;
  late Animation<double> _elementsFadeOut;
  late Animation<double> _flightProgress;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // Increased to 4000ms
    );

    // 1. Delay (0-1000ms) - handled by interval starting at 0.25
    // 2. Icon Slide Up (1000ms - 1800ms) -> Interval: 0.25 to 0.45
    _iconAlign = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.35),
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.25, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    // 3. Text Fades & Slides In (1800ms - 2500ms) -> Interval: 0.45 to 0.625
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.45, 0.625, curve: Curves.easeOut),
      ),
    );
    _textAlign = AlignmentTween(
      begin: const Alignment(0, 0.35),
      end: const Alignment(0, 0.15),
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.45, 0.625, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Progress bar (2500ms - 3200ms) -> Interval: 0.625 to 0.8
    _progressAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.625, 0.8, curve: Curves.easeInOut),
      ),
    );

    // 5. Marquees Slide In simultaneously with Text (1800ms - 2500ms)
    _topMarqueeSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.45, 0.625, curve: Curves.easeOutCubic),
      ),
    );
    _bottomMarqueeSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.45, 0.625, curve: Curves.easeOutCubic),
      ),
    );

    // 6. Fade OUT background elements (3400ms - 4000ms) -> Interval: 0.85 to 1.0
    _elementsFadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    // 7. Icon Flight Progress to top-left (3400ms - 4000ms) -> Interval: 0.85 to 1.0
    _flightProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _masterController.forward().then((_) {
      if (mounted) {
        // Now that the logo is perfectly in the corner, push the home screen!
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const MainLayout(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Splash UI that fades out
          FadeTransition(
            opacity: _elementsFadeOut,
            child: Stack(
              children: [
                // Top Marquee (Wrapped in SafeArea to avoid notch)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SlideTransition(
                      position: _topMarqueeSlide,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: CyberMarquee(reverse: false),
                      ),
                    ),
                  ),
                ),
                
                // Bottom Marquee (Wrapped in SafeArea)
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SlideTransition(
                      position: _bottomMarqueeSlide,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: CyberMarquee(reverse: true),
                      ),
                    ),
                  ),
                ),

                // Animated Texts & Progress Bar
                SafeArea(
                  child: AnimatedBuilder(
                    animation: _masterController,
                    builder: (context, child) {
                      return Align(
                        alignment: _textAlign.value,
                        child: FadeTransition(
                          opacity: _textFade,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ROBOWARS title
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
                              // Subtitle
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
                              // Progress bar
                              SizedBox(
                                width: 220,
                                child: Column(
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
                                                color: AppColors.primaryGlow
                                                    .withOpacity(0.6),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // The Flying Logo (Independent of the background fade)
          AnimatedBuilder(
            animation: _masterController,
            builder: (context, child) {
              // Base size and coordinates
              const double initialSize = 172.0;
              const double finalSize = 40.0;
              
              final double flight = _flightProgress.value;
              final double currentSize = initialSize + (finalSize - initialSize) * flight;

              // Start position (Alignment(0, -0.35) converted to absolute top/left)
              final double alignX = _iconAlign.value.x;
              final double alignY = _iconAlign.value.y;

              final double startX = (screenWidth / 2) + (alignX * screenWidth / 2) - (currentSize / 2);
              final double startY = (screenHeight / 2) + (alignY * screenHeight / 2) - (currentSize / 2);

              // End position (Top Left App Bar icon position)
              const double endX = 16.0;
              final double endY = topPadding + 8.0;

              final double currentX = flight == 0 ? startX : startX + (endX - startX) * flight;
              final double currentY = flight == 0 ? startY : startY + (endY - startY) * flight;

              return Positioned(
                left: currentX,
                top: currentY,
                child: SizedBox(
                  width: currentSize,
                  height: currentSize,
                  child: SvgPicture.asset(
                    'assets/images/robowars_logo.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

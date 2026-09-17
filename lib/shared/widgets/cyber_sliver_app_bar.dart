import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

/// Shared SliverAppBar used by all feature screens.
/// Displays the app logo, a page title, and a profile icon.
class CyberSliverAppBar extends ConsumerStatefulWidget {
  final String title;

  /// Optional callback when the menu/drawer icon is tapped.
  final VoidCallback? onMenuTap;

  /// Optional override for tapping the trailing logo. Defaults to null.
  final VoidCallback? onLogoTap;

  const CyberSliverAppBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onLogoTap,
  });

  @override
  ConsumerState<CyberSliverAppBar> createState() => _CyberSliverAppBarState();
}

class _CyberSliverAppBarState extends ConsumerState<CyberSliverAppBar> {
  // Static tap counter so rebuilds or sliver recycling don't lose tap progress
  static int _tapCount = 0;
  static DateTime? _lastTapTime;

  void _handleLogoTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) >
            const Duration(seconds: 2, milliseconds: 500)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    // Trigger standard action (e.g. scroll to top)
    widget.onLogoTap?.call();

    if (_tapCount >= 7) {
      _tapCount = 0;
      HapticFeedback.heavyImpact();
      _showEasterEgg();
    } else if (_tapCount >= 4) {
      HapticFeedback.lightImpact();
    }
  }

  void _showEasterEgg() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.90),
      builder: (context) => const _CyberpunkEasterEggDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final canAccessNotifications = ref.watch(canAccessNotificationsProvider);

    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.pop(context),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed:
                  widget.onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            ),
      centerTitle: true,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2.0,
        ),
      ),
      actions: [
        if (canAccessNotifications)
          IconButton(
            icon: const Badge(
              backgroundColor: Colors.red,
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        GestureDetector(
          onTap: _handleLogoTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: SvgPicture.asset(
              'assets/images/robowars_logo.svg',
              fit: BoxFit.contain,
              width: 40,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CYBERPUNK CRIMSON EASTER EGG DIALOG
// ─────────────────────────────────────────────────────────────────────────────

class _CyberpunkEasterEggDialog extends StatefulWidget {
  const _CyberpunkEasterEggDialog();

  @override
  State<_CyberpunkEasterEggDialog> createState() =>
      _CyberpunkEasterEggDialogState();
}

class _CyberpunkEasterEggDialogState extends State<_CyberpunkEasterEggDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _heartScaleAnimation;
  late final Animation<double> _glowAnimation;

  late final AnimationController _glitchController;

  static const Color _crimson = Color(0xFFFF003C);
  static const Color _deepCrimson = Color(0xFF6B0017);
  static const Color _cyberYellow = Color(0xFFFFE600);
  static const Color _cyberCyan = Color(0xFF00F0FF);
  static const Color _cyberDark = Color(0xFF0C0508);

  @override
  void initState() {
    super.initState();

    // 1. One-shot smooth entry animation (NO loop - avoids any jitter)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );
    _entryController.forward();

    // 2. Smooth heart pulse loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _heartScaleAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Periodic subtle cyber glitch ticker
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 390),
            child: CustomPaint(
              painter: _CyberpunkBorderPainter(
                borderColor: _crimson,
                fillColor: _cyberDark,
                accentColor: _cyberCyan,
                cutSize: 22.0,
              ),
              child: ClipPath(
                clipper: _CyberpunkCutCornerClipper(cutSize: 22.0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hazard caution top bar
                      _buildHazardBar(),
                      const SizedBox(height: 14),

                      // Status Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCyberBadge(
                            label: 'SYS_OVERRIDE // 0x5854',
                            color: _crimson,
                          ),
                          _buildCyberBadge(
                            label: 'CORRUPTED',
                            color: _cyberYellow,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Pulsing Cyber Heart with Crosshair Brackets
                      _buildCyberHeartCore(),
                      const SizedBox(height: 18),

                      // Glitchy "Made with <3 by" Header
                      const Text(
                        'MADE WITH <3 BY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _crimson,
                          letterSpacing: 4.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dual Architect Names with Cyberpunk styling
                      _buildArchitectsTitle(),
                      const SizedBox(height: 6),

                      // Sub-tag
                      const Text(
                        'ROBOWARS 2026',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Space Grotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white54,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Terminal readout block
                      _buildTerminalBlock(),
                      const SizedBox(height: 20),

                      // Cyberpunk Action Button
                      _buildCyberButton(
                        label: 'JACK OUT',
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top hazard caution stripe banner
  Widget _buildHazardBar() {
    return SizedBox(
      height: 16,
      width: double.infinity,
      child: CustomPaint(
        painter: _HazardStripePainter(
          stripeColor: _crimson,
          backgroundColor: Colors.black,
        ),
      ),
    );
  }

  /// Badge indicator
  Widget _buildCyberBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }

  /// Centerpiece: Pulsing crimson heart enclosed in targeting brackets
  Widget _buildCyberHeartCore() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = _heartScaleAnimation.value;
        final glowAlpha = _glowAnimation.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ambient outer crimson glow
            Container(
              width: 90 * scale,
              height: 90 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _crimson.withValues(alpha: glowAlpha * 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Targeting circle & brackets
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _crimson.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
            ),

            // Pulsing Heart Icon
            Transform.scale(
              scale: scale,
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _deepCrimson.withValues(alpha: 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: _crimson.withValues(alpha: glowAlpha),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: _crimson,
                    size: 34,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Animated cyberpunk title showing TBA5854 and j0K3r
  Widget _buildArchitectsTitle() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        // Micro-glitch shift every ~2.5 seconds
        final double glitchOffset =
            (_glitchController.value > 0.94 && _glitchController.value < 0.97)
            ? (math.Random().nextBool() ? 2.0 : -2.0)
            : 0.0;

        return Transform.translate(
          offset: Offset(glitchOffset, 0),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'TBA5854',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _crimson,
                        letterSpacing: 2.0,
                        shadows: [Shadow(color: _crimson, blurRadius: 14)],
                      ),
                    ),
                    TextSpan(
                      text: '  //  ',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _cyberCyan,
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: 'j0K3r',
                      style: TextStyle(
                        fontFamily: 'Space Grotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _cyberYellow,
                        letterSpacing: 2.0,
                        shadows: [Shadow(color: _cyberYellow, blurRadius: 12)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Monospace cyberpunk terminal readout
  Widget _buildTerminalBlock() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _crimson.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _terminalLine('ARCHITECT_01', 'TBA5854', _crimson),
          const SizedBox(height: 4),
          _terminalLine('ARCHITECT_02', 'j0K3r', _cyberYellow),
          const SizedBox(height: 4),
          _terminalLine('PAYLOAD     ', '<3 HEART_EXPLOIT', _cyberCyan),
          const SizedBox(height: 4),
          _terminalLine('ROOT_STATUS ', 'CONGRATS', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _terminalLine(String key, String val, Color valColor) {
    return Row(
      children: [
        Text(
          '> $key : ',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10.5,
            color: Colors.white54,
            letterSpacing: 0.8,
          ),
        ),
        Expanded(
          child: Text(
            val,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: valColor,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  /// Cyberpunk angled button
  Widget _buildCyberButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _crimson.withValues(alpha: 0.18),
          side: const BorderSide(color: _crimson, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new, color: _crimson, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTERS & CLIPPERS FOR CYBERPUNK CHAMFERED EDGES
// ─────────────────────────────────────────────────────────────────────────────

class _CyberpunkCutCornerClipper extends CustomClipper<Path> {
  final double cutSize;

  const _CyberpunkCutCornerClipper({this.cutSize = 20.0});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(cutSize, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cutSize)
      ..lineTo(size.width - cutSize, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cutSize)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _CyberpunkBorderPainter extends CustomPainter {
  final Color borderColor;
  final Color fillColor;
  final Color accentColor;
  final double cutSize;

  const _CyberpunkBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.accentColor,
    required this.cutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(cutSize, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cutSize)
      ..lineTo(size.width - cutSize, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cutSize)
      ..close();

    // Fill
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Outer Glow
    final glowPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
    canvas.drawPath(path, glowPaint);

    // Border Stroke
    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(path, strokePaint);

    // Accent corner brackets on top-right and bottom-left
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    // Top Right Accent
    canvas.drawLine(
      Offset(size.width - 20, 0),
      Offset(size.width, 0),
      accentPaint,
    );
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, 20), accentPaint);

    // Bottom Left Accent
    canvas.drawLine(
      Offset(0, size.height - 20),
      Offset(0, size.height),
      accentPaint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(20, size.height),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Caution hazard stripes
class _HazardStripePainter extends CustomPainter {
  final Color stripeColor;
  final Color backgroundColor;

  const _HazardStripePainter({
    required this.stripeColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final stripePaint = Paint()
      ..color = stripeColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    const double stripeWidth = 8.0;
    const double gap = 8.0;
    final double totalWidth = size.width;
    final double height = size.height;

    for (
      double x = -height;
      x < totalWidth + height;
      x += (stripeWidth + gap)
    ) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - height, height)
        ..lineTo(x - height, height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

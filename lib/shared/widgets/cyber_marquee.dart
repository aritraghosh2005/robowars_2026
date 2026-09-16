import 'package:flutter/material.dart';
import 'package:robowars_app/core/theme/app_theme.dart';

class CyberMarquee extends StatefulWidget {
  final bool reverse;
  final double height;
  final Duration duration;

  const CyberMarquee({
    super.key,
    this.reverse = false,
    this.height = 40,
    this.duration = const Duration(seconds: 20),
  });

  @override
  State<CyberMarquee> createState() => _CyberMarqueeState();
}

class _CyberMarqueeState extends State<CyberMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _contentWidth = 0;
  final GlobalKey _measureKey = GlobalKey();

  // Pattern directly matching the robowars.robovitics.in website marquee:
  // Alternating between red and white words with red bullets between each word.
  static const List<_MarqueeWord> _words = [
    _MarqueeWord('ROBOWARS', true),
    _MarqueeWord('WRECK', false),
    _MarqueeWord('FORGE', true),
    _MarqueeWord('VIT VELLORE', false),
    _MarqueeWord('BATTLE', true),
    _MarqueeWord('ROBOWARS', false),
    _MarqueeWord('WRECK', true),
    _MarqueeWord('FORGE', false),
    _MarqueeWord('VIT VELLORE', true),
    _MarqueeWord('BATTLE', false),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureWidth();
    });
  }

  void _measureWidth() {
    final context = _measureKey.currentContext;
    if (context != null && mounted) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null && box.size.width > 0) {
        setState(() {
          _contentWidth = box.size.width;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSingleSequence({Key? key}) {
    return Row(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: _words.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red bullet dot matching website
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              item.text,
              style: TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
                color: item.isRed ? AppColors.primary : Colors.white,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final width = _contentWidth > 0 ? _contentWidth : 950.0;
            final t = _controller.value;
            final dx = widget.reverse ? (-width + (t * width)) : (-t * width);

            return Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            );
          },
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSingleSequence(key: _measureKey),
                _buildSingleSequence(),
                _buildSingleSequence(),
                _buildSingleSequence(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarqueeWord {
  final String text;
  final bool isRed;
  const _MarqueeWord(this.text, this.isRed);
}

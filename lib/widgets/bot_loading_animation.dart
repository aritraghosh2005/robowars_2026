import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BotLoadingAnimation extends StatefulWidget {
  final double size;

  const BotLoadingAnimation({super.key, this.size = 100.0});

  @override
  State<BotLoadingAnimation> createState() => _BotLoadingAnimationState();
}

class _BotLoadingAnimationState extends State<BotLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Sped up to 700ms total loop (233ms per frame)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;

            // Frame-by-frame discrete switching
            String currentSvg = 'assets/loading/bot1.svg';
            if (progress >= 0.33 && progress < 0.66) {
              currentSvg = 'assets/loading/bot2.svg';
            } else if (progress >= 0.66) {
              currentSvg = 'assets/loading/bot3.svg';
            }

            return SvgPicture.asset(
              currentSvg,
              width: widget.size,
              height: widget.size,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            );
          },
        ),
      ),
    );
  }
}

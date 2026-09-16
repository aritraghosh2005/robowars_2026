import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioVisualizer extends StatefulWidget {
  const AudioVisualizer({super.key});

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class AudioVisualizerController with WidgetsBindingObserver {
  static final AudioVisualizerController _instance = AudioVisualizerController._internal();
  factory AudioVisualizerController() => _instance;
  AudioVisualizerController._internal();

  AudioPlayer? audioPlayer;
  bool isPlaying = false;
  bool hasError = false;
  bool isInitialized = false;
  bool _wasPlayingBeforeFocusLost = false;
  
  StreamSubscription<Duration>? positionSubscription;
  Duration currentPosition = Duration.zero;
  int fakeTimeMs = 0;
  
  List<List<double>>? spectogram;
  int chunkMs = 50;

  Future<void> init() async {
    if (isInitialized) return;
    WidgetsBinding.instance.addObserver(this);
    try {
      final String jsonStr = await rootBundle.loadString('assets/audio/skynut_levels.json');
      final Map<String, dynamic> data = json.decode(jsonStr);
      chunkMs = data['chunk_ms'] ?? 50;
      
      final levelsRaw = data['levels'] as List;
      spectogram = levelsRaw.map((chunk) {
        return (chunk as List).map((e) => (e as num).toDouble()).toList();
      }).toList();

      audioPlayer = AudioPlayer();
      await audioPlayer!.setSource(AssetSource('audio/skynut.mp3'));
      audioPlayer!.setReleaseMode(ReleaseMode.loop);
      
      positionSubscription = audioPlayer!.onPositionChanged.listen((pos) {
        currentPosition = pos;
        if ((fakeTimeMs - pos.inMilliseconds).abs() > 200) {
           fakeTimeMs = pos.inMilliseconds;
        }
      });
      isInitialized = true;
    } catch (e) {
      debugPrint("Audio load error: $e");
      hasError = true;
    }
  }

  Future<void> pause() async {
    if (hasError || audioPlayer == null || !isPlaying) return;
    await audioPlayer!.pause();
    isPlaying = false;
  }

  Future<void> resume() async {
    if (hasError || audioPlayer == null || isPlaying) return;
    fakeTimeMs = currentPosition.inMilliseconds;
    await audioPlayer!.resume();
    isPlaying = true;
  }

  Future<void> togglePlay() async {
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }
  
  Future<void> restart() async {
    if (hasError || audioPlayer == null) return;
    await audioPlayer!.seek(Duration.zero);
    fakeTimeMs = 0;
    if (!isPlaying) {
      await resume();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      if (isPlaying) {
        _wasPlayingBeforeFocusLost = true;
        pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforeFocusLost) {
        resume();
        _wasPlayingBeforeFocusLost = false;
      }
    }
  }
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  final _controller = AudioVisualizerController();

  final int barCount = 64;
  late List<double> targetLevels;
  late List<double> currentLevels;
  late AnimationController _animController;
  int _lastSwap = 0;
  
  DateTime? _lastTickTime;
  
  double _currentScale = 1.0;
  double _currentAmplitude = 0.0;
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _initAudio();
    
    targetLevels = List.filled(barCount, 0.0);
    currentLevels = List.filled(barCount, 0.0);
    
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animController.addListener(_tick);
    _animController.repeat();
  }

  Future<void> _initAudio() async {
    await _controller.init();
    if (mounted) setState(() {});
  }

  void _generateRealisticTargets(int timeMs) {
    if (_controller.spectogram == null || _controller.spectogram!.isEmpty) return;

    int chunkIndex = timeMs ~/ _controller.chunkMs;
    if (chunkIndex < 0) chunkIndex = 0;
    if (chunkIndex >= _controller.spectogram!.length) {
      chunkIndex = chunkIndex % _controller.spectogram!.length; 
    }

    final chunk = _controller.spectogram![chunkIndex];
    
    // Fix breathing by tracking the MAX amplitude (beat) rather than the average,
    // which was getting dragged down by the quiet high-frequency bands.
    double maxAmp = 0;
    for (int i = 0; i < chunk.length; i++) {
        if (chunk[i] > maxAmp) maxAmp = chunk[i];
    }
    _currentAmplitude = maxAmp;

    final frameRandom = Random(timeMs ~/ 80);

    const List<int> scatterMap = [
      17, 4, 28, 11, 2, 21, 9, 31, 
      14, 6, 25, 1, 19, 12, 29, 8, 
      3, 22, 16, 7, 26, 10, 30, 0, 
      13, 20, 5, 27, 15, 24, 18, 23
    ];

    // Distribute the 32 FFT frequency bands completely randomly around the circle
    for (int i = 0; i < 32; i++) {
      double baseFftLevel = chunk[i];
      int mappedIndex = scatterMap[i];
      
      final barRandom = Random(i * 137); 
      double reactivity = 0.4 + barRandom.nextDouble() * 0.6; 
      double jumpiness = barRandom.nextDouble() * 0.5;
      
      // Make the wave travel physically around the circle using mappedIndex
      double wave = (sin(timeMs / (200.0 + barRandom.nextDouble() * 200) + mappedIndex) * 0.5 + 0.5) * 0.4;
      
      // Combine true FFT data with the previous dynamic math simulation
      double level = (baseFftLevel * reactivity) + 
                     (frameRandom.nextDouble() * baseFftLevel * jumpiness) + 
                     (wave * baseFftLevel);
                     
      level = level.clamp(0.0, 1.0);
      
      // Apply symmetrically so left and right sides match
      targetLevels[mappedIndex] = level;
      targetLevels[barCount - 1 - mappedIndex] = level;
    }

    // SPATIAL BLUR: Smooth out the jagged spikes by blending each bar with its physical neighbors.
    // This turns randomly scattered sharp spikes into beautiful, organic, rolling hills!
    List<double> smoothed = List.filled(barCount, 0.0);
    for (int i = 0; i < barCount; i++) {
      double l2 = targetLevels[(i - 2 + barCount) % barCount];
      double l1 = targetLevels[(i - 1 + barCount) % barCount];
      double c  = targetLevels[i];
      double r1 = targetLevels[(i + 1) % barCount];
      double r2 = targetLevels[(i + 2) % barCount];
      
      // 5-bar weighted moving average.
      // We multiply by 2.0 to restore the height that gets flattened out by the blur, ensuring they reach the top!
      smoothed[i] = ((c * 0.35) + (l1 * 0.2) + (r1 * 0.2) + (l2 * 0.125) + (r2 * 0.125)) * 2.0;
      smoothed[i] = smoothed[i].clamp(0.0, 1.0);
    }
    
    for (int i = 0; i < barCount; i++) {
      targetLevels[i] = smoothed[i];
    }
  }

  void _tick() {
    if (!_controller.isPlaying) {
      for (int i = 0; i < barCount; i++) {
        currentLevels[i] *= 0.85;
        if (currentLevels[i] < 0.005) currentLevels[i] = 0;
      }
      // Idle breathing when paused
      _currentScale = 1.0 + sin(DateTime.now().millisecondsSinceEpoch / 1000.0) * 0.03;
      _lastTickTime = null;
      setState(() {});
      return;
    }

    final now = DateTime.now();
    if (_lastTickTime != null) {
      _controller.fakeTimeMs += now.difference(_lastTickTime!).inMilliseconds;
    }
    _lastTickTime = now;

    // Generate new targets every ~100ms for responsiveness
    final chunk = _controller.fakeTimeMs ~/ 100;
    if (chunk != _lastSwap) {
      _generateRealisticTargets(_controller.fakeTimeMs);
      _lastSwap = chunk;
    }
    
    // Active breathing when playing, driven by audio amplitude
    double targetScale = 1.0 + _currentAmplitude * 0.15;
    _currentScale += (targetScale - _currentScale) * 0.2;
    
    // Continuous rotation
    _currentRotation += 0.008;

    for (int i = 0; i < barCount; i++) {
      final target = targetLevels[i];
      final speed = target > currentLevels[i] ? 0.25 : 0.15;
      currentLevels[i] += (target - currentLevels[i]) * speed;
    }
    setState(() {});
  }

  void _togglePlay() async {
    await _controller.togglePlay();
    setState(() {});
  }
  
  void _restart() async {
    await _controller.restart();
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    // Intentionally NOT disposing the singleton _controller.audioPlayer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.hasError) {
      return const SizedBox(
        width: 200, 
        height: 200, 
        child: Center(child: Text('Audio Error', style: TextStyle(color: Colors.red))),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _currentScale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_controller.isPlaying)
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent, // Required to cast shadow
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.12),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.15),
                              blurRadius: 30,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    // Optional Glow Layer (much more efficient than individual shadows)
                    if (_controller.isPlaying)
                      Transform.rotate(
                        angle: _currentRotation,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: CustomPaint(
                            size: const Size(160, 160),
                            painter: VisualizerPainter(levels: currentLevels),
                          ),
                        ),
                      ),
                    // Main Visualizer Layer
                    Transform.rotate(
                      angle: _currentRotation,
                      child: CustomPaint(
                        size: const Size(160, 160),
                        painter: VisualizerPainter(levels: currentLevels),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _controller.isPlaying
                  ? GestureDetector(
                      key: const ValueKey('playing'),
                      onTap: _togglePlay,
                      child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      color: Colors.red.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20),
                      ],
                    ),
                    child: const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                )
                : Container(
                    key: const ValueKey('paused'),
                      width: 60,
                      height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    color: Colors.white.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15),
                    ],
                  ),
                  child: ClipOval(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _restart,
                            behavior: HitTestBehavior.opaque,
                            child: const Center(
                              child: Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Container(width: 1, color: Colors.white.withOpacity(0.3)),
                        Expanded(
                          child: GestureDetector(
                            onTap: _togglePlay,
                            behavior: HitTestBehavior.opaque,
                            child: const Center(
                              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _controller.isPlaying ? 'NOW PLAYING' : 'PAUSED',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final List<double> levels;
  VisualizerPainter({required this.levels});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final innerRadius = 38.0;
    final outerRadius = 65.0;
    final barCount = 64;
    final segmentCount = 10;
    final segmentGap = 1.0;
    final barGapAngle = 0.018;

    final range = outerRadius - innerRadius;

    for (int i = 0; i < barCount; i++) {
      final level = levels[i];
      final angle = (i / barCount) * pi * 2 - pi / 2;
      final halfGap = barGapAngle / 2;
      final startAngle = angle - (pi / barCount) + halfGap;
      final sweepAngle = (pi / barCount) * 2 - barGapAngle;

      for (int s = 0; s < segmentCount; s++) {
        final segFraction = s / segmentCount;
        final segEnd = (s + 1) / segmentCount;
        final segInner = innerRadius + segFraction * range;
        final segOuter = innerRadius + segEnd * range - segmentGap;
        
        final lit = (s + 1) / segmentCount <= level + 0.05;
        final partiallyLit = !lit && s / segmentCount < level + 0.05;

        final paint = Paint()..style = PaintingStyle.fill;

        if (!lit && !partiallyLit) {
          paint.color = Colors.white.withOpacity(0.08); // slightly dimmer base for dark red theme
        } else {
          final t = s / (segmentCount - 1);
          // Reversed palette: Bright crimson at the bottom (t=0) fading to dark maroon at the top (t=1)
          final r = (190 - t * 140).round(); // 190 to 50
          final g = (10 - t * 10).round();   // 10 to 0
          final b = (10 - t * 10).round();   // 10 to 0
          final opacity = 1.0 - t * 0.25;    // Optional: make the tips slightly more transparent
          paint.color = Color.fromRGBO(r, g, b, opacity);
        }

        final path = Path();
        path.arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: segInner),
          startAngle,
          sweepAngle,
          true,
        );
        path.arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: segOuter),
          startAngle + sweepAngle,
          -sweepAngle,
          false,
        );
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant VisualizerPainter oldDelegate) {
    return true; 
  }
}


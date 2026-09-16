import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/features/shell/views/main_layout.dart';
import 'package:robowars_app/features/splash/views/splash_screen.dart';

import 'package:robowars_app/features/shell/views/widgets/audio_visualizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Pre-load the audio visualizer assets and player in the background
  AudioVisualizerController().init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Robowars'26",
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MainLayout(),
      },
    );
  }
}

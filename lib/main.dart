import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/routing/app_router.dart';
import 'package:robowars_app/core/theme/app_theme.dart';
import 'package:robowars_app/firebase_options.dart';
import 'package:robowars_app/services/fcm_service.dart';

final class MyObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      debugPrint('Provider ${context.provider.name ?? context.provider.runtimeType} threw an error: ${newValue.error}\n${newValue.stackTrace}');
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('Provider ${context.provider.name ?? context.provider.runtimeType} failed: $error\n$stackTrace');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Cloud Messaging
  final fcmService = FcmService();
  await fcmService.initialize();

  runApp(ProviderScope(
    observers: [MyObserver()],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Robowars'26",
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

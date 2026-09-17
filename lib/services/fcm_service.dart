import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission (required on iOS and web)
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('FCM permission: ${settings.authorizationStatus}');
    }

    // Background message handler is not supported on web.
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  Future<void> subscribeBasedOnRole(AppUser user) async {
    // Topic subscriptions are Android/iOS only — not supported on web.
    if (kIsWeb) return;

    // Unsubscribe from previous role topics to avoid overlap.
    await _messaging.unsubscribeFromTopic('participants');
    if (user.teamId != null) {
      await _messaging.unsubscribeFromTopic(user.teamId!);
    }

    if (user.role == UserRole.participant) {
      await _messaging.subscribeToTopic('participants');
      if (user.teamId != null) {
        await _messaging.subscribeToTopic(user.teamId!);
        if (kDebugMode) print('FCM subscribed: ${user.teamId}');
      }
    }
  }
}

// Background message handler must be a top-level function.
// Only called on Android/iOS — never on web.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) print('Background message: ${message.messageId}');
}

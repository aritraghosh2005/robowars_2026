import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission (Required for iOS, web)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> subscribeBasedOnRole(AppUser user) async {
    // First unsubscribe from previous potential roles to avoid overlap
    await _messaging.unsubscribeFromTopic('participants');
    if (user.teamId != null) {
      await _messaging.unsubscribeFromTopic('team_${user.teamId}');
    }

    // Subscribe based on current role
    if (user.role == UserRole.participant) {
      await _messaging.subscribeToTopic('participants');
      if (user.teamId != null) {
        await _messaging.subscribeToTopic('team_${user.teamId}');
        if (kDebugMode) {
          print('Subscribed to topic: team_${user.teamId}');
        }
      }
      if (kDebugMode) {
        print('Subscribed to topic: participants');
      }
    }
  }
}

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

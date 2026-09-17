import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationService extends _$NotificationService {
  late FirebaseMessaging _messaging;

  @override
  FutureOr<void> build() async {
    _messaging = FirebaseMessaging.instance;
    await _init();
  }

  Future<void> _init() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Subscribe to global topic for all users
        if (!kIsWeb) {
          await _messaging.subscribeToTopic('all_users');
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  Future<void> subscribeToRole(String role) async {
    if (kIsWeb) return;
    try {
      await _messaging.subscribeToTopic(role);
    } catch (e) {
      debugPrint('Failed to subscribe to role $role: $e');
    }
  }

  Future<void> unsubscribeFromRole(String role) async {
    if (kIsWeb) return;
    try {
      await _messaging.unsubscribeFromTopic(role);
    } catch (e) {
      debugPrint('Failed to unsubscribe from role $role: $e');
    }
  }
}

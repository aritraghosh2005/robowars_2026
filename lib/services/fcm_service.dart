import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:robowars_app/features/auth/models/app_user.dart';

class FcmService {
  factory FcmService() => _instance;

  FcmService._();

  static final FcmService _instance = FcmService._();
  static const _notificationChannel = MethodChannel(
    'robowars/notifications',
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _subscribedTeamTopic;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

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
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      FirebaseMessaging.onMessage.listen(
        _showForegroundNotification,
      );
    }
  }

  Future<void> subscribeBasedOnRole(AppUser user) async {
    if (kIsWeb) return;

    await _messaging.unsubscribeFromTopic('participants');
    await _messaging.unsubscribeFromTopic('role_viewer');
    await _messaging.unsubscribeFromTopic('role_participant');
    if (_subscribedTeamTopic != null) {
      await _messaging.unsubscribeFromTopic(_subscribedTeamTopic!);
      _subscribedTeamTopic = null;
    }

    await _messaging.subscribeToTopic('role_all');
    if (user.role == UserRole.participant) {
      await _messaging.subscribeToTopic('participants');
      await _messaging.subscribeToTopic('role_participant');
      if (user.teamId != null && user.teamId!.isNotEmpty) {
        _subscribedTeamTopic = 'team_${user.teamId}';
        await _messaging.subscribeToTopic(_subscribedTeamTopic!);
      }
    } else if (user.role == UserRole.viewer) {
      await _messaging.subscribeToTopic('role_viewer');
    }

    if (kDebugMode) {
      final token = await _messaging.getToken();
      debugPrint('FCM ready for ${user.role.name}; token: $token');
    }
  }

  Future<void> clearSubscriptions() async {
    if (kIsWeb) return;
    await _messaging.unsubscribeFromTopic('participants');
    await _messaging.unsubscribeFromTopic('role_all');
    await _messaging.unsubscribeFromTopic('role_viewer');
    await _messaging.unsubscribeFromTopic('role_participant');
    if (_subscribedTeamTopic != null) {
      await _messaging.unsubscribeFromTopic(_subscribedTeamTopic!);
      _subscribedTeamTopic = null;
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null || kIsWeb) return;
    try {
      await _notificationChannel.invokeMethod<void>('showNotification', {
        'title': notification.title ?? 'Robowars',
        'body': notification.body ?? '',
      });
    } on PlatformException catch (error) {
      debugPrint('Could not show foreground notification: $error');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint('Background message: ${message.messageId}');
  }
}

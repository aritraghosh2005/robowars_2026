import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';

class NotificationSenderState {
  final bool isLoading;
  final String? error;

  NotificationSenderState({this.isLoading = false, this.error});

  NotificationSenderState copyWith({bool? isLoading, String? error}) {
    return NotificationSenderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationSenderViewModel extends Notifier<NotificationSenderState> {
  @override
  NotificationSenderState build() {
    return NotificationSenderState();
  }

  Future<bool> sendNotification(String title, String content) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final roleState = await ref.read(roleServiceProvider.future);
      if (roleState.service is! AdminService) {
        throw Exception("Permission denied. Not an admin.");
      }

      final dao = ref.read(notificationDaoProvider);
      await dao.createNotification(title, content);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final notificationSenderViewModelProvider =
    NotifierProvider<NotificationSenderViewModel, NotificationSenderState>(() {
  return NotificationSenderViewModel();
});

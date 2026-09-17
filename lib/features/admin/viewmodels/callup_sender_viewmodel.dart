import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';

class CallupSenderState {
  final bool isLoading;
  final String? error;

  CallupSenderState({this.isLoading = false, this.error});

  CallupSenderState copyWith({bool? isLoading, String? error}) {
    return CallupSenderState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CallupSenderViewModel extends Notifier<CallupSenderState> {
  @override
  CallupSenderState build() {
    return CallupSenderState();
  }

  Future<bool> sendCallup(String teamId, String teamName, String message) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final roleState = await ref.read(roleServiceProvider.future);
      if (roleState.service is! AdminService) {
        throw Exception("Permission denied. Not an admin.");
      }

      final dao = ref.read(callupDaoProvider);
      await dao.createCallup(teamId: teamId, teamName: teamName, message: message);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final callupSenderViewModelProvider =
    NotifierProvider<CallupSenderViewModel, CallupSenderState>(() {
  return CallupSenderViewModel();
});

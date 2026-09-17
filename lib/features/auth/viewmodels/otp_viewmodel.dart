import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';

part 'otp_viewmodel.g.dart';

enum OtpStateEnum { initial, sending, codeSent, verifying, success, error }

class OtpState {
  final OtpStateEnum status;
  final String? verificationId;
  final String? error;
  
  const OtpState({
    this.status = OtpStateEnum.initial,
    this.verificationId,
    this.error,
  });

  OtpState copyWith({
    OtpStateEnum? status,
    String? verificationId,
    String? error,
  }) {
    return OtpState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      error: error, // overwrite error always (null means clear)
    );
  }
}

@riverpod
class OtpViewModel extends _$OtpViewModel {
  @override
  OtpState build() {
    return const OtpState();
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: OtpStateEnum.sending, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyPhoneNumber(
        phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            status: OtpStateEnum.codeSent,
            verificationId: verificationId,
          );
        },
        verificationFailed: (String error) {
          state = state.copyWith(
            status: OtpStateEnum.error,
            error: error,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(status: OtpStateEnum.error, error: e.toString());
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    if (state.verificationId == null) return;
    
    state = state.copyWith(status: OtpStateEnum.verifying, error: null);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithSmsCode(
        verificationId: state.verificationId!,
        smsCode: smsCode,
      );
      state = state.copyWith(status: OtpStateEnum.success);
    } catch (e) {
      state = state.copyWith(status: OtpStateEnum.error, error: 'Invalid OTP code');
    }
  }

  void reset() {
    state = const OtpState();
  }
}

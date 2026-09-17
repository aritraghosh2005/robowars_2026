// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OtpViewModel)
final otpViewModelProvider = OtpViewModelProvider._();

final class OtpViewModelProvider
    extends $NotifierProvider<OtpViewModel, OtpState> {
  OtpViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otpViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otpViewModelHash();

  @$internal
  @override
  OtpViewModel create() => OtpViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OtpState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OtpState>(value),
    );
  }
}

String _$otpViewModelHash() => r'625f19fd8331c5fd8cdb9a8515cd19a4a00e5978';

abstract class _$OtpViewModel extends $Notifier<OtpState> {
  OtpState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OtpState, OtpState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OtpState, OtpState>,
              OtpState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

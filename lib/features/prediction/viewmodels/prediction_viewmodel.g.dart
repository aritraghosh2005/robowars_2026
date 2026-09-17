// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PredictionViewModel)
final predictionViewModelProvider = PredictionViewModelProvider._();

final class PredictionViewModelProvider
    extends $NotifierProvider<PredictionViewModel, AsyncValue<void>> {
  PredictionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'predictionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$predictionViewModelHash();

  @$internal
  @override
  PredictionViewModel create() => PredictionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$predictionViewModelHash() =>
    r'684442fb97229474473171b758acd93212d978bd';

abstract class _$PredictionViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

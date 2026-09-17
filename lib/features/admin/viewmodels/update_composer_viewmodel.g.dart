// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_composer_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdateComposerViewModel)
final updateComposerViewModelProvider = UpdateComposerViewModelProvider._();

final class UpdateComposerViewModelProvider
    extends $NotifierProvider<UpdateComposerViewModel, AsyncValue<void>> {
  UpdateComposerViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateComposerViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateComposerViewModelHash();

  @$internal
  @override
  UpdateComposerViewModel create() => UpdateComposerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$updateComposerViewModelHash() =>
    r'a53c854d12c86f24d5818fba5db96fbe33672f32';

abstract class _$UpdateComposerViewModel extends $Notifier<AsyncValue<void>> {
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

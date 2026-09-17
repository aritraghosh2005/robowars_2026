// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpdatesViewModel)
final updatesViewModelProvider = UpdatesViewModelProvider._();

final class UpdatesViewModelProvider
    extends $NotifierProvider<UpdatesViewModel, AsyncValue<List<UpdateItem>>> {
  UpdatesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updatesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updatesViewModelHash();

  @$internal
  @override
  UpdatesViewModel create() => UpdatesViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<UpdateItem>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<UpdateItem>>>(value),
    );
  }
}

String _$updatesViewModelHash() => r'e1e2bfea1caf43041eff01eaf67d8de7f372a7e1';

abstract class _$UpdatesViewModel
    extends $Notifier<AsyncValue<List<UpdateItem>>> {
  AsyncValue<List<UpdateItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<UpdateItem>>, AsyncValue<List<UpdateItem>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UpdateItem>>,
                AsyncValue<List<UpdateItem>>
              >,
              AsyncValue<List<UpdateItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

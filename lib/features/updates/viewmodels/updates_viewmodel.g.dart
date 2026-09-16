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
    extends $NotifierProvider<UpdatesViewModel, List<UpdateItem>> {
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
  Override overrideWithValue(List<UpdateItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UpdateItem>>(value),
    );
  }
}

String _$updatesViewModelHash() => r'95026275f38225e66c689a0db29fe546806fa281';

abstract class _$UpdatesViewModel extends $Notifier<List<UpdateItem>> {
  List<UpdateItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<UpdateItem>, List<UpdateItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<UpdateItem>, List<UpdateItem>>,
              List<UpdateItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_editor_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MatchEditorViewModel)
final matchEditorViewModelProvider = MatchEditorViewModelProvider._();

final class MatchEditorViewModelProvider
    extends $NotifierProvider<MatchEditorViewModel, MatchEditorState> {
  MatchEditorViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchEditorViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchEditorViewModelHash();

  @$internal
  @override
  MatchEditorViewModel create() => MatchEditorViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchEditorState>(value),
    );
  }
}

String _$matchEditorViewModelHash() =>
    r'2ad16f7a980dd2032752ea9718e6575376cfc993';

abstract class _$MatchEditorViewModel extends $Notifier<MatchEditorState> {
  MatchEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MatchEditorState, MatchEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MatchEditorState, MatchEditorState>,
              MatchEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

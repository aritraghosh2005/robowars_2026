// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_editor_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TeamEditorViewModel)
final teamEditorViewModelProvider = TeamEditorViewModelProvider._();

final class TeamEditorViewModelProvider
    extends $NotifierProvider<TeamEditorViewModel, TeamEditorState> {
  TeamEditorViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamEditorViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamEditorViewModelHash();

  @$internal
  @override
  TeamEditorViewModel create() => TeamEditorViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamEditorState>(value),
    );
  }
}

String _$teamEditorViewModelHash() =>
    r'a88238c59e9ecc02599ca7a45acc9363485df34c';

abstract class _$TeamEditorViewModel extends $Notifier<TeamEditorState> {
  TeamEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TeamEditorState, TeamEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TeamEditorState, TeamEditorState>,
              TeamEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

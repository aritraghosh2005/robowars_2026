// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teams_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single source of truth for all Teams screen data and view state.

@ProviderFor(TeamsViewModel)
final teamsViewModelProvider = TeamsViewModelProvider._();

/// Single source of truth for all Teams screen data and view state.
final class TeamsViewModelProvider
    extends $NotifierProvider<TeamsViewModel, TeamsState> {
  /// Single source of truth for all Teams screen data and view state.
  TeamsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'teamsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$teamsViewModelHash();

  @$internal
  @override
  TeamsViewModel create() => TeamsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TeamsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TeamsState>(value),
    );
  }
}

String _$teamsViewModelHash() => r'43ad155977a833c7dd7f6f25df1c835938597d2d';

/// Single source of truth for all Teams screen data and view state.

abstract class _$TeamsViewModel extends $Notifier<TeamsState> {
  TeamsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TeamsState, TeamsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TeamsState, TeamsState>,
              TeamsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

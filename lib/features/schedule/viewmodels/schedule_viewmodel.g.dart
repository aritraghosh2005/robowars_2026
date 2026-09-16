// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the schedule screen state: match data and the selected tab.

@ProviderFor(ScheduleViewModel)
final scheduleViewModelProvider = ScheduleViewModelProvider._();

/// Manages the schedule screen state: match data and the selected tab.
final class ScheduleViewModelProvider
    extends $NotifierProvider<ScheduleViewModel, ScheduleState> {
  /// Manages the schedule screen state: match data and the selected tab.
  ScheduleViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scheduleViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scheduleViewModelHash();

  @$internal
  @override
  ScheduleViewModel create() => ScheduleViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScheduleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScheduleState>(value),
    );
  }
}

String _$scheduleViewModelHash() => r'ab5cb2a3944c7f90691c475670c1191489f9940a';

/// Manages the schedule screen state: match data and the selected tab.

abstract class _$ScheduleViewModel extends $Notifier<ScheduleState> {
  ScheduleState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScheduleState, ScheduleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScheduleState, ScheduleState>,
              ScheduleState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

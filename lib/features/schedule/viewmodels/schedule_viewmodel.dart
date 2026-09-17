import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'schedule_viewmodel.g.dart';

class ScheduleState {
  final AsyncValue<List<Match>> matches;
  final String selectedTab;
  final String selectedWeightCategory;

  const ScheduleState({
    this.matches = const AsyncLoading(),
    this.selectedTab = 'Upcoming',
    this.selectedWeightCategory = 'All',
  });

  ScheduleState copyWith({
    AsyncValue<List<Match>>? matches,
    String? selectedTab,
    String? selectedWeightCategory,
  }) {
    return ScheduleState(
      matches: matches ?? this.matches,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedWeightCategory: selectedWeightCategory ?? this.selectedWeightCategory,
    );
  }
}

/// Manages the schedule screen state: match data and the selected tab.
@riverpod
class ScheduleViewModel extends _$ScheduleViewModel {
  @override
  ScheduleState build() {
    final matchDao = ref.watch(matchDaoProvider);

    ref.listen<AsyncValue<List<Match>>>(
      StreamProvider((ref) => matchDao.watchMatches()),
      (previous, next) {
        state = state.copyWith(matches: next);
      },
      fireImmediately: true,
    );

    return const ScheduleState();
  }

  void setTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void setWeightCategory(String category) {
    state = state.copyWith(selectedWeightCategory: category);
  }

  List<Match> get filteredMatches {
    final allMatches = state.matches.asData?.value ?? [];
    final filtered = allMatches.where((match) {
      final matchesTab = state.selectedTab == 'Completed'
          ? match.status == 'completed' || match.winner.isNotEmpty
          : match.status != 'completed' && match.winner.isEmpty;
      final matchesCategory = state.selectedWeightCategory == 'All' ||
          match.category == state.selectedWeightCategory;
      return matchesTab && matchesCategory;
    }).toList();

    filtered.sort((a, b) {
      final aStart = a.scheduledAt;
      final bStart = b.scheduledAt;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return state.selectedTab == 'Completed'
          ? bStart.compareTo(aStart)
          : aStart.compareTo(bStart);
    });
    return filtered;
  }
}

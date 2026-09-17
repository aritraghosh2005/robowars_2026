import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'teams_viewmodel.g.dart';

class TeamsState {
  final AsyncValue<List<Team>> teams;
  final bool isTeamsSelected;
  final String selectedWeightCategory;

  const TeamsState({
    this.teams = const AsyncLoading(),
    this.isTeamsSelected = true,
    this.selectedWeightCategory = 'All',
  });

  TeamsState copyWith({
    AsyncValue<List<Team>>? teams, 
    bool? isTeamsSelected,
    String? selectedWeightCategory,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      isTeamsSelected: isTeamsSelected ?? this.isTeamsSelected,
      selectedWeightCategory: selectedWeightCategory ?? this.selectedWeightCategory,
    );
  }
}

/// Single source of truth for all Teams screen data and view state.
@riverpod
class TeamsViewModel extends _$TeamsViewModel {
  @override
  TeamsState build() {
    // Listen to firestore stream
    final repository = ref.read(teamDaoProvider);
    
    ref.listen<AsyncValue<List<Team>>>(
      StreamProvider((ref) => repository.watchTeams()),
      (previous, next) {
        state = state.copyWith(teams: next);
      },
      fireImmediately: true,
    );

    return const TeamsState();
  }

  void toggleView(bool isTeams) {
    state = state.copyWith(isTeamsSelected: isTeams);
  }

  void setWeightCategory(String category) {
    state = state.copyWith(selectedWeightCategory: category);
  }

  List<Team> get filteredTeams {
    final allTeams = state.teams.asData?.value ?? [];
    if (state.selectedWeightCategory == 'All') {
      return allTeams;
    }
    return allTeams.where((team) => team.bots.any((bot) => bot.weight == state.selectedWeightCategory)).toList();
  }
}

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/admin/states/team_editor_state.dart';
import 'package:robowars_app/features/teams/models/team.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';


part 'team_editor_viewmodel.g.dart';

@riverpod
class TeamEditorViewModel extends _$TeamEditorViewModel {
  StreamSubscription<List<Team>>? _teamsSubscription;

  @override
  TeamEditorState build() {
    ref.onDispose(() {
      _teamsSubscription?.cancel();
    });

    final roleState = ref.watch(roleServiceProvider).asData?.value;
    
    if (roleState == null || roleState.hasError) {
      return const TeamEditorState(isLoading: false, errorMessage: 'Service not available or error occurred');
    }

    if (roleState.service is AdminService) {
      final teamDao = ref.watch(teamDaoProvider);
      
      _teamsSubscription?.cancel();
      _teamsSubscription = teamDao.watchTeams().listen(
        (teams) {
          state = state.copyWith(isLoading: false, teams: teams, errorMessage: null);
        },
        onError: (error) {
          state = state.copyWith(isLoading: false, errorMessage: error.toString());
        },
      );
      return const TeamEditorState(isLoading: true);
    } else {
      return const TeamEditorState(isLoading: false, errorMessage: 'Permission denied: Not an admin');
    }
  }

  void selectTeam(Team? team) {
    state = state.copyWith(selectedTeam: team);
  }

  Future<void> saveTeam(Team team) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    
    try {
      final roleState = ref.read(roleServiceProvider).asData?.value;
      if (roleState?.service is! AdminService) {
        throw Exception('Permission denied: Not an admin');
      }
      
      final teamDao = ref.read(teamDaoProvider);
      
      if (state.teams.any((t) => t.id == team.id)) {
        await teamDao.updateTeam(team);
      } else {
        await teamDao.createTeam(team);
      }
      
      state = state.copyWith(isSaving: false, selectedTeam: null);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save team: $e');
    }
  }

  Future<void> deleteTeam(String teamId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    
    try {
      final roleState = ref.read(roleServiceProvider).asData?.value;
      if (roleState?.service is! AdminService) {
        throw Exception('Permission denied: Not an admin');
      }
      
      final teamDao = ref.read(teamDaoProvider);
      await teamDao.deleteTeam(teamId);
      
      state = state.copyWith(
        isSaving: false, 
        selectedTeam: state.selectedTeam?.id == teamId ? null : state.selectedTeam,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to delete team: $e');
    }
  }
}

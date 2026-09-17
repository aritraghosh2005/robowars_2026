import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/admin/states/match_editor_state.dart';
import 'package:robowars_app/features/schedule/models/match.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/services/service_providers.dart';


part 'match_editor_viewmodel.g.dart';

@riverpod
class MatchEditorViewModel extends _$MatchEditorViewModel {
  StreamSubscription<List<Match>>? _matchesSubscription;

  @override
  MatchEditorState build() {
    ref.onDispose(() {
      _matchesSubscription?.cancel();
    });

    final roleState = ref.watch(roleServiceProvider).asData?.value;
    
    if (roleState == null || roleState.hasError) {
      return const MatchEditorState(isLoading: false, errorMessage: 'Service not available or error occurred');
    }

    if (roleState.service is AdminService) {
      final matchDao = ref.watch(matchDaoProvider);
      
      _matchesSubscription?.cancel();
      _matchesSubscription = matchDao.watchMatches().listen(
        (matches) {
          state = state.copyWith(isLoading: false, matches: matches, errorMessage: null);
        },
        onError: (error) {
          state = state.copyWith(isLoading: false, errorMessage: error.toString());
        },
      );
      return const MatchEditorState(isLoading: true);
    } else {
      return const MatchEditorState(isLoading: false, errorMessage: 'Permission denied: Not an admin');
    }
  }

  void selectMatch(Match? match) {
    state = state.copyWith(selectedMatch: match);
  }

  Future<void> saveMatch(Match match) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    
    try {
      final roleState = ref.read(roleServiceProvider).asData?.value;
      if (roleState?.service is! AdminService) {
        throw Exception('Permission denied: Not an admin');
      }
      
      final matchDao = ref.read(matchDaoProvider);
      
      // If the match already exists in our list, update it. Otherwise, create it.
      if (state.matches.any((m) => m.id == match.id)) {
        await matchDao.updateMatch(match);
      } else {
        await matchDao.createMatch(match);
      }
      
      // Clear selection after saving
      state = state.copyWith(isSaving: false, selectedMatch: null);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to save match: $e');
    }
  }

  Future<void> deleteMatch(String matchId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    
    try {
      final roleState = ref.read(roleServiceProvider).asData?.value;
      if (roleState?.service is! AdminService) {
        throw Exception('Permission denied: Not an admin');
      }
      
      final matchDao = ref.read(matchDaoProvider);
      await matchDao.deleteMatch(matchId);
      
      state = state.copyWith(
        isSaving: false, 
        selectedMatch: state.selectedMatch?.id == matchId ? null : state.selectedMatch,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Failed to delete match: $e');
    }
  }
}

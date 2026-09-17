import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:robowars_app/features/teams/models/team.dart';

part 'team_editor_state.freezed.dart';

@freezed
abstract class TeamEditorState with _$TeamEditorState {
  const factory TeamEditorState({
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default([]) List<Team> teams,
    Team? selectedTeam,
    @Default(false) bool isSaving,
  }) = _TeamEditorState;
}

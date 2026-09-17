import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

part 'match_editor_state.freezed.dart';

@freezed
abstract class MatchEditorState with _$MatchEditorState {
  const factory MatchEditorState({
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default([]) List<Match> matches,
    Match? selectedMatch,
    @Default(false) bool isSaving,
  }) = _MatchEditorState;
}

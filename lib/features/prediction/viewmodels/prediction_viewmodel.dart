import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/prediction/repositories/prediction_providers.dart';
import 'package:robowars_app/core/auth/auth_providers.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

part 'prediction_viewmodel.g.dart';

@riverpod
class PredictionViewModel extends _$PredictionViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submitPrediction(Match match, String predictedWinner) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authStateProvider).asData?.value;
      if (user == null) {
        throw StateError('Please sign in to make a prediction.');
      }
      if (!match.isPredictionOpen) {
        throw StateError('Predictions closed when this match started.');
      }

      final predictedWinnerTeamId = predictedWinner == match.team1
          ? match.team1Id
          : predictedWinner == match.team2
              ? match.team2Id
              : '';

      final predictionRepo = ref.read(predictionRepositoryProvider);
      await predictionRepo.submitPrediction(
        matchId: match.id,
        userId: user.uid,
        predictedWinnerTeamId: predictedWinnerTeamId,
        pointsMultiplier: 1.0,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

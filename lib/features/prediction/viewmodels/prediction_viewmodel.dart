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
      final user = ref.read(currentUserProvider);
      if (user == null) {
        throw Exception('User not logged in');
      }

      final predictionRepo = ref.read(predictionRepositoryProvider);
      await predictionRepo.submitPrediction(
        matchId: match.id,
        userId: user.uid,
        predictedWinnerTeamId: predictedWinner,
        pointsMultiplier: 1.0,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

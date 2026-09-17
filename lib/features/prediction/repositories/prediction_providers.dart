import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/firebase/firebase_providers.dart';
import 'package:robowars_app/features/prediction/repositories/prediction_repository.dart';

final predictionRepositoryProvider = Provider<PredictionRepository>((ref) {
  return FirestorePredictionRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

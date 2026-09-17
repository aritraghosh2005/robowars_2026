import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:robowars_app/core/config/app_config_repository.dart';
import 'package:robowars_app/core/firebase/firebase_providers.dart';

final appConfigRepositoryProvider = Provider<AppConfigRepository>((ref) {
  return FirestoreAppConfigRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

final moodMessageProvider = StreamProvider<String>((ref) {
  final repo = ref.watch(appConfigRepositoryProvider);
  return repo.getMoodMessage();
});

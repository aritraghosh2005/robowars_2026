import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@riverpod
Stream<bool> connectivity(Ref ref) async* {
  final connectivity = Connectivity();
  
  // Yield initial state
  final initialResult = await connectivity.checkConnectivity();
  yield !initialResult.contains(ConnectivityResult.none);

  // Listen for changes
  await for (final result in connectivity.onConnectivityChanged) {
    yield !result.contains(ConnectivityResult.none);
  }
}

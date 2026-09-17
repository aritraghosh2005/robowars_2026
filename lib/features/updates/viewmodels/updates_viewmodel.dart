import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'updates_viewmodel.g.dart';

@riverpod
class UpdatesViewModel extends _$UpdatesViewModel {
  @override
  AsyncValue<List<UpdateItem>> build() {
    final updateDao = ref.watch(updateDaoProvider);

    ref.listen<AsyncValue<List<UpdateItem>>>(
      StreamProvider((ref) => updateDao.watchUpdates()),
      (previous, next) {
        state = next;
      },
      fireImmediately: true,
    );

    return const AsyncLoading();
  }
}


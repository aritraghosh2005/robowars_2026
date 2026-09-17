import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/admin/auth/admin_service.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/services/service_providers.dart';
import 'package:uuid/uuid.dart';

part 'update_composer_viewmodel.g.dart';

@riverpod
class UpdateComposerViewModel extends _$UpdateComposerViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> submitUpdate({
    required String title,
    required String content,
    required UpdateTag tag,
  }) async {
    state = const AsyncLoading();
    try {
      final roleState = ref.read(roleServiceProvider).asData?.value;
      if (roleState == null || roleState.service is! AdminService) {
        throw Exception('Not authorized');
      }

      final updateDao = ref.read(updateDaoProvider);

      // Create a nice time string like "Just now" for display until stream updates
      // In a real app we might use server timestamps and formatting, but this is a simple text field currently
      final newUpdate = UpdateItem(
        id: const Uuid().v4(),
        title: title,
        content: content,
        time: 'Just now', // Hardcoded here, but the DAO handles timestamp if firebase
        tag: tag,
      );

      await updateDao.createUpdate(newUpdate);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

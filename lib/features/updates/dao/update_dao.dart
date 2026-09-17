import 'package:robowars_app/features/updates/models/update_item.dart';

abstract class UpdateDao {
  /// Stream all updates, ordered by time descending.
  Stream<List<UpdateItem>> watchUpdates();
  
  /// Create a new update.
  Future<void> createUpdate(UpdateItem update);
  
  /// Delete an update by ID.
  Future<void> deleteUpdate(String updateId);
}

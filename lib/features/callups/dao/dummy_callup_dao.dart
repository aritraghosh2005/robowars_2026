import 'package:robowars_app/features/callups/models/callup_item.dart';
import 'package:robowars_app/features/callups/dao/callup_dao.dart';
import 'package:uuid/uuid.dart';

class DummyCallupDao implements CallupDao {
  final List<CallupItem> _callups = [];

  @override
  Stream<List<CallupItem>> watchCallups() {
    return Stream.value([..._callups]);
  }

  @override
  Stream<CallupItem?> watchActiveCallupForTeam(String teamId) {
    try {
      final activeCallup = _callups.firstWhere((c) => c.teamId == teamId && c.isActive);
      return Stream.value(activeCallup);
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  Future<void> createCallup({required String teamId, required String teamName, required String message}) async {
    _callups.insert(0, CallupItem(
      id: const Uuid().v4(),
      teamId: teamId,
      teamName: teamName,
      message: message,
      isActive: true,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> dismissCallup(String callupId) async {
    final index = _callups.indexWhere((c) => c.id == callupId);
    if (index != -1) {
      final old = _callups[index];
      _callups[index] = CallupItem(
        id: old.id,
        teamId: old.teamId,
        teamName: old.teamName,
        message: old.message,
        isActive: false,
        timestamp: old.timestamp,
      );
    }
  }
}

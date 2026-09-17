import 'package:robowars_app/features/callups/models/callup_item.dart';

abstract class CallupDao {
  Stream<List<CallupItem>> watchCallups();
  Stream<CallupItem?> watchActiveCallupForTeam(String teamId);
  Future<void> createCallup({required String teamId, required String teamName, required String message});
  Future<void> dismissCallup(String callupId);
}

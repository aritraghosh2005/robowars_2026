import 'package:robowars_app/features/updates/models/update_item.dart';
import 'package:robowars_app/features/updates/dao/update_dao.dart';
import 'package:uuid/uuid.dart';

class DummyUpdateDao implements UpdateDao {
  final List<UpdateItem> _updates = [
    const UpdateItem(
      id: 'update1',
      title: 'Registration Closing Soon',
      content: 'Make sure your robot meets all safety guidelines before final weigh-in at 5:00 PM today.',
      time: '1h ago',
      tag: UpdateTag.alert,
    ),
    const UpdateItem(
      id: 'update2',
      title: 'Bracket Updated',
      content: 'The elimination brackets for the 15kg weight class have been posted on the main board.',
      time: '2h ago',
      tag: UpdateTag.update,
    ),
    const UpdateItem(
      id: 'update3',
      title: 'Match 14 Result',
      content: 'Terminal Velocity defeated Byte Me by knockout in 1 minute 42 seconds.',
      time: '3h ago',
      tag: UpdateTag.results,
    ),
    const UpdateItem(
      id: 'update4',
      title: 'Safety Inspection Update',
      content: 'Teams 20-40 please report to the pit area for secondary safety inspections.',
      time: '4h ago',
      tag: UpdateTag.info,
    ),
  ];

  @override
  Stream<List<UpdateItem>> watchUpdates() {
    return Stream.value([..._updates]);
  }

  @override
  Future<void> createUpdate(UpdateItem update) async {
    final newUpdate = UpdateItem(
      id: const Uuid().v4(),
      title: update.title,
      content: update.content,
      time: update.time,
      tag: update.tag,
    );
    _updates.insert(0, newUpdate); // Insert at start
  }

  @override
  Future<void> deleteUpdate(String updateId) async {
    _updates.removeWhere((item) => item.id == updateId);
  }
}

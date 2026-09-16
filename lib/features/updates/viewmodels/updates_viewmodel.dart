import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/updates/models/update_item.dart';

part 'updates_viewmodel.g.dart';

@riverpod
class UpdatesViewModel extends _$UpdatesViewModel {
  @override
  List<UpdateItem> build() {
    return const [
      UpdateItem(
        title: 'Round 1 Results: Featherweight',
        content: 'Team Orcus\'s "Raven" clinched victory in a stunning KO against "Byte Crusher". The bot\'s spinner was unstoppable.',
        time: '2 hrs ago',
        tag: UpdateTag.results,
      ),
      UpdateItem(
        title: 'Match Delayed: Arena Inspection',
        content: 'The heavyweight bout between Team Shadow and Team Nexus has been delayed by 30 minutes for arena safety checks.',
        time: '3 hrs ago',
        tag: UpdateTag.alert,
      ),
      UpdateItem(
        title: 'Schedule Update: Day 2',
        content: 'The semifinals bracket has been updated. Check the Schedule tab for the latest matchup times and pairings.',
        time: '5 hrs ago',
        tag: UpdateTag.update,
      ),
      UpdateItem(
        title: 'KO of the Day: Firestorm Dominates',
        content: 'Team Blaze\'s "Firestorm" delivered the most spectacular KO of the day, launching "Ice Breaker" 3 feet into the air.',
        time: '6 hrs ago',
        tag: UpdateTag.highlight,
      ),
      UpdateItem(
        title: 'Registration Reminder',
        content: 'Walk-in registrations close tonight at 10 PM. All competing teams must verify their bot weight at the check-in desk.',
        time: '8 hrs ago',
        tag: UpdateTag.info,
      ),
      UpdateItem(
        title: 'Day 1 Recap: 12 Matches Completed',
        content: 'A thrilling Day 1 saw 12 matches across all weight classes. The Featherweight category had the most upsets so far.',
        time: '10 hrs ago',
        tag: UpdateTag.recap,
      ),
    ];
  }
}

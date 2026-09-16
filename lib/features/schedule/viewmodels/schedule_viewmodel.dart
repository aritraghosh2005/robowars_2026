import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/schedule/models/match.dart';

part 'schedule_viewmodel.g.dart';

class ScheduleState {
  final List<Match> matches;
  final String selectedTab;

  const ScheduleState({
    required this.matches,
    this.selectedTab = 'Upcoming',
  });

  ScheduleState copyWith({
    List<Match>? matches,
    String? selectedTab,
  }) {
    return ScheduleState(
      matches: matches ?? this.matches,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

/// Manages the schedule screen state: match data and the selected tab.
@riverpod
class ScheduleViewModel extends _$ScheduleViewModel {
  @override
  ScheduleState build() {
    return const ScheduleState(
      matches: [
        Match(
          team1: 'Team Shadow', bot1: 'Dark Matter',
          team2: 'Team Xenon', bot2: 'Cyclone X',
          category: '60 kg', time: '9:00 AM', winner: 'Team Shadow',
        ),
        Match(
          team1: 'Team Phoenix', bot1: 'Inferno',
          team2: 'Team Nexus', bot2: 'Storm Rider',
          category: '15 kg', time: '10:30 AM', winner: 'Team Phoenix',
        ),
        Match(
          team1: 'Team Orcus', bot1: 'Raven',
          team2: 'Team Venom', bot2: 'Serpent',
          category: '8 kg', time: '12:00 PM', winner: 'Team Orcus',
        ),
        Match(
          team1: 'Team Thunder', bot1: 'Bolt',
          team2: 'Team Titan', bot2: 'Colossus',
          category: '60 kg', time: '2:00 PM', winner: 'Team Thunder',
        ),
        Match(
          team1: 'Team Blaze', bot1: 'Firestorm',
          team2: 'Team Ice', bot2: 'Glacier',
          category: '15 kg', time: '3:30 PM', winner: 'Team Blaze',
        ),
      ],
    );
  }

  void setTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/teams/models/bot.dart';
import 'package:robowars_app/features/teams/models/team.dart';

part 'teams_viewmodel.g.dart';

class TeamsState {
  final List<Team> teams;
  final bool isTeamsSelected;

  const TeamsState({
    required this.teams,
    this.isTeamsSelected = true,
  });

  TeamsState copyWith({List<Team>? teams, bool? isTeamsSelected}) {
    return TeamsState(
      teams: teams ?? this.teams,
      isTeamsSelected: isTeamsSelected ?? this.isTeamsSelected,
    );
  }
}

/// Single source of truth for all Teams screen data and view state.
@riverpod
class TeamsViewModel extends _$TeamsViewModel {
  static const String _sharedDescription =
      'A battle-hardened team from across the nation, bringing precision-engineered war machines designed for maximum impact in the arena.';

  @override
  TeamsState build() {
    return TeamsState(
      teams: [
        Team(name: 'Team Orcus', bots: [Bot(name: 'Raven', weight: '60 kg'), Bot(name: 'Vulcan', weight: '15 kg')], description: _sharedDescription, wins: 4, losses: 1, pts: 8),
        Team(name: 'Team Shadow', bots: [Bot(name: 'Dark Matter', weight: '15 kg'), Bot(name: 'Phantom', weight: '8 kg')], description: _sharedDescription, wins: 3, losses: 2, pts: 6),
        Team(name: 'Team Phoenix', bots: [Bot(name: 'Inferno', weight: '8 kg'), Bot(name: 'Blaze', weight: '60 kg')], description: _sharedDescription, wins: 5, losses: 0, pts: 10),
        Team(name: 'Team Nexus', bots: [Bot(name: 'Cyclone', weight: '60 kg'), Bot(name: 'Storm', weight: '15 kg')], description: _sharedDescription, wins: 2, losses: 3, pts: 4),
        Team(name: 'Team Thunder', bots: [Bot(name: 'Bolt', weight: '15 kg'), Bot(name: 'Thunder', weight: '8 kg')], description: _sharedDescription, wins: 4, losses: 2, pts: 8),
        Team(name: 'Team Titan', bots: [Bot(name: 'Colossus', weight: '8 kg'), Bot(name: 'Golem', weight: '60 kg')], description: _sharedDescription, wins: 1, losses: 4, pts: 2),
        Team(name: 'Team Blaze', bots: [Bot(name: 'Firestorm', weight: '60 kg'), Bot(name: 'Ember', weight: '15 kg')], description: _sharedDescription, wins: 3, losses: 2, pts: 6),
        Team(name: 'Team Ice', bots: [Bot(name: 'Glacier', weight: '15 kg'), Bot(name: 'Frost', weight: '8 kg')], description: _sharedDescription, wins: 2, losses: 3, pts: 4),
      ],
    );
  }

  void toggleView(bool isTeams) {
    state = state.copyWith(isTeamsSelected: isTeams);
  }
}

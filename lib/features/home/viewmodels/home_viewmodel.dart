import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/home/models/contender.dart';
import 'package:robowars_app/features/home/models/matchup.dart';

part 'home_viewmodel.g.dart';

/// Encapsulates all data displayed on the Home screen.
/// Currently uses static data; designed to be swapped for live API calls.
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    return const HomeState();
  }
}

class HomeState {
  final List<Matchup> matchups;
  final List<Contender> contenders;
  final Map<String, String> quickStats;

  const HomeState({
    this.matchups = const [
      Matchup(team1: 'Team Shadow', bot1: 'Dark Matter', team2: 'Team Apex', bot2: 'Apex Predator', category: '60 kg'),
      Matchup(team1: 'Team Phoenix', bot1: 'Inferno', team2: 'Team Nexus', bot2: 'Cyclone', category: '15 kg'),
      Matchup(team1: 'Team Orcus', bot1: 'Raven', team2: 'Team Venom', bot2: 'Serpent', category: '8 kg'),
      Matchup(team1: 'Team Thunder', bot1: 'Bolt', team2: 'Team Titan', bot2: 'Colossus', category: '60 kg'),
      Matchup(team1: 'Team Blaze', bot1: 'Firestorm', team2: 'Team Ice', bot2: 'Glacier', category: '15 kg'),
      Matchup(team1: 'Team Steel', bot1: 'Iron Will', team2: 'Team Ghost', bot2: 'Phantom', category: '8 kg'),
    ],
    this.contenders = const [
      Contender(name: 'Thunder Strike', team: 'Team Xenon', result: 'QF Winner'),
      Contender(name: 'Iron Jaws', team: 'Team TerrorBulls', result: 'SF Winner'),
      Contender(name: 'Apex Predator', team: 'Team Apex', result: 'QF Winner'),
      Contender(name: 'Dark Matter', team: 'Team Shadow', result: 'Top 8'),
    ],
    this.quickStats = const {
      'Teams': '40+',
      'Bots': '45+',
      'Prize Pool': '₹1L+',
      'Categories': '3',
    },
  });
}

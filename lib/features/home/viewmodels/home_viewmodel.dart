import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:robowars_app/features/home/models/contender.dart';

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
  final List<Contender> contenders;
  final Map<String, String> quickStats;

  const HomeState({
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

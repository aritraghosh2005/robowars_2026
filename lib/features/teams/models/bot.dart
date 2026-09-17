import 'package:robowars_app/features/teams/models/bot_category.dart';

/// Represents a single robot/bot entry for a team.
class Bot {
  final String name;
  final String weight;

  const Bot({required this.name, required this.weight});

  factory Bot.fromMap(Map<String, dynamic> map) {
    return Bot(
      name: map['name'] ?? '',
      weight: BotCategory.normalize(map['weight'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
    };
  }
}

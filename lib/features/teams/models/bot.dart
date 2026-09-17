/// Represents a single robot/bot entry for a team.
class Bot {
  final String name;
  final String weight;

  const Bot({required this.name, required this.weight});

  factory Bot.fromMap(Map<String, dynamic> map) {
    return Bot(
      name: map['name'] ?? '',
      weight: map['weight'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weight': weight,
    };
  }
}

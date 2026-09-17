abstract final class BotCategory {
  static const List<String> values = <String>['8kg', '15kg', '60kg'];

  static String normalize(String? value) {
    final compact = (value ?? '').toLowerCase().replaceAll(' ', '');
    return values.contains(compact) ? compact : '15kg';
  }
}

import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return;

  final regex = RegExp(r'\.withValues\(\s*alpha:\s*([\d.]+)\s*\)');
  
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      if (content.contains('.withValues')) {
        final newContent = content.replaceAllMapped(regex, (match) {
          final alpha = match.group(1);
          return '.withOpacity($alpha)';
        });
        entity.writeAsStringSync(newContent);
        print('Updated ${entity.path}');
      }
    }
  }
}

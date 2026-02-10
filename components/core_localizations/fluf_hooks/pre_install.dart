import 'dart:io';

/// Standalone pre-install hook for core_localizations.
///
/// Sets `generate: true` under the `flutter:` section of pubspec.yaml.
///
/// Usage: dart run pre_install.dart <project_root>
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;
  final pubspecFile = File('$projectRoot/pubspec.yaml');

  if (!pubspecFile.existsSync()) {
    stderr.writeln('pubspec.yaml not found at $projectRoot');
    exit(1);
  }

  final content = pubspecFile.readAsStringSync();
  final lines = content.split('\n');

  bool inFlutterSection = false;
  bool generateFlagFound = false;
  int flutterIndent = 0;
  int flutterLineIndex = -1;

  // Find the flutter section and generate flag
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    if (RegExp(r'^flutter\s*:').hasMatch(line)) {
      inFlutterSection = true;
      flutterLineIndex = i;
      flutterIndent = line.indexOf('flutter');
      continue;
    }

    if (inFlutterSection) {
      if (line.trim().isNotEmpty &&
          !line.startsWith(' ') &&
          !line.startsWith('\t')) {
        inFlutterSection = false;
        continue;
      }

      if (line.trim().isEmpty || line.trim().startsWith('#')) {
        continue;
      }

      final leadingSpaces = line.indexOf(line.trim());
      if (leadingSpaces <= flutterIndent) {
        inFlutterSection = false;
        continue;
      }

      if (RegExp(r'\s+generate\s*:').hasMatch(line)) {
        generateFlagFound = true;
        if (!line.contains('true')) {
          lines[i] = line.replaceFirst(RegExp(r'generate\s*:.*'), 'generate: true');
          stdout.writeln('Updated generate flag to true.');
        } else {
          stdout.writeln('Generate flag already set to true.');
        }
      }
    }
  }

  // Add the generate flag if not found
  if (!generateFlagFound && flutterLineIndex != -1) {
    String indent = '';
    bool foundFirstChild = false;

    for (int i = flutterLineIndex + 1; i < lines.length; i++) {
      final line = lines[i].trimRight();
      if (line.trim().isEmpty || line.trim().startsWith('#')) continue;

      if (RegExp(r'^\s+\w+\s*:').hasMatch(line)) {
        indent = line.substring(0, line.indexOf(line.trim()));
        foundFirstChild = true;
        break;
      }

      if (line.trim().isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t')) {
        break;
      }
    }

    if (!foundFirstChild) {
      indent = ' ' * (flutterIndent + 2);
    }

    lines.insert(flutterLineIndex + 1, '${indent}generate: true');
    stdout.writeln('Added generate: true to flutter section.');
  }

  // If flutter section is not found, add it
  if (flutterLineIndex == -1) {
    lines.add('');
    lines.add('flutter:');
    lines.add('  generate: true');
    stdout.writeln('Added flutter section with generate: true.');
  }

  pubspecFile.writeAsStringSync(lines.join('\n'));
}

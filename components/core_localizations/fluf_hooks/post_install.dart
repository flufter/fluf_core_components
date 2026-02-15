import 'dart:convert';
import 'dart:io';

/// Standalone post-install hook for core_localizations.
///
/// Runs `fvm flutter gen-l10n` to generate localization files.
/// Also writes the AppConfig JSON to the project root for debugging.
///
/// Usage: dart run post_install.dart <project_root> [<app_config_json_path>]
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  // Parse AppConfig from JSON temp file and write it to project root for testing
  if (args.length > 1) {
    final configFile = File(args[1]);
    if (await configFile.exists()) {
      final raw = await configFile.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final prettyJson = const JsonEncoder.withIndent('  ').convert(json);
      final outputFile = File('$projectRoot/debug_app_config.json');
      await outputFile.writeAsString(prettyJson);
      stdout.writeln('Wrote AppConfig to ${outputFile.path}');
    }
  }

  final result = await Process.run(
    'fvm',
    ['flutter', 'gen-l10n'],
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

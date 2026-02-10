import 'dart:io';

/// Standalone post-install hook for core_localizations.
///
/// Runs `fvm flutter gen-l10n` to generate localization files.
///
/// Usage: dart run post_install.dart <project_root>
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

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

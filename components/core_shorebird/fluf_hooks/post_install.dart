import 'dart:io';

/// Standalone post-install hook for core_shorebird.
///
/// Runs `shorebird init` to initialize Shorebird for the project.
///
/// Usage: dart run post_install.dart <project_root>
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  final result = await Process.run(
    'shorebird',
    ['init'],
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

import 'dart:io';

/// Standalone post-install hook for core_splash_screen.
///
/// Runs `fvm dart run flutter_native_splash:create`.
///
/// Usage: dart run post_install.dart <project_root>
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  final result = await Process.run(
    'fvm',
    [
      'dart',
      'run',
      'flutter_native_splash:create',
      '--path=fluf/config/splash_screen.yaml',
    ],
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

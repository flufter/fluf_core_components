import 'dart:convert';
import 'dart:io';

/// Standalone post-install hook for core_shorebird.
///
/// Runs `shorebird init` to initialize Shorebird for the project.
///
/// Usage: dart run post_install.dart <project_root> [<app_config_json_path>]
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  // Read AppConfig from JSON temp file (passed as second arg by the CLI)
  String? displayName;
  if (args.length > 1) {
    final configFile = File(args[1]);
    if (await configFile.exists()) {
      final json =
          jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
      displayName = json['appName'] as String?;
    }
  }

  final shorebirdArgs = <String>['init'];
  if (displayName != null && displayName.isNotEmpty) {
    shorebirdArgs.addAll(['--display-name', displayName]);
  }

  final result = await Process.run(
    'shorebird',
    shorebirdArgs,
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

import 'dart:io';

import 'package:yaml/yaml.dart';

/// Validates fluf_component.yaml files across a component repo.
///
/// Checks:
/// 1. All YAML files parse without errors
/// 2. No two components define the same parameter name with different configs
/// 3. No two components define the same variable name with different configs
///
/// Usage: dart run bin/validate.dart [repo_root]
void main(List<String> args) {
  final repoRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  final scanDirs = ['components', 'legacy', 'unrefactored'];
  final configFileName = 'fluf_component.yaml';

  final seenParams = <String, _ParamDef>{};
  final seenVars = <String, _VarDef>{};
  var errors = 0;
  var filesScanned = 0;

  for (final scanDir in scanDirs) {
    final dir = Directory('$repoRoot/$scanDir');
    if (!dir.existsSync()) continue;

    for (final entry in dir.listSync().whereType<Directory>()) {
      final configFile = File('${entry.path}/$configFileName');
      if (!configFile.existsSync()) continue;

      filesScanned++;
      final brickName = entry.path.split('/').last;

      try {
        final content = configFile.readAsStringSync();
        final yaml = loadYaml(content);
        if (yaml is! YamlMap) {
          stderr.writeln('ERROR: $brickName/$configFileName is not a YAML map');
          errors++;
          continue;
        }

        // Validate parameters
        final paramsList = yaml['parameters'] as YamlList?;
        if (paramsList != null) {
          for (final param in paramsList) {
            if (param is! YamlMap) continue;
            final name = _toSnakeCase(param['name']?.toString() ?? '');
            if (name.isEmpty) continue;

            final def = _ParamDef(
              type: param['type']?.toString() ?? 'string',
              query: param['query']?.toString() ?? '',
              description: param['description']?.toString() ?? '',
              defaultValue: param['defaultValue']?.toString() ?? '',
              options: _toStringList(param['options']),
              environments: _toStringList(param['environments']),
              fromAppConfig: param['fromAppConfig']?.toString(),
              source: brickName,
            );

            final existing = seenParams[name];
            if (existing != null && !existing.matches(def)) {
              stderr.writeln(
                'ERROR: Parameter "$name" defined in $brickName '
                'conflicts with definition in ${existing.source}:',
              );
              _printParamDiff(existing, def);
              errors++;
            } else if (existing == null) {
              seenParams[name] = def;
            }
          }
        }

        // Validate variables
        final varsList = yaml['variables'] as YamlList?;
        if (varsList != null) {
          for (final v in varsList) {
            if (v is! YamlMap) continue;
            final name = _toSnakeCase(v['name']?.toString() ?? '');
            if (name.isEmpty) continue;

            final def = _VarDef(
              description: v['description']?.toString() ?? '',
              isGlobal: v['isGlobal'] as bool? ?? true,
              addToServer: v['addToServer'] as bool? ?? false,
              addToCI: v['addToCI'] as bool? ?? true,
              cascadedVars: _toCascadedList(v['cascadedVars']),
              source: brickName,
            );

            final existing = seenVars[name];
            if (existing != null && !existing.matches(def)) {
              stderr.writeln(
                'ERROR: Variable "$name" defined in $brickName '
                'conflicts with definition in ${existing.source}:',
              );
              _printVarDiff(existing, def);
              errors++;
            } else if (existing == null) {
              seenVars[name] = def;
            }
          }
        }
      } catch (e) {
        stderr.writeln('ERROR: Failed to parse $brickName/$configFileName: $e');
        errors++;
      }
    }
  }

  stdout.writeln('Scanned $filesScanned fluf_component.yaml files.');
  stdout.writeln(
    'Found ${seenParams.length} unique parameters, '
    '${seenVars.length} unique variables.',
  );

  if (errors > 0) {
    stderr.writeln('\n$errors error(s) found.');
    exit(1);
  } else {
    stdout.writeln('No conflicts found.');
  }
}

String _toSnakeCase(String input) {
  // Simple snake_case normalization: lowercase, replace spaces/hyphens with _
  return input
      .replaceAllMapped(
          RegExp(r'[A-Z]'), (m) => '_${m.group(0)!.toLowerCase()}')
      .replaceAll(RegExp(r'[\s-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_'), '')
      .toLowerCase();
}

List<String> _toStringList(dynamic value) {
  if (value == null) return [];
  if (value is YamlList) return value.map((e) => e.toString()).toList();
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

List<(String, String)> _toCascadedList(dynamic value) {
  if (value == null) return [];
  if (value is! YamlList) return [];
  return value.map((e) {
    if (e is YamlMap) {
      return (e['target']?.toString() ?? '', e['template']?.toString() ?? '');
    }
    return ('', '');
  }).toList();
}

void _printParamDiff(_ParamDef a, _ParamDef b) {
  if (a.type != b.type) {
    stderr.writeln('  type: "${a.type}" vs "${b.type}"');
  }
  if (a.query != b.query) {
    stderr.writeln('  query: "${a.query}" vs "${b.query}"');
  }
  if (a.description != b.description) {
    stderr.writeln('  description differs');
  }
  if (a.defaultValue != b.defaultValue) {
    stderr.writeln('  defaultValue: "${a.defaultValue}" vs "${b.defaultValue}"');
  }
  if (a.options.toString() != b.options.toString()) {
    stderr.writeln('  options: ${a.options} vs ${b.options}');
  }
  if (a.fromAppConfig != b.fromAppConfig) {
    stderr.writeln(
      '  fromAppConfig: "${a.fromAppConfig}" vs "${b.fromAppConfig}"',
    );
  }
}

void _printVarDiff(_VarDef a, _VarDef b) {
  if (a.description != b.description) {
    stderr.writeln('  description differs');
  }
  if (a.isGlobal != b.isGlobal) {
    stderr.writeln('  isGlobal: ${a.isGlobal} vs ${b.isGlobal}');
  }
  if (a.addToServer != b.addToServer) {
    stderr.writeln('  addToServer: ${a.addToServer} vs ${b.addToServer}');
  }
  if (a.addToCI != b.addToCI) {
    stderr.writeln('  addToCI: ${a.addToCI} vs ${b.addToCI}');
  }
  if (a.cascadedVars.toString() != b.cascadedVars.toString()) {
    stderr.writeln('  cascadedVars differ');
  }
}

class _ParamDef {
  final String type;
  final String query;
  final String description;
  final String defaultValue;
  final List<String> options;
  final List<String> environments;
  final String? fromAppConfig;
  final String source;

  _ParamDef({
    required this.type,
    required this.query,
    required this.description,
    required this.defaultValue,
    required this.options,
    required this.environments,
    required this.fromAppConfig,
    required this.source,
  });

  bool matches(_ParamDef other) {
    if (type != other.type) return false;
    if (query != other.query) return false;
    if (description != other.description) return false;
    if (defaultValue != other.defaultValue) return false;
    if (options.length != other.options.length) return false;
    for (var i = 0; i < options.length; i++) {
      if (options[i] != other.options[i]) return false;
    }
    if (fromAppConfig != other.fromAppConfig) return false;
    if (environments.length != other.environments.length) return false;
    for (var i = 0; i < environments.length; i++) {
      if (environments[i] != other.environments[i]) return false;
    }
    return true;
  }
}

class _VarDef {
  final String description;
  final bool isGlobal;
  final bool addToServer;
  final bool addToCI;
  final List<(String, String)> cascadedVars;
  final String source;

  _VarDef({
    required this.description,
    required this.isGlobal,
    required this.addToServer,
    required this.addToCI,
    required this.cascadedVars,
    required this.source,
  });

  bool matches(_VarDef other) {
    if (description != other.description) return false;
    if (isGlobal != other.isGlobal) return false;
    if (addToServer != other.addToServer) return false;
    if (addToCI != other.addToCI) return false;
    if (cascadedVars.length != other.cascadedVars.length) return false;
    for (var i = 0; i < cascadedVars.length; i++) {
      if (cascadedVars[i].$1 != other.cascadedVars[i].$1) return false;
      if (cascadedVars[i].$2 != other.cascadedVars[i].$2) return false;
    }
    return true;
  }
}

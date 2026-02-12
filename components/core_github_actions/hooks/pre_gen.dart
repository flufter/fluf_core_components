import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final _ = logger.level;

  final has_core_firebase = context.vars['has_core_firebase'] as bool;
  final has_core_shorebird = context.vars['has_core_shorebird'] as bool;

  context.vars['has_firebase_and_shorebird'] =
      has_core_firebase && has_core_shorebird;
  context.vars['has_firebase_only'] = has_core_firebase && !has_core_shorebird;
  context.vars['has_shorebird_only'] = !has_core_firebase && has_core_shorebird;
  context.vars['has_neither_firebase_nor_shorebird'] =
      !has_core_firebase && !has_core_shorebird;

  final environments = context.vars['environments'] as List<dynamic>?;

  if (environments != null) {
    context.vars['has_dev_env'] = environments.contains('dev');
    context.vars['has_stag_env'] = environments.contains('stag');
    context.vars['has_testing_env'] = environments.contains('testing');
    context.vars['has_prod_env'] = environments.contains('prod');
  }
}

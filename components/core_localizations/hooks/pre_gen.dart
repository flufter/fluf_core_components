import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final _ = logger.level;
  // Add custom logic here

  final environments = context.vars['environments'] as List<dynamic>?;

  if (environments != null) {
    context.vars['has_dev_env'] = environments.contains('dev');
    context.vars['has_stag_env'] = environments.contains('stag');
    context.vars['has_testing_env'] = environments.contains('testing');
    context.vars['has_prod_env'] = environments.contains('prod');
  }
}

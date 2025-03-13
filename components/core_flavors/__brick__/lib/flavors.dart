import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum Flavor {
  {{#has_dev_env}}dev,{{/has_dev_env}}
  {{#has_stag_env}}stag,{{/has_stag_env}}
  {{#has_prod_env}}prod,{{/has_prod_env}}
  {{#has_testing_env}}test,{{/has_testing_env}}
}

class F {
  static Flavor? appFlavor;
}

/// Global function to return the current flavor
Flavor getFlavor() {
  // * On iOS/Android, appFlavor is supported and set with the --flavor option
  // * On web, appFlavor is not supported so we read a separate SW_ENV
  // * variable and set it with --dart-define SW_ENV=dev|stag|prod|test
  const webFlavor = String.fromEnvironment('SW_ENV');
  const flavor = kIsWeb ? webFlavor : appFlavor;
  return switch (flavor) {
    {{#has_dev_env}}'dev' => Flavor.dev,{{/has_dev_env}}
    {{#has_prod_env}}'prod' => Flavor.prod,{{/has_prod_env}}
    {{#has_stag_env}}'stag' => Flavor.stag,{{/has_stag_env}}
    {{#has_testing_env}}'test' => Flavor.test,{{/has_testing_env}}
    null || '' => Flavor.values.first,
    _ => throw UnsupportedError('Invalid flavor: $flavor'),
  };
}

extension FlavorExtension on Flavor {
  String get asString => toString().split('.').last;
}
// ignore_for_file:no-equal-switch-expression-cases,avoid-nullable-interpolation
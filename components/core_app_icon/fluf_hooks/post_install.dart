import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Standalone post-install hook for core_app_icon.
///
/// 1. Removes the alpha channel from the app icon (replaces with white).
/// 2. Runs `fvm flutter pub run flutter_launcher_icons`.
///
/// Usage: dart run post_install.dart <project_root>
void main(List<String> args) async {
  final projectRoot = args.isNotEmpty ? args[0] : Directory.current.path;

  // Step 1: Remove alpha channel from app icon
  final iconPath = '$projectRoot/assets/images/app_icon/app_icon.png';
  final iconFile = File(iconPath);

  if (iconFile.existsSync()) {
    final imageBytes = await iconFile.readAsBytes();
    final originalImage = img.decodePng(imageBytes);

    if (originalImage == null) {
      stderr.writeln('Unable to decode PNG image at: $iconPath');
    } else {
      var hasAlpha = false;
      for (var y = 0; y < originalImage.height && !hasAlpha; y++) {
        for (var x = 0; x < originalImage.width && !hasAlpha; x++) {
          if (originalImage.getPixel(x, y).a != 255) {
            hasAlpha = true;
          }
        }
      }

      if (!hasAlpha) {
        stdout.writeln('No alpha channel found in the image.');
      } else {
        // Create backup
        final backupPath = iconPath.replaceAll(
          RegExp(r'\.png$'),
          '_before_alpha_channel_removal.png',
        );
        await iconFile.copy(backupPath);

        // Create new image without alpha (blend with white)
        final modified = img.Image(
          width: originalImage.width,
          height: originalImage.height,
        );

        for (var y = 0; y < originalImage.height; y++) {
          for (var x = 0; x < originalImage.width; x++) {
            final pixel = originalImage.getPixel(x, y);
            final alpha = pixel.a;

            if (alpha == 0) {
              modified.setPixelRgb(x, y, 255, 255, 255);
            } else {
              final blendedR =
                  ((1 - alpha / 255) * 255 + (alpha / 255) * pixel.r).toInt();
              final blendedG =
                  ((1 - alpha / 255) * 255 + (alpha / 255) * pixel.g).toInt();
              final blendedB =
                  ((1 - alpha / 255) * 255 + (alpha / 255) * pixel.b).toInt();
              modified.setPixelRgb(x, y, blendedR, blendedG, blendedB);
            }
          }
        }

        final outputBytes = Uint8List.fromList(img.encodePng(modified));
        await iconFile.writeAsBytes(outputBytes);
        stdout.writeln('Alpha channel removed from app icon.');
      }
    }
  } else {
    stderr.writeln(
      'App icon file not found at: $iconPath\n'
      'If you changed the app icon\'s location, please update the path in '
      'fluf/config/app_icon.yaml accordingly.\n'
      'Also ensure your app icon image doesn\'t contain any alpha channel '
      '(transparency).',
    );
  }

  // Step 2: Run flutter_launcher_icons
  final result = await Process.run(
    'fvm',
    [
      'flutter',
      'pub',
      'run',
      'flutter_launcher_icons',
      '-f',
      'fluf/config/app_icon.yaml',
    ],
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exit(result.exitCode);
  }
}

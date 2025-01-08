// ignore_for_file: avoid_print

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (name, image, [args]) async {
        try {
          // save the raw file
          final File rawFile =
              await File('./screenshots/raw/$name').create(recursive: true);
          await rawFile.writeAsBytes(image);
          print("Captured raw screenshot: ${rawFile.path}");

          return true;
        } catch (error, stack) {
          print(error.toString());
          print(stack);
          return false;
        }
      },
    );
  } catch (e) {
    print('Error occured: $e');
  }
}

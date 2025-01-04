import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_notepad_v2/views/home.dart';

import 'bootstrap.dart';
import 'utils/screenshot.dart';

Future<void> main() async {
  HttpOverrides.global = _MyHttpOverrides();
  late Uint8List screenshot;

  testWidgets(
    'Main screen',
    (tester) async {
      // Setup
      await tester.setScreenSize(Size(1242, 2688), 3);
      final bootstrapper = await Bootstrapper.getInstance(null);

      // Start our scene
      runApp(
        bootstrapper.wrap(Container()),
      );
      // await tester.pumpAndSettle();

      // Take a screenshot
      screenshot = await takeScreenshot<Container>();
    },
  );

  tearDownAll(() async {
    await File("screenshot.png").writeAsBytes(screenshot, flush: true);
  });
}

class _MyHttpOverrides extends HttpOverrides {}

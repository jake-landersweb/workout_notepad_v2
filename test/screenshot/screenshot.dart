import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:screenshot/screenshot.dart';
import 'package:workout_notepad_v2/main.dart';

import 'device.dart';
import 'server.dart';
import 'store.dart';

var currentIndex = 0;

void main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('Take Screenshots', (tester) async {
    // launch the app and wait for all internal processes
    runApp(MyApp(
      defaultUser:
          '{"userId": "xL3zGrTtKYZp8ml6QiDDFmDu86w2", "displayName": "Ryan Hockings"}',
    ));
    await tester.pumpAndSettle(Duration(seconds: 12));

    // get the media query
    final mediaQuery = MediaQueryData.fromView(
      IntegrationTestWidgetsFlutterBinding.instance.window,
    );

    // ------------ HOMESCREEN
    // homescreen
    await takeScreenshot(
      "homescreen",
      tester,
      mediaQuery,
      storeTitle: "The Notepad Replacement.",
    );

    // exercise summary
    await tester.tap(find.text("Details"));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "post-workout",
      tester,
      mediaQuery,
      storeTitle: "Advanced post-workout reports.",
    );
    await tester.tap(find.byKey(ValueKey("CloseButton2")));
    await tester.pumpAndSettle();

    // workout detail
    await tester.scrollUntilVisible(
      find.text("Arms+Shoulders").first,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Arms+Shoulders").first);
    await tester.pumpAndSettle();
    await takeScreenshot(
      "workout-detail",
      tester,
      mediaQuery,
      storeTitle: "Create your workouts.",
    );

    // workout edit
    await tester.tap(find.text("Edit").first);
    await tester.pumpAndSettle();
    await takeScreenshot(
      "workout-edit",
      tester,
      mediaQuery,
      storeTitle: "With our completely customizable builder.",
    );
    await tester.tap(find.byKey(ValueKey("CloseButton2")));
    await tester.pumpAndSettle();

    // workout launch
    await tester.tap(find.text("Start").first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey("launch-workout-next")));
    await tester.pumpAndSettle();
    await tester.tap(find.text("REPS").first);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Save").first);
    await tester.pumpAndSettle();
    await takeScreenshot(
      "workout-launch",
      tester,
      mediaQuery,
      storeTitle: "Intuative workout launcher.",
    );
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byKey(ValueKey("launch-workout-next")));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text("Cancel").first);
    await tester.pumpAndSettle();
    await tester.tap(find.text("Yes").first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey("BackButton2")));
    await tester.pumpAndSettle();

    // ------------ EXERCISES
    await tester.tap(find.byKey(ValueKey("homescreen-key-Exercises")));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "exercise-home",
      tester,
      mediaQuery,
      storeTitle: "Expandable exercise bank.",
    );

    // exercise detail
    await tester.scrollUntilVisible(
      find.text("Incline Walk"),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Incline Walk"));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "exercise-detail-cardio",
      tester,
      mediaQuery,
      storeTitle: "Comprehensive exercise reports.",
    );
    await tester.tap(find.byKey(ValueKey("CloseButton2")));
    await tester.pumpAndSettle();

    // ------------ DISCOVER
    await tester.tap(find.byKey(ValueKey("homescreen-key-Discover")));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "discover-home",
      tester,
      mediaQuery,
      storeTitle: "Expert-made workout templates.",
    );

    // ------------ INSIGHTS
    await tester.tap(find.byKey(ValueKey("homescreen-key-Insights")));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "insights-home",
      tester,
      mediaQuery,
      storeTitle: "Automatic workout insights.",
    );

    // insights lower
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "insights-home-2",
      tester,
      mediaQuery,
      storeTitle: "Data-driven training.",
    );

    // ------------ LOGS
    await tester.tap(find.byKey(ValueKey("homescreen-key-Logs")));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "logs-home",
      tester,
      mediaQuery,
      storeTitle: "Many visualization dashboards.",
    );

    // raw logs
    await tester.scrollUntilVisible(
      find.text("Raw Workout Logs"),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Raw Workout Logs"));
    await tester.pumpAndSettle();
    await takeScreenshot(
      "raw-workout-logs",
      tester,
      mediaQuery,
      storeTitle: "Workout history.",
    );
    await tester.tap(find.byKey(ValueKey("BackButton2")));
    await tester.pumpAndSettle();
  });
}

Future<void> takeScreenshot(
  String title,
  WidgetTester tester,
  MediaQueryData mediaQuery, {
  String? storeTitle,
}) async {
  String imgTitle = "$title.png";

  // capture the screen
  final binding = IntegrationTestWidgetsFlutterBinding.instance;
  var data = await binding.takeScreenshot(imgTitle);

  // write with a device border
  Widget device = wrapInDevice(Uint8List.fromList(data), mediaQuery);

  // screenshot the raw device
  ScreenshotController screenshotController = ScreenshotController();
  var deviceImage = await screenshotController.captureFromWidget(device);
  await sendScreenshotToServer("device/$currentIndex-$imgTitle", deviceImage);

  if (storeTitle != null) {
    final memoryImage = MemoryImage(deviceImage);

    // capture the large store screenshot
    StoreScreenshot largeStoreScreenshot = StoreScreenshot(
      size: StoreScreenShotSize.iphoneLarge(),
      text: storeTitle,
      deviceImage: memoryImage,
    );
    var storeImageLarge = await screenshotController.captureFromWidget(
      largeStoreScreenshot,
      targetSize: Size(
          largeStoreScreenshot.size.width, largeStoreScreenshot.size.height),
    );
    await sendScreenshotToServer(
        "store-large/$currentIndex-$imgTitle", storeImageLarge);

    // capture the large store screenshot
    StoreScreenshot smallStoreScreenshot = StoreScreenshot(
      size: StoreScreenShotSize.iphoneSmall(),
      text: storeTitle,
      deviceImage: memoryImage,
    );
    var smallImageLarge = await screenshotController.captureFromWidget(
      smallStoreScreenshot,
      targetSize: Size(
          smallStoreScreenshot.size.width, smallStoreScreenshot.size.height),
    );
    await sendScreenshotToServer(
        "store-small/$currentIndex-$imgTitle", smallImageLarge);
  }

  currentIndex++;
}

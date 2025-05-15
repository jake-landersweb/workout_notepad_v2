import 'package:flutter/material.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/logger/events/generic.dart';

Future<void> showPaywall(BuildContext context) async {
  // cupertinoSheet(
  //   context: context,
  //   builder: (context) => const Subscriptions(),
  // );

  final paywallResult = await RevenueCatUI.presentPaywall();
  logger.info("RevenueCat paywall result: ${paywallResult.name}");
  logger.event(GenericEvent(
    "view-paywall",
    metadata: {"result": paywallResult.name},
  ));
}

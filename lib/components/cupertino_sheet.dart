import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';

void cupertinoSheet({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool expand = false,
  bool resizeToAvoidBottomInset = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (context) => Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: builder(context),
    ),
    expand: expand,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Theme.of(context).colorScheme.background,
    animationCurve: Sprung(36),
    previousRouteAnimationCurve: Sprung(36),
    duration: const Duration(milliseconds: 500),
  );
}

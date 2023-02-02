import 'dart:math';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

void cupertinoSheet({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
  bool expand = false,
}) {
  showCupertinoModalBottomSheet(
    context: context,
    builder: (context) => Material(
      color: sui.CustomColors.backgroundColor(context),
      child: builder(context),
    ),
    expand: expand,
    animationCurve: Sprung(36),
    previousRouteAnimationCurve: Sprung(36),
    duration: const Duration(milliseconds: 500),
  );
}

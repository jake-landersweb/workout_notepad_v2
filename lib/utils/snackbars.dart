import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/utils/root.dart';

void snackbarErr(
  BuildContext context,
  String message, {
  Duration? duration,
}) {
  logger.error(message);
  showTopSnackBar(
    Overlay.of(context),
    curve: Sprung.overDamped,
    reverseCurve: Sprung.overDamped,
    displayDuration: const Duration(milliseconds: 3000),
    reverseAnimationDuration: const Duration(milliseconds: 500),
    animationDuration: const Duration(milliseconds: 700),
    CustomSnackBar.error(
      message: message,
    ),
  );
  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(
  //     duration: duration ?? const Duration(seconds: 4),
  //     content: Text(message),
  //     backgroundColor: AppColors.error(),
  //   ),
  // );
}

void snackbarStatus(
  BuildContext context,
  String message, {
  Duration? duration,
  Color? bg,
}) {
  showTopSnackBar(
    Overlay.of(context),
    curve: Sprung.overDamped,
    reverseCurve: Sprung.overDamped,
    displayDuration: const Duration(milliseconds: 3000),
    reverseAnimationDuration: const Duration(milliseconds: 500),
    animationDuration: const Duration(milliseconds: 700),
    CustomSnackBar.info(
      message: message,
      backgroundColor: AppColors.cell(context),
      textStyle: TextStyle(color: AppColors.text(context)),
      icon: const Icon(
        Icons.info_outline_rounded,
        color: Color(0x15000000),
        size: 120,
      ),
    ),
  );
}

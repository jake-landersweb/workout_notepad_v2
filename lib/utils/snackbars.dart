import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/utils/root.dart';

void snackbarErr(
  BuildContext context,
  String message, {
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration ?? const Duration(seconds: 4),
      content: Text(message),
      backgroundColor: AppColors.error(),
    ),
  );
}

void snackbarStatus(
  BuildContext context,
  String message, {
  Duration? duration,
  Color? bg,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration ?? const Duration(seconds: 4),
      content: Text(
        message,
        style: TextStyle(
          color: AppColors.text(context),
        ),
      ),
      backgroundColor: bg ?? AppColors.cell(context)[100],
    ),
  );
}

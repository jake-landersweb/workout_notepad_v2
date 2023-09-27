import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:workout_notepad_v2/utils/root.dart';

/// for conventinely showing an alert that is styled for the current platform.
Future<void> showAlert({
  required BuildContext context,
  required String title,
  required Widget body,
  bool cancelBolded = false,
  required String cancelText,
  required VoidCallback onCancel,
  bool submitBolded = false,
  required String submitText,
  required VoidCallback onSubmit,
  Color? cancelColor,
  Color? submitColor,
}) async {
  if (kIsWeb) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          content: body,
          actions: _materialActions(
            context: context,
            cancelBolded: cancelBolded,
            cancelText: cancelText,
            onCancel: onCancel,
            submitBolded: submitBolded,
            submitText: submitText,
            onSubmit: onSubmit,
            cancelColor: cancelColor,
            submitColor: submitColor,
          ),
        );
      },
    );
  } else {
    if (Platform.isIOS || Platform.isMacOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            content: body,
            actions: _cupertinoActions(
              context: context,
              cancelBolded: cancelBolded,
              cancelText: cancelText,
              onCancel: onCancel,
              submitBolded: submitBolded,
              submitText: submitText,
              onSubmit: onSubmit,
              cancelColor: cancelColor,
              submitColor: submitColor,
            ),
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(10),
            actionsPadding: const EdgeInsets.all(10),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.cell(context),
            surfaceTintColor: AppColors.cell(context),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [body],
            ),
            actions: _materialActions(
              context: context,
              cancelBolded: cancelBolded,
              cancelText: cancelText,
              onCancel: onCancel,
              submitBolded: submitBolded,
              submitText: submitText,
              onSubmit: onSubmit,
              cancelColor: cancelColor,
              submitColor: submitColor,
            ),
          );
        },
      );
    }
  }
}

List<Widget> _cupertinoActions({
  required BuildContext context,
  required bool cancelBolded,
  required String cancelText,
  required VoidCallback onCancel,
  required bool submitBolded,
  required String submitText,
  required VoidCallback onSubmit,
  Color? cancelColor,
  Color? submitColor,
}) {
  return [
    CupertinoDialogAction(
      isDefaultAction: cancelBolded,
      onPressed: () {
        Navigator.of(context).pop();
        onCancel();
      },
      child: Text(cancelText,
          style: TextStyle(color: cancelColor ?? Colors.blue[800])),
    ),
    // submit button
    CupertinoDialogAction(
      isDefaultAction: submitBolded,
      onPressed: () {
        Navigator.of(context).pop();
        onSubmit();
      },
      child: Text(submitText,
          style: TextStyle(color: submitColor ?? Colors.blue[800])),
    ),
  ];
}

List<Widget> _materialActions({
  required BuildContext context,
  required bool cancelBolded,
  required String cancelText,
  required VoidCallback onCancel,
  required bool submitBolded,
  required String submitText,
  required VoidCallback onSubmit,
  Color? cancelColor,
  Color? submitColor,
}) {
  return [
    TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        onCancel();
      },
      child: Text(cancelText,
          style: TextStyle(
              color: cancelColor ?? Theme.of(context).colorScheme.primary,
              fontWeight: cancelBolded ? FontWeight.w600 : null)),
    ),
    // submit button
    TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        onSubmit();
      },
      child: Text(submitText,
          style: TextStyle(
              fontWeight: submitBolded ? FontWeight.w600 : null,
              color: submitColor ?? Theme.of(context).colorScheme.primary)),
    ),
  ];
}

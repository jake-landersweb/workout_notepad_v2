import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void navigate({
  required BuildContext context,
  required Widget Function(BuildContext context) builder,
}) {
  Navigator.of(context).push(
    MaterialWithModalsPageRoute(
      builder: builder,
    ),
  );
}

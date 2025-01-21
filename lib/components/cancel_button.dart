import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({
    super.key,
    this.title,
    this.useRoot = false,
  });
  final String? title;
  final bool useRoot;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () => Navigator.of(context, rootNavigator: useRoot).pop(),
      child: Text(
        title ?? "Cancel",
        style: ttLabel(context, size: 16),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:workout_notepad_v2/text_themes.dart';

class LabeledWidget extends StatelessWidget {
  const LabeledWidget({
    super.key,
    required this.label,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 0),
    this.labelSpacing = 4,
  });
  final String label;
  final Widget child;
  final EdgeInsets padding;
  final double labelSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding,
          child: Text(
            label.toUpperCase(),
            style: ttLargeLabel(context),
          ),
        ),
        SizedBox(height: labelSpacing),
        child,
      ],
    );
  }
}

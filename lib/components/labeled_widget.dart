import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class LabeledWidget extends StatelessWidget {
  const LabeledWidget({
    super.key,
    required this.label,
    required this.child,
    this.labelInsets = const EdgeInsets.fromLTRB(16, 0, 16, 0),
  });
  final String label;
  final Widget child;
  final EdgeInsets labelInsets;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: labelInsets,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: sui.CustomColors.textColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

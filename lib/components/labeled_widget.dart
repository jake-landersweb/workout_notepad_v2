import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

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
            style: TextStyle(
              color: sui.CustomColors.textColor(context).withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: labelSpacing),
        child,
      ],
    );
  }
}

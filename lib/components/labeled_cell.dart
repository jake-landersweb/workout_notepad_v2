import 'package:flutter/material.dart';

class LabeledCell extends StatelessWidget {
  const LabeledCell({
    Key? key,
    required this.label,
    required this.child,
    this.height = 50,
    this.textColor,
  }) : super(key: key);
  final String label;
  final Widget child;
  final double height;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: Center(
        child: Row(
          children: [
            Expanded(child: child),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

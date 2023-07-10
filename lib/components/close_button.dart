import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/root.dart';

class CloseButton2 extends StatelessWidget {
  const CloseButton2({
    super.key,
    this.useRoot = false,
    this.color,
  });
  final bool useRoot;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        Navigator.of(context, rootNavigator: useRoot).pop();
      },
      child: Icon(
        LineIcons.times,
        color: color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}

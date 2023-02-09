import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class CloseButton extends StatelessWidget {
  const CloseButton({
    super.key,
    this.useRoot = false,
    this.color,
  });
  final bool useRoot;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return sui.Button(
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

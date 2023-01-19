import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class BackButton extends StatelessWidget {
  const BackButton({
    super.key,
    this.useRoot = false,
  });
  final bool useRoot;

  @override
  Widget build(BuildContext context) {
    return sui.Button(
      onTap: () {
        Navigator.of(context, rootNavigator: useRoot).pop();
      },
      child: Icon(
        LineIcons.angleDoubleLeft,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

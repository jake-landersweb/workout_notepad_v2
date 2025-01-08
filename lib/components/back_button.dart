import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class BackButton2 extends StatelessWidget {
  const BackButton2({
    super.key,
    this.useRoot = false,
    this.text,
  });
  final bool useRoot;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      key: ValueKey("BackButton2"),
      onTap: () {
        Navigator.of(context, rootNavigator: useRoot).pop();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LineIcons.angleDoubleLeft,
            color: Theme.of(context).primaryColor,
          ),
          if (text != null)
            Text(
              text!,
              style: ttLabel(
                context,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}

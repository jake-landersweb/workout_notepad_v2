import 'package:flutter/material.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return sui.Button(
        onTap: () => Navigator.of(context).pop(),
        child: Text(
          "Cancel",
          style: ttLabel(context, color: Theme.of(context).primaryColor),
        ));
  }
}

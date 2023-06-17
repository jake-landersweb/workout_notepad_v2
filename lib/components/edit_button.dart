import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Clickable(
        onTap: onTap,
        child: Text(
          "Edit",
          style: ttLabel(context, color: Theme.of(context).primaryColor),
        ));
  }
}

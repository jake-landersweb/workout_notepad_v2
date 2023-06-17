import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/root.dart';

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () => onTap(),
      child: Icon(
        LineIcons.plus,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

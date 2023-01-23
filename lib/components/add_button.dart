import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class AddButton extends StatelessWidget {
  const AddButton({
    super.key,
    required this.onTap,
  });
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return sui.Button(
      onTap: () => onTap(),
      child: Icon(
        LineIcons.plus,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

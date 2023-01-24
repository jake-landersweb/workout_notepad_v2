import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.initText,
    this.padding = const EdgeInsets.only(bottom: 8.0),
  });
  final Function(String val) onChanged;
  final String labelText;
  final String? hintText;
  final String? initText;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: sui.CellWrapper(
        child: Row(
          children: [
            Icon(LineIcons.search, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: sui.TextField(
                labelText: labelText,
                hintText: hintText ?? labelText,
                value: initText,
                onChanged: onChanged,
              ),
            )
          ],
        ),
      ),
    );
  }
}

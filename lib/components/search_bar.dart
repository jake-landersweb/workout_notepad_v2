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
  });
  final Function(String val) onChanged;
  final String labelText;
  final String? hintText;
  final String? initText;

  @override
  Widget build(BuildContext context) {
    return sui.CellWrapper(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        children: [
          Icon(
            LineIcons.search,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: sui.TextField(
              labelText: labelText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              hintText: hintText ?? labelText,
              value: initText,
              onChanged: onChanged,
            ),
          )
        ],
      ),
    );
  }
}

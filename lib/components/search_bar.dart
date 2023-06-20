import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:workout_notepad_v2/components/root.dart';

import 'package:workout_notepad_v2/utils/root.dart';

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
    return CellWrapper(
      backgroundColor:
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      child: Row(
        children: [
          Icon(
            LineIcons.search,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Field(
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

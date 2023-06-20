import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class SelectExercise extends StatefulWidget {
  const SelectExercise({
    super.key,
    required this.onSelect,
    this.closeOnSelect = true,
    this.title,
  });
  final Function(Exercise e) onSelect;
  final bool closeOnSelect;
  final String? title;

  @override
  State<SelectExercise> createState() => _SelectExerciseState();
}

class _SelectExerciseState extends State<SelectExercise>
    with TickerProviderStateMixin {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: widget.title ?? "Select or Create",
      leading: const [comp.CloseButton()],
      itemSpacing: 8,
      children: [
        const SizedBox(height: 16),
        Clickable(
          onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => CEERoot(
                isCreate: true,
                onAction: (e) {
                  _select(e);
                },
              ),
            );
          },
          child: CellWrapper(
            child: Row(
              children: [
                Icon(
                  LineIcons.plusCircle,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 16),
                Text(
                  "Create New",
                  style: ttLabel(
                    context,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // search bar
        comp.SearchBar(
          onChanged: (val) {
            setState(() {
              _searchText = val.toLowerCase();
            });
          },
          initText: _searchText,
          labelText: "Search",
          hintText: "Search by title or category",
        ),
        const SizedBox(height: 16),
        // exercise list
        for (var i in filteredExercises(dmodel.exercises, _searchText))
          ExerciseCell(
            exercise: i,
            onTap: () => _select(i),
          ),
      ],
    );
  }

  void _select(Exercise e) {
    widget.onSelect(e);
    if (widget.closeOnSelect) {
      Navigator.of(context).pop();
    }
  }
}

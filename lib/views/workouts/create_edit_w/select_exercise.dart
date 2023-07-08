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
    this.onDeselect,
    this.selectedIds,
  });
  final Function(Exercise e) onSelect;
  final Function(Exercise e)? onDeselect;
  final List<String>? selectedIds;
  final bool closeOnSelect;
  final String? title;

  @override
  State<SelectExercise> createState() => _SelectExerciseState();
}

class _SelectExerciseState extends State<SelectExercise>
    with TickerProviderStateMixin {
  String _searchText = "";
  late List<String> _selected;
  late bool _closeOnSelect;

  @override
  void initState() {
    if (widget.onDeselect != null || widget.selectedIds != null) {
      assert(widget.onDeselect != null && widget.selectedIds != null,
          "BOTH ARE REQURED TO WORK TOGETHER");
    }
    _selected = widget.selectedIds ?? [];
    if (widget.onDeselect != null) {
      _closeOnSelect = false;
    } else {
      _closeOnSelect = widget.closeOnSelect;
    }
    super.initState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: widget.title ?? "Select or Create",
      trailing: const [comp.CancelButton(title: "Done")],
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
                  color: AppColors.subtext(context),
                ),
                const SizedBox(width: 16),
                Text(
                  "Create New",
                  style: ttLabel(context),
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
            trailingWidget: widget.onDeselect == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      _selected.any((element) => element == i.exerciseId)
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: AppColors.cell(context)[700],
                    ),
                  ),
            onTap: () {
              if (widget.onDeselect != null) {
                if (_selected.any((element) => element == i.exerciseId)) {
                  widget.onDeselect!(i);
                  setState(() {
                    _selected.removeWhere((element) => element == i.exerciseId);
                  });
                } else {
                  _select(i);
                  setState(() {
                    _selected.add(i.exerciseId);
                  });
                }
              } else {
                _select(i);
              }
            },
          ),
      ],
    );
  }

  void _select(Exercise e) {
    widget.onSelect(e);
    if (_closeOnSelect) {
      Navigator.of(context).pop();
    }
  }
}

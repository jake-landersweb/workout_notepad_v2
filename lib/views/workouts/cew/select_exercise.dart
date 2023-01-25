import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class SelectExercise extends StatefulWidget {
  const SelectExercise({
    super.key,
    required this.onSelect,
    this.closeOnSelect = true,
    this.useCupertino = true,
    this.useRoot = false,
  });
  final Function(Exercise e) onSelect;
  final bool closeOnSelect;
  final bool useCupertino;
  final bool useRoot;

  @override
  State<SelectExercise> createState() => _SelectExerciseState();
}

class _SelectExerciseState extends State<SelectExercise>
    with TickerProviderStateMixin {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return sui.FloatingSheet(
      title: "Select or Create",
      useRoot: widget.useRoot,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: sui.FluidScrollView(
          spacing: 8,
          children: [
            // add new
            sui.Button(
              onTap: () {
                if (widget.useCupertino) {
                  sui.showCupertinoSheet(
                    context: context,
                    builder: (context) => CEERoot(
                      isCreate: true,
                      useRoot: widget.useRoot,
                      onAction: (e) {
                        widget.onSelect(e);
                        if (widget.closeOnSelect) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                } else {
                  sui.showBottomSheet(
                    context: context,
                    vsync: this,
                    builder: (context) => CEERoot(
                      isCreate: true,
                      useRoot: false,
                      onAction: (e) {
                        widget.onSelect(e);
                        if (widget.closeOnSelect) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                }
              },
              child: sui.CellWrapper(
                child: Row(
                  children: [
                    Icon(
                      LineIcons.plusCircle,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Text("Create New", style: ttLabel(context)),
                  ],
                ),
              ),
            ),
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
            // exercise list
            for (var i in filteredExercises(dmodel.exercises, _searchText))
              ExerciseCell(
                exercise: i,
                onTap: () {
                  widget.onSelect(i);
                  if (widget.closeOnSelect) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

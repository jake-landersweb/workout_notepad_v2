import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/floating_sheet.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;

class CEWExerciseCell extends StatefulWidget {
  const CEWExerciseCell({
    super.key,
    required this.cewe,
    required this.handle,
    required this.index,
    required this.inDrag,
  });
  final CEWExercise cewe;
  final Handle handle;
  final int index;
  final bool inDrag;

  @override
  State<CEWExerciseCell> createState() => _CEWExerciseCellState();
}

class _CEWExerciseCellState extends State<CEWExerciseCell> {
  @override
  Widget build(BuildContext context) {
    var cmodel = Provider.of<CEWModel>(context);
    return AnimatedContainer(
      curve: Sprung(36),
      duration: const Duration(milliseconds: 700),
      color: widget.inDrag
          ? Theme.of(context).colorScheme.surfaceVariant
          : Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.cewe.exercise.title,
                          style: ttSubTitle(context,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      widget.handle,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: EditableExerciseItemGroup(exercise: widget.cewe.exercise),
          ),
          ImplicitlyAnimatedList(
            items: widget.cewe.children,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, animation, item, i) {
              return SizeFadeTransition(
                sizeFraction: 0.7,
                curve: Curves.easeInOut,
                animation: animation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Clickable(
                    onTap: () {
                      showFloatingSheet(
                        context: context,
                        builder: (context) => FloatingSheet(
                          title: item.title,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              EditableExerciseItemGroup(
                                exercise: item,
                                onChanged: () => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Container()),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Clickable(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              cmodel.removeExerciseChild(
                                                widget.index,
                                                item,
                                              );
                                            },
                                            child: Text(
                                              "Remove",
                                              style: ttBody(
                                                context,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Clickable(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              cmodel.removeExerciseChild(
                                                widget.index,
                                                item,
                                              );
                                            },
                                            child: comp.ActionButton(
                                              title: "Close",
                                              minHeight: 40,
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Text(
                                        item.title,
                                        style: ttLabel(
                                          context,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      )),
                                    ],
                                  ),
                                  item.info(
                                    context,
                                    style: ttLabel(
                                      context,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LineIcons.verticalEllipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            areItemsTheSame: ((oldItem, newItem) =>
                oldItem.exerciseSetId == newItem.exerciseSetId),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Clickable(
                          onTap: () {
                            showFloatingSheet(
                              context: context,
                              builder: (context) => _ExerciseNote(
                                note: widget.cewe.exercise.note,
                                onSave: (val) {
                                  setState(() {
                                    widget.cewe.exercise.note = val;
                                  });
                                },
                              ),
                            );
                          },
                          child: Icon(
                            Icons.sticky_note_2_rounded,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        if (widget.cewe.exercise.note != "")
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(widget.cewe.exercise.note,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(LineIcons.plus),
                    label: const Text("Super-Set"),
                    onPressed: () {
                      comp.cupertinoSheet(
                        context: context,
                        builder: (context) {
                          return SelectExercise(
                            onSelect: (e) {
                              cmodel.addExerciseChild(
                                widget.index,
                                ExerciseSet.fromExercise(
                                  cmodel.workout.workoutId,
                                  widget.cewe.exercise,
                                  e,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.index < cmodel.exercises.length - 1)
            const Divider(height: 0.5),
        ],
      ),
    );
  }
}

class _ExerciseNote extends StatefulWidget {
  const _ExerciseNote({
    super.key,
    required this.note,
    required this.onSave,
  });
  final String note;
  final Function(String val) onSave;

  @override
  State<_ExerciseNote> createState() => __ExerciseNoteState();
}

class __ExerciseNoteState extends State<_ExerciseNote> {
  late String _note;

  @override
  void initState() {
    _note = widget.note;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CellWrapper(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              child: Field(
                value: _note,
                maxLines: 4,
                labelText: "Note",
                onChanged: (val) {
                  setState(() {
                    _note = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Clickable(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: ttBody(
                              context,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: comp.ActionButton(
                          title: "Save",
                          minHeight: 40,
                          onTap: () {
                            widget.onSave(_note);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuperSetOrder extends StatefulWidget {
  const _SuperSetOrder({
    super.key,
    required this.exercise,
    required this.onSelect,
  });
  final WorkoutExercise exercise;
  final Function(int val) onSelect;

  @override
  State<_SuperSetOrder> createState() => __SuperSetOrderState();
}

class __SuperSetOrderState extends State<_SuperSetOrder> {
  late int _val;

  @override
  void initState() {
    _val = widget.exercise.superSetOrdering;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingSheet(
      title: "Super-Set Ordering",
      child: ContainedList<int>(
        children: const [0, 1, 2],
        allowsSelect: true,
        selected: [_val],
        color: Theme.of(context).primaryColor,
        leadingPadding: 0,
        trailingPadding: 0,
        onSelect: (item) {
          setState(() {
            _val = item;
          });
          widget.onSelect(item);
          Navigator.of(context).pop();
        },
        childBuilder: (context, item) {
          return Text(_getTitle(item), style: ttLabel(context));
        },
      ),
    );
  }

  String _getTitle(int v) {
    switch (v) {
      case 0:
        return "Default";
      case 1:
        return "Every Other (Top)";
      case 2:
        return "Every Other (Bottom)";
      default:
        return "";
    }
  }
}

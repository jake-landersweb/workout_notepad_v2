import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWExerciseEdit extends StatefulWidget {
  const CEWExerciseEdit({
    super.key,
    required this.workoutId,
    required this.exercise,
    required this.onSave,
  });
  final String workoutId;
  final CEWExercise exercise;
  final Function(CEWExercise e) onSave;

  @override
  State<CEWExerciseEdit> createState() => _CEWExerciseEditState();
}

class _CEWExerciseEditState extends State<CEWExerciseEdit> {
  late WorkoutExercise _exercise;
  late List<ExerciseSet> _children;

  @override
  void initState() {
    _exercise = widget.exercise.exercise.copy();
    _children = [];
    for (var i in widget.exercise.children) {
      _children.add(i.copy());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return sui.AppBar.sheet(
      title: "Configure Exercise",
      leading: const [comp.CloseButton(useRoot: true)],
      trailing: [
        sui.Button(
          onTap: () {
            var c = CEWExercise.init(_exercise);
            c.children = _children;
            widget.onSave(c);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: Text("Save", style: ttLabel(context, color: dmodel.color)),
        ),
      ],
      horizontalSpacing: 0,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              comp.LabeledWidget(
                label: "Basic Information",
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          comp.NumberPicker(
                            showPicker: false,
                            textFontSize: 40,
                            intialValue: _exercise.sets,
                            onChanged: (val) {
                              setState(() {
                                _exercise.sets = val;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "SETS",
                              style: TextStyle(
                                fontSize: 12,
                                color: dmodel.color.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("x",
                          style: ttLabel(context, color: dmodel.color)),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          comp.NumberPicker(
                            showPicker: false,
                            textFontSize: 40,
                            intialValue: _exercise.reps,
                            onChanged: (val) {
                              setState(() {
                                _exercise.reps = val;
                              });
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              "REPS",
                              style: TextStyle(
                                fontSize: 12,
                                color: dmodel.color.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              sui.CellWrapper(
                child: sui.TextField(
                  labelText: "Note",
                  value: _exercise.note,
                  onChanged: (val) {
                    setState(() {
                      _exercise.note = val;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: comp.ActionButton(
                  title: "Add Super-Set",
                  onTap: () {
                    comp.cupertinoSheet(
                      context: context,
                      builder: (context) {
                        return SelectExercise(
                          onSelect: (e) {
                            setState(() {
                              _children.add(
                                ExerciseSet.fromExercise(
                                  widget.workoutId,
                                  widget.exercise.exercise,
                                  e,
                                ),
                              );
                            });
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
        comp.LabeledWidget(
          label: "Super-Sets",
          padding: const EdgeInsets.fromLTRB(32, 0, 16, 0),
          child: comp.ReorderableList<ExerciseSet>(
            items: _children,
            areItemsTheSame: (p0, p1) => p0.exerciseSetId == p1.exerciseSetId,
            onReorderFinished: (item, from, to, newItems) {
              setState(() {
                _children
                  ..clear()
                  ..addAll(newItems);
              });
            },
            slideBuilder: (item, index) {
              return ActionPane(
                extentRatio: 0.3,
                motion: const DrawerMotion(),
                children: [
                  Expanded(
                    child: Row(children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          setState(() {
                            _children.removeAt(index);
                          });
                        },
                        icon: LineIcons.alternateTrash,
                        label: "Delete",
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ]),
                  ),
                ],
              );
            },
            builder: (item, index) {
              return _exerciseSuperSet(context, dmodel, item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _exerciseSuperSet(
      BuildContext context, DataModel dmodel, ExerciseSet exercise, int index) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.title,
            style: ttLargeLabel(
              context,
              color: dmodel.color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    comp.NumberPicker(
                      showPicker: false,
                      textFontSize: 40,
                      intialValue: exercise.sets,
                      onChanged: (val) {
                        setState(() {
                          exercise.sets = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "SETS",
                        style: TextStyle(
                          fontSize: 12,
                          color: dmodel.color.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("x", style: ttLabel(context, color: dmodel.color)),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    comp.NumberPicker(
                      showPicker: false,
                      textFontSize: 40,
                      intialValue: exercise.reps,
                      onChanged: (val) {
                        setState(() {
                          exercise.reps = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "REPS",
                        style: TextStyle(
                          fontSize: 12,
                          color: dmodel.color.withOpacity(0.7),
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
    );
  }
}

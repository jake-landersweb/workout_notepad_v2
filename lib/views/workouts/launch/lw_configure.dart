import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:line_icons/line_icons.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/cancel_button.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/raw_reorderable_list.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';

class LWConfigure extends StatefulWidget {
  const LWConfigure({
    super.key,
    required this.exercises,
    required this.exerciseLogs,
    required this.workout,
    required this.workoutLog,
    required this.onSave,
  });
  final List<List<WorkoutExercise>> exercises;
  final List<List<ExerciseLog>> exerciseLogs;
  final Workout workout;
  final WorkoutLog workoutLog;
  final Future<bool> Function(
    List<List<WorkoutExercise>> exercises,
    List<List<ExerciseLog>> logs,
  ) onSave;

  @override
  State<LWConfigure> createState() => _LWConfigureState();
}

class _LWConfigureState extends State<LWConfigure> {
  late List<Tuple3<String, List<WorkoutExercise>, List<ExerciseLog>>> _items;

  @override
  void initState() {
    _items = [];
    var uuid = const Uuid();
    for (int i = 0; i < widget.exercises.length; i++) {
      _items
          .add(Tuple3(uuid.v4(), widget.exercises[i], widget.exerciseLogs[i]));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Re-Order",
      canScroll: true,
      trailing: [
        Clickable(
          onTap: () async {
            var response = await _save();
            if (response) {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            "Save",
            style: ttLabel(context),
          ),
        ),
      ],
      leading: const [CancelButton()],
      horizontalSpacing: 0,
      children: [
        RawReorderableList<
            Tuple3<String, List<WorkoutExercise>, List<ExerciseLog>>>(
          items: _items,
          areItemsTheSame: (p0, p1) => p0.v1 == p1.v1,
          header: const SizedBox(height: 16),
          footer: const SizedBox(height: 0),
          onReorderFinished: (item, from, to, newItems) {
            setState(() {
              _items = newItems;
            });
          },
          slideBuilder: (item, index) {
            return ActionPane(
              extentRatio: 0.3,
              motion: const DrawerMotion(),
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        SlidableAction(
                          borderRadius: BorderRadius.circular(10),
                          onPressed: (context) async {
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );
                            setState(() {
                              _items.removeAt(index);
                            });
                          },
                          icon: LineIcons.alternateTrash,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.error(),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          builder: (item, index, handle, inDrag) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  color: inDrag
                      ? AppColors.cell(context)[50]
                      : AppColors.cell(context),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i in item.v2)
                                Row(
                                  children: [
                                    Expanded(child: Text("- ${i.title}")),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        handle,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 50),
          child: WrappedButton(
            title: "Add Exercise",
            type: WrappedButtonType.main,
            onTap: () {
              cupertinoSheet(
                context: context,
                builder: (context) => SelectExercise(
                  onSelect: (e) {
                    var we = WorkoutExercise.fromExercise(widget.workout, e);
                    we.exerciseOrder = _items.length;
                    var wl = ExerciseLog.workoutInit(
                      workoutLog: widget.workoutLog,
                      exercise: we,
                    );
                    setState(() {
                      _items.add(Tuple3(const Uuid().v4(), [we], [wl]));
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<bool> _save() async {
    try {
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        // remove all exercises
        int r = await txn.rawDelete(
          "DELETE FROM workout_exercise WHERE workoutId = ?",
          [widget.workout.workoutId],
        );
        if (r == 0) {
          throw "There was an issue deleting the exercises when reordering";
        }

        // re-add exercises
        for (int i = 0; i < _items.length; i++) {
          for (int j = 0; j < _items[i].v2.length; j++) {
            // modify the items
            _items[i].v2[j].exerciseOrder = i;
            _items[i].v3[j].exerciseOrder = i;
            r = await txn.insert("workout_exercise", _items[i].v2[j].toMap());
            if (r == 0) {
              throw "There was an issue re-adding the exercises when re-ordering";
            }
          }
        }
      });
      await widget.onSave(
        _items.map((e) => e.v2).toList(),
        _items.map((e) => e.v3).toList(),
      );
      return true;
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(e, StackTrace.current);
      return false;
    }
  }
}

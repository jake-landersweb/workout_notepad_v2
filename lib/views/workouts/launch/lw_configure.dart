import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/select_exercise.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/cew_configure.dart';
import 'package:workout_notepad_v2/logger.dart';

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
    String newTitle,
  ) onSave;

  @override
  State<LWConfigure> createState() => _LWConfigureState();
}

class _LWConfigureState extends State<LWConfigure> {
  late List<List<WorkoutExercise>> _exercises = [];
  late List<Tuple3<String, List<WorkoutExercise>, List<ExerciseLog>>> _items;
  late TextEditingController _controller;

  @override
  void initState() {
    _items = [];
    var uuid = const Uuid();
    _exercises = widget.exercises
        .map((group) => group.map((e) => e.copy()).toList())
        .toList();
    for (int i = 0; i < widget.exercises.length; i++) {
      _items
          .add(Tuple3(uuid.v4(), widget.exercises[i], widget.exerciseLogs[i]));
    }

    _controller = TextEditingController(text: widget.workoutLog.title);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of(context);
    return HeaderBar.sheet(
      title: "Configure",
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
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Field(
                labelText: "Title",
                controller: _controller,
                hasClearButton: true,
                charLimit: 30,
                textCapitalization: TextCapitalization.words,
                showCharacters: true,
                onChanged: (val) {},
              ),
            ),
          ),
        ),
        CEWConfigure(
          exercises: _exercises,
          onReorderFinish: (exercises) {
            setState(() {
              // ignore: unnecessary_cast
              _exercises = exercises as List<List<WorkoutExercise>>;
            });
          },
          removeAt: (index) {
            setState(() {
              _exercises.removeAt(index);
            });
          },
          onGroupReorder: (int i, List<Exercise> group) {
            setState(() {
              _exercises[i] = group as List<WorkoutExercise>;
            });
          },
          removeSuperset: (int i, int j) {
            setState(() {
              _exercises[i].removeAt(j);
            });
          },
          addExercise: (int index, Exercise e) {
            setState(() {
              _exercises[index].add(
                WorkoutExercise.fromExercise(widget.workout, e),
              );
            });
          },
          sState: () {
            setState(() {});
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
                      defaultTag: dmodel.tags.firstWhereOrNull(
                        (element) => element.isDefault,
                      ),
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
        // int r = await txn.rawDelete(
        //   "DELETE FROM workout_exercise WHERE workoutId = ?",
        //   [widget.workout.workoutId],
        // );
        // if (r == 0) {
        //   throw "There was an issue deleting the exercises when reordering";
        // }

        // re-add exercises
        for (int i = 0; i < _items.length; i++) {
          for (int j = 0; j < _items[i].v2.length; j++) {
            // modify the items
            _items[i].v2[j].exerciseOrder = i;
            _items[i].v2[j].supersetOrder = j;
            _items[i].v3[j].exerciseOrder = i;
            _items[i].v3[j].supersetOrder = j;
            // r = await txn.insert("workout_exercise", _items[i].v2[j].toMap());
            // if (r == 0) {
            //   throw "There was an issue re-adding the exercises when re-ordering";
            // }
          }
        }
      });
      await widget.onSave(
        _items.map((e) => e.v2).toList(),
        _items.map((e) => e.v3).toList(),
        _controller.text,
      );
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      return false;
    }
  }
}

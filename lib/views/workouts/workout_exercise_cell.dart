import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class WorkoutExerciseCell extends StatefulWidget {
  const WorkoutExerciseCell({
    super.key,
    required this.workoutId,
    required this.exercise,
    this.children,
  });

  final String workoutId;
  final WorkoutExercise exercise;
  final List<ExerciseSet>? children;

  @override
  State<WorkoutExerciseCell> createState() => _WorkoutExerciseCellState();
}

class _WorkoutExerciseCellState extends State<WorkoutExerciseCell> {
  List<ExerciseSet> _children = [];

  @override
  void initState() {
    super.initState();
    if (widget.children == null) {
      _getChildren();
    } else {
      _children = widget.children!;
    }
  }

  Future<void> _getChildren() async {
    _children = await widget.exercise.getChildren(widget.workoutId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          ExerciseCell(
            exercise: widget.exercise,
            padding: EdgeInsets.zero,
          ),
          for (int i = 0; i < _children.length; i++)
            Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      "—",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cell(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(_children[i].title)),
                            _children[i].info(
                              context,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

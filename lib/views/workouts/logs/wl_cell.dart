import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

class WorkoutLogCell extends StatefulWidget {
  const WorkoutLogCell({
    super.key,
    required this.workoutLog,
    this.onSelect,
  });
  final WorkoutLog workoutLog;
  final VoidCallback? onSelect;

  @override
  State<WorkoutLogCell> createState() => _WorkoutLogCellState();
}

class _WorkoutLogCellState extends State<WorkoutLogCell> {
  late WorkoutLog _wl;
  @override
  void initState() {
    super.initState();
    _wl = widget.workoutLog;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _wl.getCreatedFormatted(),
              style: ttBody(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _wl.getDuration(),
              style: ttcaption(context, fontWeight: FontWeight.w500),
            ),
            Text(
              "${_wl.exerciseLogs.map((e) => e.length).sum} Total Exercises",
              style: ttcaption(context, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WrappedButton(
                    title: "View Summary",
                    type: WrappedButtonType.main,
                    rowAxisSize: MainAxisSize.max,
                    center: true,
                    onTap: () {
                      comp.cupertinoSheet(
                        context: context,
                        builder: (context) => PostWorkoutSummary(
                          workoutLogId: widget.workoutLog.workoutLogId,
                          onSave: (wl) async {
                            _wl = wl;
                            _wl.exerciseLogs = await _wl.getExercises() ?? [];
                            setState(() {});
                          },
                        ),
                      );
                    },
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

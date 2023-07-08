import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

class WorkoutLogCell extends StatefulWidget {
  const WorkoutLogCell({
    super.key,
    required this.workoutLog,
  });
  final WorkoutLog workoutLog;

  @override
  State<WorkoutLogCell> createState() => _WorkoutLogCellState();
}

class _WorkoutLogCellState extends State<WorkoutLogCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.workoutLog.getCreatedFormatted(),
              style: ttBody(
                context,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.workoutLog.getDuration(),
              style: ttBody(context, color: AppColors.subtext(context)),
            ),
            Row(
              children: [
                const Spacer(),
                Clickable(
                  onTap: () {
                    comp.cupertinoSheet(
                      context: context,
                      builder: (context) =>
                          WLExercises(workoutLog: widget.workoutLog),
                    );
                  },
                  child: const Text("View Info"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        color: Theme.of(context).colorScheme.surfaceVariant,
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              widget.workoutLog.getDuration(),
              style:
                  ttBody(context, color: Theme.of(context).colorScheme.outline),
            ),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    comp.cupertinoSheet(
                      context: context,
                      builder: (context) =>
                          WLExercises(workoutLog: widget.workoutLog),
                    );
                  },
                  child: Text("View Info"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

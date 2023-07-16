import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: WrappedButton(
                    title: "View Info",
                    bg: AppColors.cell(context)[600],
                    rowAxisSize: MainAxisSize.max,
                    center: true,
                    onTap: () {
                      comp.cupertinoSheet(
                        context: context,
                        builder: (context) =>
                            WLExercises(workoutLog: widget.workoutLog),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: widget.onSelect == null
                      ? Container()
                      : WrappedButton(
                          title: "Select",
                          type: WrappedButtonType.main,
                          rowAxisSize: MainAxisSize.max,
                          center: true,
                          onTap: () => widget.onSelect!(),
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

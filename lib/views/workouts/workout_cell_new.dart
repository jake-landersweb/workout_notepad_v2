import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WorkoutCellNew extends StatefulWidget {
  const WorkoutCellNew({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutCellNew> createState() => _WorkoutCellNewState();
}

class _WorkoutCellNewState extends State<WorkoutCellNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.workout.title, style: ttLargeLabel(context)),
        ],
      ),
    );
  }
}

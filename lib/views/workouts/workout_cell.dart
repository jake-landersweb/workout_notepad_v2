import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

class WorkoutCell extends StatefulWidget {
  const WorkoutCell({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.cell(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.workout.title,
                                  style: ttTitle(context),
                                ),
                              ),
                            ],
                          ),
                          if (widget.workout.description?.isNotEmpty ?? false)
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      widget.workout.description!,
                                      style: ttBody(
                                        context,
                                        color: AppColors.subtext(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.workout.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _cat(context),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: WrappedButton(
                  title: "Details",
                  bg: AppColors.cell(context)[600],
                  center: true,
                  onTap: () {
                    comp.navigate(
                      context: context,
                      builder: (context) =>
                          WorkoutDetail(workout: widget.workout),
                    );
                  },
                )),
                const SizedBox(width: 8),
                Expanded(
                  child: WrappedButton(
                    bg: dmodel.workoutState?.workout.workoutId ==
                            widget.workout.workoutId
                        ? AppColors.cell(context)[600]
                        : Theme.of(context).colorScheme.primary,
                    fg: dmodel.workoutState?.workout.workoutId ==
                            widget.workout.workoutId
                        ? AppColors.text(context)
                        : Colors.white,
                    center: true,
                    title: dmodel.workoutState?.workout.workoutId ==
                            widget.workout.workoutId
                        ? "Resume"
                        : "Start",
                    onTap: () async => await launchWorkout(
                      context,
                      dmodel,
                      widget.workout,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cat(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (int i = 0; i < widget.workout.categories.length; i++)
          CategoryCell(categoryId: widget.workout.categories[i])
      ],
    );
  }
}

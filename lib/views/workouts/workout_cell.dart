import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
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
    required this.wc,
  });
  final WorkoutCategories wc;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
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
            Clickable(
              onTap: () {
                comp.navigate(
                  context: context,
                  builder: (context) => WorkoutDetail(workout: widget.wc),
                );
              },
              child: Column(
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
                                    widget.wc.workout.title,
                                    style: ttTitle(context),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.wc.workout.description?.isNotEmpty ??
                                false)
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        widget.wc.workout.description!,
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
                  if (widget.wc.categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _cat(context),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: WrappedButton(
                    bg: dmodel.workoutState?.workout.workoutId ==
                            widget.wc.workout.workoutId
                        ? AppColors.cell(context)[600]
                        : Theme.of(context).colorScheme.primary,
                    fg: dmodel.workoutState?.workout.workoutId ==
                            widget.wc.workout.workoutId
                        ? AppColors.text(context)
                        : Colors.white,
                    center: true,
                    title: dmodel.workoutState?.workout.workoutId ==
                            widget.wc.workout.workoutId
                        ? "Resume"
                        : "Start",
                    onTap: () async => await launchWorkout(
                      context,
                      dmodel,
                      widget.wc.workout,
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
        for (int i = 0; i < widget.wc.categories.length; i++)
          CategoryCell(categoryId: widget.wc.categories[i])
      ],
    );
  }
}

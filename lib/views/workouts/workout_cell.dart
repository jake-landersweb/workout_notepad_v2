import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/dynamicgv.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/workout_detail.dart';
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wc.workout.title,
                      style: ttTitle(
                        context,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (widget.wc.workout.description?.isNotEmpty ?? false)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          widget.wc.workout.description!,
                          style: ttBody(
                            context,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
            if (widget.wc.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _cat(context),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            comp.navigate(
                              context: context,
                              builder: (context) =>
                                  WorkoutDetail(workout: widget.wc),
                            );
                          },
                          child: const Text("View"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            showMaterialModalBottomSheet(
                              context: context,
                              enableDrag: false,
                              builder: (context) =>
                                  LaunchWorkout(workout: widget.wc.workout),
                            );
                          },
                          child: const Text("Start"),
                        ),
                      ),
                    ],
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
    return DynamicGridView(
      itemCount: widget.wc.categories.length,
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      builder: (context, index) {
        return CategoryCell(title: widget.wc.categories[index]);
      },
    );
  }
}

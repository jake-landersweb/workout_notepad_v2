import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class WorkoutCellSmall extends StatelessWidget {
  const WorkoutCellSmall({
    super.key,
    required this.workout,
    this.bg,
    this.endWidget,
  });
  final Workout workout;
  final Color? bg;
  final Widget? endWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Sprung(36),
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: bg ?? AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    workout.title,
                    style: ttTitle(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int j = 0; j < workout.categories.length; j++)
                  CategoryCell(categoryId: workout.categories[j])
              ],
            ),
            if (endWidget != null) endWidget!,
          ],
        ),
      ),
    );
  }
}

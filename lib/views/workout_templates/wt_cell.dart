import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/navigate.dart';
import 'package:workout_notepad_v2/data/workout_exercise.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_exercise_cell.dart';
import 'package:workout_notepad_v2/views/workouts/workouts_home.dart';

class WTCell extends StatelessWidget {
  const WTCell({
    super.key,
    required this.wt,
  });

  final WorkoutTemplate wt;

  @override
  Widget build(BuildContext context) {
    var swatch = getSwatch(ColorUtil.hexToColor(wt.backgroundColor));
    return Container(
      decoration: BoxDecoration(
        color: wt.backgroundColor.isEmpty ? AppColors.cell(context) : null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            swatch[100]!,
            swatch[400]!,
            swatch[800]!,
          ],
        ),
        border: Border.all(color: AppColors.divider(context), width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  wt.title,
                  style: ttLargeLabel(context),
                ),
              ),
              const SizedBox(width: 8),
              Opacity(
                opacity: 0.7,
                child: Clickable(
                  onTap: () {
                    navigate(
                      context: context,
                      builder: (context) => const WorkoutsHome(),
                    );
                  },
                  child: const Row(
                    children: [
                      Text("More"),
                      Icon(Icons.arrow_right_alt),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (wt.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                wt.description,
                style: ttcaption(context),
              ),
            ),
          for (var item in exercises) WTExerciseCell(exercise: item),
        ],
      ),
    );
  }

  List<WorkoutTemplateExercise> get exercises {
    if (wt.exercises.flattened.length > 4) {
      return wt.exercises.flattened.toList().slice(0, 4);
    }
    return wt.exercises.flattened.toList();
  }
}

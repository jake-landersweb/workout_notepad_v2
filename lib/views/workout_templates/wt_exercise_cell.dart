import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/icons.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WTExerciseCell extends StatefulWidget {
  const WTExerciseCell({
    super.key,
    required this.exercise,
  });
  final WorkoutTemplateExercise exercise;

  @override
  State<WTExerciseCell> createState() => _WTExerciseCellState();
}

class _WTExerciseCellState extends State<WTExerciseCell> {
  @override
  Widget build(BuildContext context) {
    var categories = context.select(
      (DataModel value) => value.categories,
    );
    return Row(
      children: [
        if (widget.exercise.category.isNotEmpty) getIcon(categories),
        Expanded(
          child: Text(
            widget.exercise.title,
            style: ttLabel(
              context,
              color: AppColors.text(context).withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget getIcon(List<Category> categories) {
    var match = categories.firstWhere(
      (element) => element.categoryId == widget.exercise.category,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: getImageIcon(match.icon, size: 25),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/navigate.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WorkoutCell extends StatefulWidget {
  const WorkoutCell({
    super.key,
    required this.workout,
    this.allowActions = true,
    this.isTemplate = false,
    this.showBookmark = false,
    this.bookmarkFilled = false,
  });
  final Workout workout;
  final bool allowActions;
  final bool isTemplate;
  final bool showBookmark;
  final bool bookmarkFilled;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  @override
  Widget build(BuildContext context) {
    var color = widget.workout.getBackgroundColor(context);
    var swatch = getSwatch(color ?? AppColors.cell(context));
    return Clickable(
      onTap: () {
        navigate(
          context: context,
          builder: (context) => WorkoutDetail(
            workout: widget.workout,
            allowActions: widget.allowActions,
            isTemplate: widget.isTemplate,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color ?? AppColors.cell(context),
          gradient: color == null
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  colors: [
                    swatch[100]!,
                    swatch[400]!,
                    swatch[800]!,
                  ],
                ),
          border: Border.all(color: AppColors.border(context), width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.showBookmark)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      widget.bookmarkFilled
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: AppColors.text(context).withValues(alpha: 0.3),
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.workout.title,
                    style: ttLargeLabel(context),
                  ),
                ),
                const SizedBox(width: 8),
                Opacity(
                  opacity: 0.7,
                  child: const Row(
                    children: [
                      Text("More"),
                      Icon(Icons.arrow_right_alt),
                    ],
                  ),
                ),
              ],
            ),
            if ((widget.workout.description ?? "").isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.workout.description!,
                  style: ttcaption(context),
                ),
              ),
            for (var item in widget.workout.getFlatExercises(limit: 3))
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: _exerciseCell(context, item),
              ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseCell(BuildContext context, Exercise e) {
    var categories = context.select(
      (DataModel value) => value.categories,
    );
    return Row(
      children: [
        if (e.category.isNotEmpty) _getIcon(categories, e),
        Expanded(
          child: Text(
            e.title,
            style: ttLabel(
              context,
              color: AppColors.text(context).withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getIcon(List<Category> categories, Exercise e) {
    var match = categories.firstWhere(
      (element) => element.categoryId == e.category,
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

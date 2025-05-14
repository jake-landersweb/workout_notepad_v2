import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/navigate.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
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
    this.isExpandedExercises = false,
    this.allowsTap = true,
  });
  final Workout workout;
  final bool allowActions;
  final bool isTemplate;
  final bool showBookmark;
  final bool bookmarkFilled;
  final bool isExpandedExercises;
  final bool allowsTap;

  @override
  State<WorkoutCell> createState() => _WorkoutCellState();
}

class _WorkoutCellState extends State<WorkoutCell> {
  @override
  Widget build(BuildContext context) {
    if (widget.allowsTap) {
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
        child: _cell(context),
      );
    }
    return _cell(context);
  }

  Widget _cell(BuildContext context) {
    var color = widget.workout.getBackgroundColor(context);
    var swatch = getSwatch(color ?? AppColors.cell(context));
    return Container(
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
          if (widget.workout is WorkoutTemplate)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  _levelCell((widget.workout as WorkoutTemplate).level),
                  if ((widget.workout as WorkoutTemplate).estTime.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: _timeCell(
                          (widget.workout as WorkoutTemplate).estTime),
                    ),
                  const Spacer(),
                  if (widget.showBookmark)
                    Icon(
                      widget.bookmarkFilled
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: AppColors.text(context).withValues(alpha: 0.3),
                    ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  widget.workout.title,
                  style: ttLargeLabel(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.allowsTap)
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: ttcaption(context),
              ),
            ),
          const SizedBox(height: 4),
          if (widget.isExpandedExercises)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: _exercises(context),
              ),
            )
          else
            Column(children: _exercises(context)),
        ],
      ),
    );
  }

  List<Widget> _exercises(BuildContext context) {
    return widget.workout
        .getFlatExercises(limit: 3)
        .map((item) => Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: _exerciseCell(context, item),
            ))
        .toList();
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
      child: getImageIcon(match.icon, size: 40),
    );
  }

  Widget _levelCell(String level) {
    final s = getSwatch(_levelCellColor(level));
    return Container(
      decoration: BoxDecoration(
        color: s[100],
        border: Border.all(color: s[500]!),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        level.capitalize(),
        style: ttcaption(context, size: 12, color: s[700]),
      ),
    );
  }

  Widget _timeCell(String time) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.05),
        border:
            Border.all(color: AppColors.text(context).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        time,
        style: ttcaption(
          context,
          size: 12,
          color: AppColors.text(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Color _levelCellColor(String level) {
    switch (level.toLowerCase()) {
      case "beginner":
        return Colors.green;
      case "intermediate":
        return Colors.amber;
      case "advanced":
        return Colors.red;
      default:
        return AppColors.background(context);
    }
  }
}

class WorkoutCell2 extends StatefulWidget {
  const WorkoutCell2({
    super.key,
    required this.workout,
    this.allowActions = true,
    this.isTemplate = false,
    this.showBookmark = false,
    this.bookmarkFilled = false,
    this.allowsTap = true,
  });
  final Workout workout;
  final bool allowActions;
  final bool isTemplate;
  final bool showBookmark;
  final bool bookmarkFilled;
  final bool allowsTap;

  @override
  State<WorkoutCell2> createState() => _WorkoutCell2State();
}

class _WorkoutCell2State extends State<WorkoutCell2> {
  bool _isList = false;

  @override
  Widget build(BuildContext context) {
    if (widget.allowsTap) {
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
        child: _cell(context),
      );
    }
    return _cell(context);
  }

  Widget _cell(BuildContext context) {
    var categories = context.select(
      (DataModel value) => value.categories,
    );

    return Container(
      color: AppColors.cell(context),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Container(
                //   width: 10,
                //   height: 10,
                //   decoration: BoxDecoration(
                //     color: widget.workout.getBackgroundColor(context) ??
                //         Theme.of(context).colorScheme.primary,
                //     shape: BoxShape.circle,
                //   ),
                // ),
                // const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.workout.title,
                    style: ttLargeLabel(context),
                  ),
                ),
                if (widget.allowsTap)
                  Opacity(
                    opacity: 0.7,
                    child: Platform.isIOS
                        ? Icon(Icons.chevron_right_rounded)
                        : Icon(Icons.arrow_right_alt),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "(${widget.workout.getFlatExercises().map((v) => v.title).join(", ")})",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ttBody(
                      context,
                      color: AppColors.text(context).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    key: ValueKey("${widget.workout.workoutId}-row"),
                    children: widget.workout
                        .getTopCategories(limit: 3)
                        .map((v) => _getIcon(categories, v))
                        .toList(),
                  ),
                ),
                if (widget.workout is WorkoutTemplate)
                  Row(
                    children: [
                      if ((widget.workout as WorkoutTemplate)
                          .estTime
                          .isNotEmpty)
                        _timeCell((widget.workout as WorkoutTemplate).estTime),
                      if ((widget.workout as WorkoutTemplate).level.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: _levelCell(
                              (widget.workout as WorkoutTemplate).level),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIcon(List<Category> categories, String cat) {
    var match = categories.firstWhere(
      (element) => element.categoryId == cat,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: getImageIcon(match.icon, size: 30),
    );
  }

  Widget _levelCell(String level) {
    final s = getSwatch(_levelCellColor(level));
    return Container(
      decoration: BoxDecoration(
        color: s[100],
        border: Border.all(color: s[500]!),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Text(
        level.capitalize(),
        style: ttcaption(context, size: 12, color: s[700]),
      ),
    );
  }

  Widget _timeCell(String time) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.text(context).withValues(alpha: 0.05),
        border:
            Border.all(color: AppColors.text(context).withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Text(
        time,
        style: ttcaption(
          context,
          size: 12,
          color: AppColors.text(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Color _levelCellColor(String level) {
    switch (level.toLowerCase()) {
      case "beginner":
        return Colors.green;
      case "intermediate":
        return Colors.amber;
      case "advanced":
        return Colors.red;
      default:
        return AppColors.background(context);
    }
  }
}

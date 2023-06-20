import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/cell_wrapper.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/labeled_cell.dart';
import 'package:workout_notepad_v2/data/exercise.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:flutter_animate/flutter_animate.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: widget.exercise.title,
      crossAxisAlignment: CrossAxisAlignment.center,
      isFluid: true,
      itemSpacing: 16,
      horizontalSpacing: 0,
      leading: const [comp.CloseButton()],
      children: [
        if (widget.exercise.icon.isNotEmpty) _icon(context),
        _actions(context, dmodel),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "About",
              style: ttLargeLabel(
                context,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ),
        )
            .animate(delay: (50 * 1).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExerciseItemGoup(exercise: widget.exercise),
        )
            .animate(delay: (50 * 2).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
        ContainedList<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            LabeledCell(
              label: "Category",
              child: Text(
                widget.exercise.category.capitalize(),
                style: ttLabel(
                  context,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            if (widget.exercise.description.isNotEmpty)
              LabeledCell(
                label: "Description",
                child: Text(
                  widget.exercise.description.capitalize(),
                  style: ttLabel(
                    context,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
          ],
        )
            .animate(delay: (50 * 3).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
      ],
    );
  }

  Widget _icon(BuildContext context) {
    return getImageIcon(widget.exercise.icon, size: 100);
  }

  Widget _actions(BuildContext context, DataModel dmodel) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            _actionCell(
              context: context,
              icon: Icons.edit_rounded,
              title: "Edit",
              description: "Change the attributes",
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) => CEERoot(
                    isCreate: false,
                    exercise: widget.exercise,
                    onAction: (_) {
                      // close the detail screen
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              index: 1,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.sticky_note_2_rounded,
              title: "Logs",
              description: "View exercise logs",
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  builder: (context) => ExerciseLogs(exercise: widget.exercise),
                );
              },
              index: 2,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.add_rounded,
              title: "Add",
              description: "Exercise to workout",
              onTap: () {
                // TODO -- implement
              },
              index: 3,
            ),
            const SizedBox(width: 16),
            _actionCell(
              context: context,
              icon: Icons.delete_rounded,
              title: "Delete",
              description: "Delete this exercise",
              onTap: () {
                // TODO -- implement
              },
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required int index,
  }) {
    final bgColor =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
    final textColor = Theme.of(context).colorScheme.onTertiaryContainer;
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: textColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: ttBody(
                  context,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (25 * index).ms)
        .slideX(
            begin: 0.25,
            curve: Sprung(36),
            duration: const Duration(milliseconds: 500))
        .fadeIn();
  }
}

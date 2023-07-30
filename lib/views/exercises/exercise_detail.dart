import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/labeled_cell.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_details.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
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
  ExerciseDetails? details;

  @override
  void initState() {
    _fetchDetails();
    super.initState();
  }

  Future<void> _fetchDetails() async {
    var db = await getDB();
    var response = await db.rawQuery(
      "SELECT * FROM exercise_detail WHERE exerciseId = '${widget.exercise.exerciseId}'",
    );
    if (response.isNotEmpty) {
      details = await ExerciseDetails.fromJson(response[0]);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var category = dmodel.categories.firstWhere(
      (element) => element.categoryId == widget.exercise.category,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    return HeaderBar.sheet(
      title: widget.exercise.title,
      crossAxisAlignment: CrossAxisAlignment.center,
      isFluid: false,
      itemSpacing: 16,
      horizontalSpacing: 0,
      leading: const [comp.CloseButton2()],
      children: [
        const SizedBox(height: 16),
        if (details != null && details?.file.type != AppFileType.none)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 3,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: details!.file.getRenderer(),
              ),
            ),
          ),
        _actions(context, dmodel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: comp.Section("About",
              child: ExerciseItemGoup(exercise: widget.exercise)),
        )
            .animate(delay: (50 * 2).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
        const SizedBox(height: 16),
        ContainedList<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            if (category.categoryId.isNotEmpty)
              LabeledCell(
                label: "Category",
                child: Row(
                  children: [
                    getImageIcon(category.icon, size: 40),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.title.capitalize(),
                        style: ttLabel(context),
                      ),
                    ),
                  ],
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
        if (details != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: comp.Section(
              "Details",
              child: Column(
                children: [
                  if (details!.description.isNotEmpty)
                    _detailWrapper(
                      context,
                      "Desc",
                      details!.description,
                    ),
                  if (details!.difficultyLevel.isNotEmpty)
                    _detailWrapper(
                      context,
                      "Difficulty",
                      details!.difficultyLevel,
                    ),
                  if (details!.equipmentNeeded.isNotEmpty)
                    _detailWrapper(
                      context,
                      "Equipment",
                      details!.equipmentNeeded,
                    ),
                  // if (details!.restTime.isNotEmpty)
                  //   _detailWrapper(context, "RestTime", details!.description),
                  if (details!.cues.isNotEmpty)
                    _detailWrapper(
                      context,
                      "Cues",
                      details!.cues,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _detailWrapper(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: comp.LabeledCell(
            label: label,
            child: Text(value),
          ),
        ),
      ),
    );
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
              dmodel: dmodel,
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
              dmodel: dmodel,
              icon: Icons.sticky_note_2_rounded,
              title: "Logs",
              description: "View exercise logs",
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: true,
                  builder: (context) =>
                      ExerciseLogs(exerciseId: widget.exercise.exerciseId),
                );
              },
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCell({
    required BuildContext context,
    required DataModel dmodel,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required int index,
  }) {
    final bgColor = AppColors.cell(context);
    final textColor = AppColors.text(context);
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 2.5,
          minHeight: MediaQuery.of(context).size.width / 3,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: dmodel.color,
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

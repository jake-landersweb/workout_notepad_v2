import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CECWorkouts extends StatefulWidget {
  const CECWorkouts({super.key});

  @override
  State<CECWorkouts> createState() => _CECWorkoutsState();
}

class _CECWorkoutsState extends State<CECWorkouts> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    var dmodel = context.read<DataModel>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "First, select the workouts you would like to include in this collection.",
                style: ttLabel(context),
              ),
              const SizedBox(height: 8),
              WrappedButton(
                title: "Create New Workout",
                type: WrappedButtonType.main,
                center: true,
                rowAxisSize: MainAxisSize.max,
                onTap: () {
                  showMaterialModalBottomSheet(
                    context: context,
                    enableDrag: false,
                    useRootNavigator: true,
                    builder: (context) => CEWRoot(
                      isCreate: true,
                      onAction: (w) {
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              WrappedButton(
                title: "Re-Order",
                icon: Icons.toc_rounded,
                center: true,
                rowAxisSize: MainAxisSize.max,
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    enableDrag: false,
                    builder: (context) => const CECOrder(),
                  );
                },
              ),
              Section(
                "${cmodel.collection.items.length} Selected",
                child: Column(
                  children: [
                    for (var wc in dmodel.workouts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _workoutCell(context, cmodel, wc),
                      ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workoutCell(
      BuildContext context, CECModel cmodel, WorkoutCategories wc) {
    var selected =
        cmodel.workoutIds.any((element) => element == wc.workout.workoutId);
    return WorkoutCellSmall(
      wc: wc,
      bg: AppColors.cell(context),
      endWidget: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: WrappedButton(
                title: "Details",
                center: true,
                bg: AppColors.cell(context)[500],
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => WorkoutDetail.small(workout: wc),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: WrappedButton(
                title: selected ? "Selected" : "Select",
                icon: selected ? Icons.check : null,
                fg: selected ? Colors.white : AppColors.text(context),
                bg: selected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.cell(context)[500],
                iconBg: Colors.transparent,
                iconFg: Colors.white,
                iconSpacing: 4,
                center: true,
                rowAxisSize: MainAxisSize.max,
                onTap: () {
                  if (selected) {
                    cmodel.collection.items.removeWhere((element) =>
                        element.workout!.workout.workoutId ==
                        wc.workout.workoutId);
                  } else {
                    if (cmodel.collection.items.length >= 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              "You can only have a maximum of 10 workouts in a collection."),
                          backgroundColor: Colors.red[300],
                        ),
                      );
                      return;
                    }
                    cmodel.collection.items.add(
                      CollectionItem.fromWorkout(
                        collectionId: cmodel.collection.collectionId,
                        wc: wc,
                      ),
                    );
                  }
                  cmodel.refresh();
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

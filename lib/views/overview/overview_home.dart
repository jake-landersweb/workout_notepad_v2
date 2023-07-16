import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/collection/collection_item_cell.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';

class OverviewHome extends StatefulWidget {
  const OverviewHome({super.key});

  @override
  State<OverviewHome> createState() => _OverviewHomeState();
}

class _OverviewHomeState extends State<OverviewHome> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: dmodel.user!.displayName != null ||
              (dmodel.user!.displayName?.isNotEmpty ?? false)
          ? "Hello, ${dmodel.user!.displayName!.split(' ')[0]}"
          : "My Dashboard",
      isLarge: true,
      trailing: [
        AddButton(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              enableDrag: false,
              builder: (context) => CEWRoot(
                isCreate: true,
                onAction: (w) {
                  print(w);
                },
              ),
            );
          },
        )
      ],
      children: [
        const SizedBox(height: 16),
        WrappedButton(
          title: "Start An Empty Workout",
          rowAxisSize: MainAxisSize.max,
          type: WrappedButtonType.main,
          center: true,
          onTap: () async {
            var workout = Workout.init();
            workout.title = DateFormat('MM-dd-yy h:mm:ssa').format(
              DateTime.now(),
            );
            var db = await getDB();
            await db.insert("workout", workout.toMap());
            await launchWorkout(context, dmodel, workout, isEmpty: true);
          },
        ),
        const SizedBox(height: 16),
        // Next workout
        if (dmodel.nextWorkout?.workout != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Section(
              "Next Scheduled Workout",
              child: CollectionItemCell(item: dmodel.nextWorkout!),
            ),
          ),
        // recently completed workouts
        Section(
          "All Workouts",
          child: Column(
            children: [
              for (var i in dmodel.workouts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: WorkoutCell(workout: i),
                ),
            ],
          ),
        ),
        SizedBox(
            height: (dmodel.workoutState == null ? 100 : 130) +
                (dmodel.user!.offline ? 30 : 0)),
      ],
    );
  }
}

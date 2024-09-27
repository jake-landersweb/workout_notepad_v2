import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/action_cell.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/overview/previous_workout.dart';
import 'package:workout_notepad_v2/views/overview/workout_progress.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/workout_cell_new.dart';

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
      // title: dmodel.user!.displayName != null ||
      //         (dmodel.user!.displayName?.isNotEmpty ?? false)
      //     ? "Hello, ${dmodel.user!.displayName!.split(' ')[0]}"
      //     : "My Dashboard",
      isLarge: false,
      // trailing: [
      //   AddButton(
      //     onTap: () {
      //       showMaterialModalBottomSheet(
      //         context: context,
      //         enableDrag: false,
      //         builder: (context) => const CEW(),
      //       );
      //     },
      //   )
      // ],
      children: [
        Row(
          children: [
            dmodel.user!.avatar(context, size: 50),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.75),
                  ),
                ),
                Text("Jake Landers", style: ttLargeLabel(context)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (dmodel.workoutState == null)
          Column(
            children: [
              Clickable(
                onTap: () async {
                  var workout = Workout.init();
                  workout.title = DateFormat('MM-dd-yy h:mm:ssa').format(
                    DateTime.now(),
                  );
                  // var db = await DatabaseProvider().database;
                  // await db.insert("workout", workout.toMap());
                  await launchWorkout(context, dmodel, workout, isEmpty: true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  height: 43,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.play_arrow,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Start A New Workout",
                            style: ttLabel(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Clickable(
                onTap: () async {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => HeaderBar.sheet(
                      title: "Select Template",
                      leading: const [CloseButton2()],
                      children: [
                        if (dmodel.workoutTemplates.isNotEmpty)
                          Section(
                            "Default Templates",
                            allowsCollapse: true,
                            initOpen: dmodel.workouts.isEmpty,
                            child: Column(
                              children: [
                                for (var i in dmodel.workoutTemplates)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Clickable(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await launchWorkout(context, dmodel, i);
                                      },
                                      child: WorkoutCellSmall(workout: i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (dmodel.workouts.isNotEmpty)
                          Section(
                            "My Templates",
                            allowsCollapse: true,
                            initOpen: true,
                            child: Column(
                              children: [
                                for (var i in dmodel.workouts)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Clickable(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await launchWorkout(context, dmodel, i);
                                      },
                                      child: WorkoutCellSmall(workout: i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  height: 43,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.splitscreen,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Start From A Template",
                            style: ttLabel(
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          const WorkoutProgress(),
        const PreviousWorkout(),
        _templates(context, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _templates(BuildContext context, DataModel dmodel) {
    List<Workout> _all = dmodel.workouts + dmodel.workoutTemplates;
    return Section(
      "Templates",
      trailingWidget: Opacity(
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
              Text("All"),
              Icon(Icons.arrow_right_alt),
            ],
          ),
        ),
      ),
      child: Column(
        children: [
          if (_all.length < 3)
            for (var i in _all)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: WorkoutCell(workout: i),
              )
          else
            for (var i in _all.slice(0, 3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: WorkoutCell(workout: i),
              ),
        ],
      ),
    );
  }
}

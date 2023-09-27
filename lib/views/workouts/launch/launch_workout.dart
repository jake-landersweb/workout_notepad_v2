// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/blurred_container.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_cell.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_configure.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_end.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_time.dart';

enum PopupState { minimize, finish, cancel, configure }

Future<void> launchWorkout(
  BuildContext context,
  DataModel dmodel,
  Workout workout, {
  CollectionItem? collectionItem,
  bool isEmpty = false,
}) async {
  if (dmodel.workoutState != null) {
    if (dmodel.workoutState!.workout.workoutId == workout.workoutId) {
      var s = dmodel.workoutState!;
      showMaterialModalBottomSheet(
        context: context,
        enableDrag: true,
        builder: (context) {
          return LaunchWorkout(state: s);
        },
      );
    } else {
      showAlert(
        context: context,
        title: "Overwrite Workout?",
        body: const Text(
          "You currently have a workout in progress, do you want to cancel that workout and start this one?",
        ),
        cancelText: "No, close",
        cancelBolded: true,
        onCancel: () {
          return;
        },
        submitText: "Overwrite",
        onSubmit: () async {
          var s = await dmodel.createWorkoutState(
            workout,
            collectionItem: collectionItem,
            isEmpty: isEmpty,
          );
          showMaterialModalBottomSheet(
            context: context,
            enableDrag: true,
            builder: (context) {
              return LaunchWorkout(state: s);
            },
          );
        },
      );
    }
  } else {
    var s = await dmodel.createWorkoutState(
      workout,
      collectionItem: collectionItem,
      isEmpty: isEmpty,
    );
    showMaterialModalBottomSheet(
      context: context,
      enableDrag: true,
      builder: (context) {
        return LaunchWorkout(state: s);
      },
    );
  }
}

class LaunchWorkout extends StatefulWidget {
  const LaunchWorkout({
    super.key,
    required this.state,
    this.dispose,
  });
  final LaunchWorkoutModelState state;
  final VoidCallback? dispose;

  @override
  State<LaunchWorkout> createState() => _LaunchWorkoutState();
}

class _LaunchWorkoutState extends State<LaunchWorkout> {
  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose!();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LaunchWorkoutModel(state: widget.state),
      builder: ((context, child) {
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialWithModalsPageRoute(
              settings: settings,
              builder: (context) => _body(context),
            );
          },
        );
      }),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return Scaffold(
      body: comp.InteractiveSheet(
        header: (context) => _header(context, dmodel, lmodel),
        headerPadding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
        builder: (context) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                onPageChanged: (value) => lmodel.setIndex(value),
                controller: lmodel.state.pageController,
                children: [
                  for (int i = 0; i < lmodel.state.exerciseLogs.length; i++)
                    LWCell(i: i),
                  const LWEnd(),
                ],
              ),
              SafeArea(
                top: false,
                bottom: true,
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Clickable(
                        onTap: () {
                          if (lmodel.state.workoutIndex > 0) {
                            lmodel.setPage(lmodel.state.workoutIndex - 1);
                          }
                        },
                        child: BlurredContainer(
                          borderRadius: BorderRadius.circular(100),
                          opacity: 0.05,
                          blur: 5,
                          backgroundColor: AppColors.light(context),
                          height: 50,
                          width: 50,
                          child: Center(
                              child: Icon(
                            Icons.chevron_left_rounded,
                            size: 30,
                            color: AppColors.cell(context),
                          )),
                        ),
                      ),
                      const Spacer(),
                      Clickable(
                        onTap: () {
                          if (lmodel.state.workoutIndex <
                              lmodel.state.exercises.length) {
                            lmodel.setPage(lmodel.state.workoutIndex + 1);
                          }
                        },
                        child: BlurredContainer(
                          borderRadius: BorderRadius.circular(100),
                          opacity: 0.15,
                          blur: 5,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          height: 50,
                          width: 50,
                          child: Center(
                              child: Icon(
                            Icons.chevron_right_rounded,
                            size: 30,
                            color: AppColors.cell(context),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(
      BuildContext context, DataModel dmodel, LaunchWorkoutModel lmodel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                lmodel.state.workout.title,
                style: ttTitle(context),
              ),
            ),
            PopupMenuButton<PopupState>(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.more_vert_rounded,
                color: AppColors.subtext(context),
              ),
              // Callback that sets the selected popup menu item.
              onSelected: (PopupState item) async {
                switch (item) {
                  case PopupState.minimize:
                    // hide the workout launch view
                    Navigator.of(context, rootNavigator: true).pop();
                    break;
                  case PopupState.finish:
                    showAlert(
                      context: context,
                      title: "Are You Sure?",
                      body: const Text(
                          "Once you finish a workout, you cannot go back and modify it."),
                      cancelText: "Go Back",
                      onCancel: () {},
                      submitBolded: true,
                      submitText: "Finish",
                      onSubmit: () async {
                        var response = await lmodel.finishWorkout(dmodel);
                        if (response.isEmpty) {
                          Navigator.of(context, rootNavigator: true).pop();
                        } else {
                          snackbarErr(
                            context,
                            response,
                            duration: const Duration(seconds: 6),
                          );
                        }
                      },
                    );
                    break;
                  case PopupState.cancel:
                    showAlert(
                      context: context,
                      title: "Are You Sure?",
                      body: const Text(
                          "If you cancel your workout, all progress will be lost."),
                      cancelText: "Go Back",
                      onCancel: () {},
                      cancelBolded: true,
                      submitColor: Colors.red,
                      submitText: "Yes",
                      onSubmit: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        dmodel.stopWorkout(isCancel: true);
                      },
                    );
                    break;
                  case PopupState.configure:
                    cupertinoSheet(
                      context: context,
                      builder: (context) => LWConfigure(
                        exercises: lmodel.state.exercises,
                        exerciseLogs: lmodel.state.exerciseLogs,
                        workout: lmodel.state.workout,
                        workoutLog: lmodel.state.wl,
                        onSave: (exercises, logs) async {
                          lmodel.state.exercises = exercises;
                          lmodel.state.exerciseLogs = logs;
                          lmodel.refresh();
                          return true;
                        },
                      ),
                    );
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PopupState>>[
                PopupMenuItem<PopupState>(
                  value: PopupState.minimize,
                  child: Row(
                    children: [
                      Icon(
                        Icons.minimize_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text("Minimize"),
                    ],
                  ),
                ),
                PopupMenuItem<PopupState>(
                  value: PopupState.cancel,
                  child: Row(
                    children: [
                      Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text("Cancel"),
                    ],
                  ),
                ),
                PopupMenuItem<PopupState>(
                  value: PopupState.finish,
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text("Finish"),
                    ],
                  ),
                ),
                PopupMenuItem<PopupState>(
                  value: PopupState.configure,
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text("Configure"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if (lmodel.state.workout.description?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              lmodel.state.workout.description!,
              style: ttBody(
                context,
                color: AppColors.subtext(context),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
          child: Row(
            children: [
              LWTime(
                start: lmodel.state.startTime,
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(100),
                ),
                width: 75,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      "${lmodel.state.workoutIndex + 1 > lmodel.state.exercises.length ? '-' : lmodel.state.workoutIndex + 1}/${lmodel.state.exercises.length}",
                      style: ttLabel(
                        context,
                        color: AppColors.text(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

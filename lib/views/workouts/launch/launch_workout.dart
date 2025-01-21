// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/blurred_container.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_cell.dart';
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
        headerPadding: const EdgeInsets.fromLTRB(16, 0, 0, 8),
        headerColor: AppColors.background(context),
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
                        key: ValueKey("launch-workout-back"),
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
                        key: ValueKey("launch-workout-next"),
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
                lmodel.state.wl.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ttTitle(context),
              ),
            ),
            Clickable(
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (context) {
                    return CEW(
                      workout: Workout(
                        workoutId: "",
                        title: lmodel.state.wl.title,
                        description: lmodel.state.wl.description,
                        icon: "",
                        created: "",
                        updated: "",
                        template: false,
                        categories: [],
                        exercises: lmodel.state.exercises,
                      ),
                      updateDatabase: false,
                      onAction: (workout) {
                        if (!lmodel.handleEdit(dmodel, workout)) {
                          snackbarErr(context, "Failed to save your changes");
                        }
                      },
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                child: Icon(
                  Icons.settings_rounded,
                  color: AppColors.text(context).withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
        if (lmodel.state.wl.description?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              lmodel.state.wl.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.border(context), width: 3),
                  ),
                  height: 35,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: LWTime(
                            start: lmodel.state.startTime,
                            style: ttLabel(
                              context,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 0.5,
                        color: AppColors.text(context).withOpacity(0.3),
                      ),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Text(
                            "${lmodel.state.workoutIndex + 1 > lmodel.state.exercises.length ? '-' : lmodel.state.workoutIndex + 1}/${lmodel.state.exercises.length}",
                            style: ttLabel(
                              context,
                              color: AppColors.text(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Clickable(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border(context), width: 3),
                    ),
                    height: 35,
                    child: Icon(
                      Icons.minimize,
                      color: AppColors.text(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Clickable(
                  onTap: () async {
                    await showAlert(
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
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border(context), width: 3),
                    ),
                    height: 35,
                    child: Icon(Icons.cancel_outlined, color: Colors.red[300]),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Clickable(
                  onTap: () async {
                    await showAlert(
                      context: context,
                      title: "Are You Sure?",
                      body: const Text(
                          "Once you finish a workout, you cannot go back and modify it."),
                      cancelText: "Go Back",
                      onCancel: () {},
                      submitBolded: true,
                      submitText: "Finish",
                      onSubmit: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        await lmodel.handleFinish(context, dmodel);
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.border(context), width: 3),
                    ),
                    height: 35,
                    child: Icon(Icons.star_rounded, color: Colors.amber[300]),
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

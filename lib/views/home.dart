import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/blurred_container.dart';
import 'package:workout_notepad_v2/components/clickable.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_home.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/profile/profile.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

enum HomeScreen { logs, collections, workouts, exercises, profile }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _getBody(dmodel),
        _bar(context, dmodel),
      ],
    );
  }

  Widget _getBody(DataModel dmodel) {
    switch (dmodel.currentTabScreen) {
      case HomeScreen.collections:
        return const CollectionHome();
      case HomeScreen.workouts:
        return const WorkoutsHome();
      case HomeScreen.exercises:
        return const ExerciseHome();
      case HomeScreen.profile:
        return const Profile();
      case HomeScreen.logs:
        return const LogsHome();
    }
  }

  Widget _bar(BuildContext context, DataModel dmodel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 0.5,
          width: double.infinity,
          color: AppColors.divider(context),
        ),
        BlurredContainer(
          backgroundColor: AppColors.background(context),
          opacity: 0.5,
          blur: 5,
          borderRadius: BorderRadius.circular(0),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (dmodel.user!.offline)
                  Container(
                    color: AppColors.divider(context),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "You are offline.",
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (dmodel.workoutState != null)
                  Clickable(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          enableDrag: true,
                          builder: (context) {
                            if (dmodel.workoutState == null) {
                              return Container();
                            } else {
                              return LaunchWorkout(state: dmodel.workoutState!);
                            }
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: AppColors.divider(context),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Clickable(
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
                                    dmodel.stopWorkout();
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                                child: Icon(
                                  Icons.stop_rounded,
                                  size: 30,
                                  color: AppColors.subtext(context),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Workout",
                                    style: TextStyle(
                                      color: AppColors.subtext(context),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dmodel.workoutState!.workout.title,
                                          style: TextStyle(
                                            color: AppColors.text(context),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            LWTime(
                              start: dmodel.workoutState!.startTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.subtext(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _barRow(
                        context,
                        dmodel,
                        LineIcons.barChartAlt,
                        "Logs",
                        HomeScreen.logs,
                      ),
                      _barRow(
                        context,
                        dmodel,
                        LineIcons.calendar,
                        "Collections",
                        HomeScreen.collections,
                      ),
                      _barRow(
                        context,
                        dmodel,
                        LineIcons.running,
                        "Workouts",
                        HomeScreen.workouts,
                      ),
                      _barRow(
                        context,
                        dmodel,
                        LineIcons.dumbbell,
                        "Exercises",
                        HomeScreen.exercises,
                      ),
                      _barRow(
                        context,
                        dmodel,
                        LineIcons.userCircle,
                        "Settings",
                        HomeScreen.profile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _barRow(
    BuildContext context,
    DataModel dmodel,
    IconData icon,
    String label,
    HomeScreen screen,
  ) {
    return GestureDetector(
      onTap: () {
        dmodel.setTabScreen(screen);
      },
      child: Container(
        decoration: BoxDecoration(
          color: dmodel.currentTabScreen == screen
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dmodel.currentTabScreen == screen
                ? dmodel.color
                : AppColors.subtext(context),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Icon(
            icon,
            color: dmodel.currentTabScreen == screen
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
        ),
      ),
    );
  }
}

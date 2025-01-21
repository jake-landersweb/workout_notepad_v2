import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/internet_provider.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/insights_home.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_home.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/overview/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/profile/profile.dart';
import 'package:workout_notepad_v2/views/welcome.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_time.dart';

enum HomeScreen { logs, overview, exercises, profile, discover, insights }

class ScreenModel extends ChangeNotifier {
  ScreenModel({HomeScreen? initScreen}) {
    _currentScreen = initScreen ?? HomeScreen.overview;
  }

  late HomeScreen _currentScreen;
  HomeScreen get screen => _currentScreen;
  void setScreen(HomeScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _modelShown = false;

  Future<void> _showWelcome(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 500));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cupertinoSheet(
        context: context,
        builder: (context) => const WelcomeScreen(),
      );
    });
  }

  Future<void> _showPostWorkout(BuildContext context) async {
    var db = await DatabaseProvider().database;
    var wlid = await db.rawQuery(
        "SELECT workoutLogId FROM workout_log ORDER BY created DESC LIMIT 1");
    if (wlid.isNotEmpty) {
      print(wlid);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cupertinoSheet(
          context: context,
          builder: (context) => PostWorkoutSummary(
            workoutLogId: wlid[0]['workoutLogId'] as String,
            onSave: (v) {},
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    if (dmodel.hasNoData && !_modelShown) {
      _modelShown = true;
      _showWelcome(context);
    }

    if (dmodel.showPostWorkoutScreen) {
      dmodel.showPostWorkoutScreen = false;
      _showPostWorkout(context);
    }

    return ChangeNotifierProvider(
      create: (context) => ScreenModel(),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _getBody(context, dmodel),
            _bar(context, dmodel),
          ],
        );
      },
    );
  }

  Widget _getBody(BuildContext context, DataModel dmodel) {
    var screenModel = Provider.of<ScreenModel>(context);
    if (dmodel.user == null) {
      return Container();
    }
    switch (screenModel.screen) {
      case HomeScreen.overview:
        return const OverviewHome();
      // return const WorkoutsHome();
      case HomeScreen.exercises:
        return const ExerciseHome();
      case HomeScreen.profile:
        return const Profile();
      case HomeScreen.logs:
        return const LogsHome();
      case HomeScreen.discover:
        return const WTHome();
      case HomeScreen.insights:
        return const InsightsHome();
    }
  }

  Widget _bar(BuildContext context, DataModel dmodel) {
    var internetModel = Provider.of<InternetProvider>(context);
    var screenModel = Provider.of<ScreenModel>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Container(
        //   height: 0.5,
        //   width: double.infinity,
        //   color: AppColors.divider(context),
        // ),
        BlurredContainer(
          // backgroundColor: AppColors.background(context),
          backgroundColor: AppColors.cell(context),
          opacity: 0.5,
          blur: 5,
          borderRadius: BorderRadius.circular(0),
          border: Border(
            top: BorderSide(color: AppColors.border(context), width: 2),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (!internetModel.hasInternet())
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
                            // Clickable(
                            //   onTap: () async {
                            //     await showAlert(
                            //       context: context,
                            //       title: "Are You Sure?",
                            //       body: const Text(
                            //           "If you cancel your workout, all progress will be lost."),
                            //       cancelText: "Go Back",
                            //       onCancel: () {},
                            //       cancelBolded: true,
                            //       submitColor: Colors.red,
                            //       submitText: "Yes",
                            //       onSubmit: () {
                            //         dmodel.stopWorkout(isCancel: true);
                            //         // dmodel.workoutState!.dumpToFile();
                            //       },
                            //     );
                            //   },
                            //   child: Padding(
                            //     padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
                            //     child: Icon(
                            //       Icons.stop_rounded,
                            //       size: 30,
                            //       color: AppColors.subtext(context),
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Current Workout",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                            SizedBox(
                              width: 60,
                              child: Center(
                                child: LWTime(
                                  start: dmodel.workoutState!.startTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.subtext(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _barRow(
                        context,
                        screenModel,
                        LineIcons.list,
                        "Exercises",
                        HomeScreen.exercises,
                      ),
                      _barRow(
                        context,
                        screenModel,
                        LineIcons.compass,
                        "Discover",
                        HomeScreen.discover,
                      ),
                      _barRow(
                        context,
                        screenModel,
                        LineIcons.dumbbell,
                        "Dashboard",
                        HomeScreen.overview,
                      ),
                      _barRow(
                        context,
                        screenModel,
                        LineIcons.lightbulb,
                        "Insights",
                        HomeScreen.insights,
                      ),
                      _barRow(
                        context,
                        screenModel,
                        LineIcons.pieChart,
                        "Logs",
                        HomeScreen.logs,
                      ),
                      // _barRow(
                      //   context,
                      //   dmodel,
                      //   LineIcons.userCircle,
                      //   "Settings",
                      //   HomeScreen.profile,
                      // ),
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
    ScreenModel screenModel,
    IconData icon,
    String label,
    HomeScreen screen,
  ) {
    return GestureDetector(
      key: ValueKey("homescreen-key-$label"),
      onTap: () {
        screenModel.setScreen(screen);
      },
      child: Container(
        decoration: BoxDecoration(
          color: screenModel.screen == screen
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: screenModel.screen == screen
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Icon(
            icon,
            color: screenModel.screen == screen
                ? Theme.of(context).colorScheme.onPrimary
                : null,
          ),
        ),
      ),
    );
  }
}

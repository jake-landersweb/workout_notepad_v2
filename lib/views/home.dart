import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/internet_provider.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/insights_home.dart';
import 'package:workout_notepad_v2/views/overview/workout_progress.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_home.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/overview/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/profile/profile.dart';
import 'package:workout_notepad_v2/views/welcome.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';

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
  final double _tabWidth = 45;
  final double _tabHeight = 34;

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

    var showCurrentWorkout = dmodel.workoutState != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SafeArea(
          bottom: true,
          child: Column(
            children: [
              if (!internetModel.hasInternet())
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.divider(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "You are offline.",
                              style: TextStyle(
                                color: AppColors.subtext(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Center(
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Sprung(36),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Your main bar as it currently is.
                      BlurredContainer(
                        backgroundColor: AppColors.cell(context),
                        opacity: 0.5,
                        blur: 5,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: AppColors.border(context), width: 2),
                        alignment: Alignment.center,
                        shrink: true,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Sprung.overDamped,
                                    left: _getPositionValue(
                                            Provider.of<ScreenModel>(context)) *
                                        _tabWidth,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      height: _tabHeight,
                                      width: _tabWidth,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Animated gap: when the red widget is active, add a gap.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Sprung(36),
                        width: showCurrentWorkout ? 8.0 : 0,
                      ),
                      // This AnimatedContainer always reserves space for the red widget.
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Sprung(36),
                        // Animate the width: full width when active, zero when not.
                        width: showCurrentWorkout ? _tabHeight + 8 : 0,
                        // You can animate the height as well if needed.
                        height: _tabHeight + 8,
                        // Optionally add alignment so that when the container shrinks, its child shrinks
                        alignment: Alignment.center,
                        child: showCurrentWorkout
                            ? Clickable(
                                onTap: () {
                                  showMaterialModalBottomSheet(
                                      context: context,
                                      enableDrag: true,
                                      builder: (context) {
                                        if (dmodel.workoutState == null) {
                                          return Container();
                                        } else {
                                          return LaunchWorkout(
                                              state: dmodel.workoutState!);
                                        }
                                      });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  height: _tabHeight + 8,
                                  width: _tabHeight + 8,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: WorkoutProgressIndicator(
                                        size: _tabHeight - 4,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        width: _tabWidth,
        height: _tabHeight,
        color: Colors.black.withValues(alpha: 0.0001),
        child: Center(
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

  double _getPositionValue(ScreenModel screenModel) {
    switch (screenModel._currentScreen) {
      case HomeScreen.exercises:
        return 0;
      case HomeScreen.discover:
        return 1;
      case HomeScreen.overview:
        return 2;
      case HomeScreen.insights:
        return 3;
      case HomeScreen.logs:
        return 4;
      default:
        return 0;
    }
  }
}

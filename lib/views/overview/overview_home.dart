import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/previous_workouts.dart';
import 'package:workout_notepad_v2/views/overview/previous_workout.dart';
import 'package:workout_notepad_v2/views/overview/workout_list.dart';
import 'package:workout_notepad_v2/views/overview/workout_progress.dart';
import 'package:workout_notepad_v2/views/profile/profile.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/create_edit/cew.dart';
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
      isLarge: false,
      horizontalSpacing: 0,
      refreshable: true,
      forceNoBar: true,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        await dmodel.fetchData(checkData: false);
      },
      children: [
        _build(context, dmodel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: _body(context, dmodel),
        ),
        // _exercises(context, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _build(BuildContext context, DataModel dmodel) {
    var screenModel = Provider.of<ScreenModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Clickable(
            onTap: () {
              navigate(context: context, builder: (context) => Profile());
            },
            child: Row(
              children: [
                dmodel.user!.avatar(context, size: 50),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    color: AppColors.background(context),
                    child: Column(
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
                        Text(dmodel.user?.getName() ?? "Unknown User",
                            style: ttLargeLabel(context)),
                      ],
                    ),
                  ),
                ),
                Icon(LineIcons.verticalEllipsis),
              ],
            ),
          ),
          // _templates2(context, dmodel),
          const SizedBox(height: 32),
          if (dmodel.workoutState == null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.border(context),
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Clickable(
                        onTap: () async {
                          var workout = Workout.init();
                          workout.title =
                              "Workout ${DateFormat('MM/dd/yy').format(
                            DateTime.now(),
                          )}";
                          // var db = await DatabaseProvider().database;
                          // await db.insert("workout", workout.toMap());
                          await launchWorkout(context, dmodel, workout,
                              isEmpty: true);
                        },
                        child: Container(
                          color: AppColors.cell(context),
                          height: 80,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    size: 24,
                                  ),
                                  Text(
                                    "New\nWorkout",
                                    style: ttBody(
                                      context,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 3, color: AppColors.border(context)),
                    Expanded(
                      child: Clickable(
                        onTap: () async {
                          showMaterialModalBottomSheet(
                            context: context,
                            enableDrag: false,
                            builder: (context) => const CEW(),
                          );
                        },
                        child: Container(
                          color: AppColors.cell(context),
                          height: 80,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    Icons.splitscreen,
                                    size: 24,
                                  ),
                                  Text(
                                    "Create a\nTemplate",
                                    style: ttBody(
                                      context,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 3, color: AppColors.border(context)),
                    Expanded(
                      child: Clickable(
                        onTap: () async {
                          screenModel.setScreen(HomeScreen.discover);
                        },
                        child: Container(
                          color: AppColors.cell(context),
                          height: 80,
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    LineIcons.globe,
                                    size: 24,
                                  ),
                                  Text(
                                    "Explore\nTemplates",
                                    style: ttBody(
                                      context,
                                      fontWeight: FontWeight.w600,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const WorkoutProgress(),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (dmodel.workouts.isEmpty &&
        (dmodel.remoteTemplates?.isEmpty ?? true) &&
        dmodel.workoutTemplates.isEmpty) {
      var screenModel = Provider.of<ScreenModel>(context);
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              "Welcome to\nWorkout Notepad!",
              style: ttSubTitle(context, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "We are exicted for you to get started. To get started, you can start a new workout, create a new template, or browse our templates.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            WrappedButton(
              title: "Start a New Workout",
              icon: Icons.play_arrow,
              center: true,
              borderColor: AppColors.border(context),
              onTap: () async {
                var workout = Workout.init();
                workout.title = "Workout ${DateFormat('MM/dd/yy').format(
                  DateTime.now(),
                )}";
                // var db = await DatabaseProvider().database;
                // await db.insert("workout", workout.toMap());
                await launchWorkout(context, dmodel, workout, isEmpty: true);
              },
            ),
            const SizedBox(height: 8),
            WrappedButton(
              title: "Create a Template",
              icon: Icons.add,
              center: true,
              borderColor: AppColors.border(context),
              onTap: () {
                showMaterialModalBottomSheet(
                  context: context,
                  enableDrag: false,
                  builder: (context) => const CEW(),
                );
              },
            ),
            const SizedBox(height: 8),
            WrappedButton(
              title: "Browse Templates",
              icon: LineIcons.globe,
              center: true,
              borderColor: AppColors.border(context),
              onTap: () {
                screenModel.setScreen(HomeScreen.discover);
              },
            ),
            const SizedBox(height: 8),
            WrappedButton(
              title: "Open Documentation",
              icon: LineIcons.book,
              center: true,
              borderColor: AppColors.border(context),
              onTap: () {
                launchUrl(Uri.parse("https://docs.workoutnotepad.co/"));
              },
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: const PreviousWorkout(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Clickable(
              onTap: () {
                navigate(
                  context: context,
                  builder: (context) => LogsPreviousWorkouts(),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.border(context), width: 3),
                ),
                padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "All Completed Workouts",
                        style: ttBody(context),
                      ),
                    ),
                    Opacity(
                      opacity: 0.7,
                      child: Icon(
                        Platform.isIOS
                            ? Icons.chevron_right
                            : Icons.arrow_right_alt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (dmodel.workouts.isNotEmpty) _templates(context, dmodel),
        ],
      );
    }
  }

  Widget getIcon(DataModel dmodel, String categoryId) {
    var match = dmodel.categories.firstWhere(
      (element) => element.categoryId == categoryId,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return getImageIcon(match.icon, size: 32);
  }

  Widget _templates(BuildContext context, DataModel dmodel) {
    return WorkoutList(
      title: "My Workouts",
      workouts: dmodel.allWorkouts,
      allowsExpand: false,
    );
  }
}

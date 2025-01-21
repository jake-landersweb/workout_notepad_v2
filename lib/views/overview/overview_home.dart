import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/overview/previous_workout.dart';
import 'package:workout_notepad_v2/views/overview/workout_progress.dart';
import 'package:workout_notepad_v2/views/profile/profile.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_home.dart';
import 'package:workout_notepad_v2/views/workout_templates/wt_saved.dart';
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
        _mainContent(context, dmodel),
        if (dmodel.workouts.isNotEmpty) _templates(context, dmodel),
        if (dmodel.workoutTemplates.isNotEmpty)
          _remoteTemplates(context, dmodel),
        // _exercises(context, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _mainContent(BuildContext context, DataModel dmodel) {
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
                  color: AppColors.border(context).withValues(alpha: 0.08),
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
                          height: 90,
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
                          cupertinoSheet(
                            context: context,
                            builder: (context) => HeaderBar.sheet(
                              title: "Select Template",
                              leading: const [CloseButton2()],
                              children: [
                                if (dmodel.defaultWorkouts.isNotEmpty)
                                  Section(
                                    "Default Templates",
                                    allowsCollapse: true,
                                    initOpen: dmodel.workouts.isEmpty,
                                    child: Column(
                                      children: [
                                        for (var i in dmodel.defaultWorkouts)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Clickable(
                                              onTap: () async {
                                                Navigator.of(context).pop();
                                                await launchWorkout(
                                                    context, dmodel, i);
                                              },
                                              child: WorkoutCell(
                                                workout: i,
                                                allowsTap: false,
                                              ),
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
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Clickable(
                                              onTap: () async {
                                                Navigator.of(context).pop();
                                                await launchWorkout(
                                                    context, dmodel, i);
                                              },
                                              child: WorkoutCell(
                                                workout: i,
                                                allowsTap: false,
                                              ),
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
                          color: AppColors.cell(context),
                          height: 90,
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
                                    "Start from a\nTemplate",
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
                          height: 90,
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
          const PreviousWorkout(),
        ],
      ),
    );
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
    List<Workout> _all = dmodel.workouts + dmodel.defaultWorkouts;
    return TemplateSection(
      title: "My Templates",
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
      templates: _all.length > 5 ? _all.slice(0, 5) : _all,
    );
  }

  Widget _remoteTemplates(BuildContext context, DataModel dmodel) {
    List<WorkoutTemplate> _all = dmodel.workoutTemplates;
    return TemplateSection(
      title: "Saved Templates",
      trailingWidget: Opacity(
        opacity: 0.7,
        child: Clickable(
          onTap: () {
            navigate(
              context: context,
              builder: (context) => const WTSaved(),
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
      templates: _all.length > 5 ? _all.slice(0, 5) : _all,
    );
  }
}

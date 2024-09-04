import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/recent_exercises.dart';
import 'package:workout_notepad_v2/views/logs/logs_cat_indiv.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';
import 'dart:math' as math;

import 'package:workout_notepad_v2/views/workouts/logs/wl_exercises.dart';

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  List<WorkoutLog> _workoutLogs = [];
  List<WorkoutLog> _currentWorkoutLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutLogs();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Logs Overview",
      isLarge: true,
      horizontalSpacing: 0,
      largeTitlePadding: const EdgeInsets.only(left: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: AppColors.cell(context),
              child: SfCalendar(
                dataSource: WorkoutLogCalendarDataSource(_workoutLogs),
                cellBorderColor: Colors.transparent,
                initialSelectedDate: DateTime.now(),
                showNavigationArrow: true,
                onTap: (d) {
                  _currentWorkoutLogs = [];
                  for (var i in d.appointments ?? []) {
                    _currentWorkoutLogs.add(i);
                  }
                  setState(() {});
                },
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayCount: 3,
                  // showAgenda: true,
                  dayFormat: 'EEE',
                ),
                view: CalendarView.month,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            curve: Sprung.overDamped,
            height: _currentWorkoutLogs.isEmpty
                ? 0
                : _currentWorkoutLogs.length * 75,
            child: Column(
              children: [
                for (int i = 0; i < _currentWorkoutLogs.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Clickable(
                        onTap: () {
                          cupertinoSheet(
                            context: context,
                            builder: (context) => PostWorkoutSummary(
                              workoutLogId: _currentWorkoutLogs[i].workoutLogId,
                              onSave: (wl) {
                                setState(() {
                                  _currentWorkoutLogs[i] = wl;
                                });
                              },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cell(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: double.infinity,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  _currentWorkoutLogs[i]
                                      .getCreated()
                                      .day
                                      .toString(),
                                  style: ttTitle(context),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _currentWorkoutLogs[i].title,
                                        style: ttLabel(context),
                                      ),
                                      Text(
                                        _currentWorkoutLogs[i].getDuration(),
                                        style: ttBody(
                                          context,
                                          color: AppColors.subtext(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppColors.subtext(context),
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
        ),
        // most logged for all types (2x2)
        Section(
          "Basic",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
            childPadding: EdgeInsets.zero,
            children: [
              Tuple4(
                "Workout Logs",
                Icons.calendar_month_rounded,
                Colors.green[200]!,
                const LogsPreviousWorkouts(),
              ),
              Tuple4(
                "Recent Exercises",
                Icons.update_rounded,
                Colors.purple[200]!,
                const RecentExercises(),
              ),
            ],
            onChildTap: (context, item, index) =>
                navigate(context: context, builder: (context) => item.v4),
            childBuilder: (context, item, index) {
              return Row(
                children: [
                  Expanded(
                    child: WrappedButton(
                      title: item.v1,
                      icon: item.v2,
                      iconBg: item.v3,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.subtext(context),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ),
        Section(
          "Advanced",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Tuple4<String, IconData, Color, Widget>>(
            childPadding: EdgeInsets.zero,
            children: [
              Tuple4(
                "Workouts Breakdown",
                Icons.analytics_rounded,
                Colors.deepOrange[200]!,
                const LogsWorkoutsBreakdown(),
              ),
              Tuple4(
                "My Max Sets",
                Icons.speed_rounded,
                Colors.red[200]!,
                const LogsMaxSets(),
              ),
              Tuple4(
                "Exercise Type Distribution",
                Icons.donut_small_rounded,
                Colors.blue[200]!,
                const LogsTypeDistribution(),
              ),
              Tuple4(
                "Categories Overview",
                Icons.donut_small_rounded,
                Colors.orange[200]!,
                LogsCategoryDistribution(categories: dmodel.categories),
              ),
            ],
            onChildTap: (context, item, index) {
              if (dmodel.hasValidSubscription()) {
                navigate(context: context, builder: (context) => item.v4);
              } else {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const Subscriptions(),
                );
              }
            },
            childBuilder: (context, item, index) {
              return Row(
                children: [
                  Expanded(
                    child: WrappedButton(
                      title: item.v1,
                      icon: item.v2,
                      iconBg: item.v3,
                    ),
                  ),
                  Icon(
                    dmodel.hasValidSubscription()
                        ? Icons.chevron_right_rounded
                        : Icons.lock_rounded,
                    color: AppColors.subtext(context),
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ),
        Section(
          "Category",
          headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
          child: ContainedList<Category>(
            childPadding: const EdgeInsets.only(left: 16),
            children: dmodel.categories,
            onChildTap: (context, item, index) {
              if (dmodel.hasValidSubscription()) {
                navigate(
                  context: context,
                  builder: (context) => LogsCategoryIndividual(category: item),
                );
              } else {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const Subscriptions(),
                );
              }
            },
            childBuilder: (context, item, index) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cell(context)[500],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 30,
                      width: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: getImageIcon(item.icon),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title.capitalize(),
                        style: ttLabel(context),
                      ),
                    ),
                    Icon(
                      dmodel.hasValidSubscription()
                          ? Icons.chevron_right_rounded
                          : Icons.lock_rounded,
                      color: AppColors.subtext(context),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              );
            },
          ),
        ),

        SizedBox(
            height: (dmodel.workoutState == null ? 100 : 130) +
                (dmodel.user!.offline ? 30 : 0)),
      ],
    );
  }

  Future<void> _fetchWorkoutLogs() async {
    var db = await DatabaseProvider().database;

    var logsResponse = await db.rawQuery("""
      SELECT * FROM workout_log
      ORDER BY created DESC
    """);
    for (var i in logsResponse) {
      var log = await WorkoutLog.fromJson(i);
      _workoutLogs.add(log);
      if (log.getCreated().day == DateTime.now().day &&
          log.getCreated().month == DateTime.now().month &&
          log.getCreated().year == DateTime.now().year) {
        _currentWorkoutLogs.add(log);
      }
    }
    setState(() {});
  }
}

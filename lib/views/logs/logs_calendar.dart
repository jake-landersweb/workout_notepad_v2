import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'dart:math' as math;

class LogsCalendar extends StatefulWidget {
  const LogsCalendar({super.key});

  @override
  State<LogsCalendar> createState() => _LogsCalendarState();
}

class _LogsCalendarState extends State<LogsCalendar> {
  final List<WorkoutLog> _workoutLogs = [];
  List<WorkoutLog> _currentWorkoutLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: "Workout Calendar",
        leading: const [BackButton2()],
        horizontalSpacing: 0,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: AppColors.cell(context),
                child: SfCalendar(
                  dataSource: WorkoutLogCalendarDataSource(_workoutLogs),
                  cellBorderColor: Colors.transparent,
                  initialSelectedDate: DateTime.now(),
                  headerStyle: CalendarHeaderStyle(
                    backgroundColor: AppColors.cell(context),
                  ),
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
                                workoutLogId:
                                    _currentWorkoutLogs[i].workoutLogId,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
        ],
      ),
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

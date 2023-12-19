import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'package:workout_notepad_v2/views/logs/post_workout.dart';
import 'dart:math' as math;

import 'package:workout_notepad_v2/views/workouts/logs/root.dart';

class LogsPreviousWorkouts extends StatefulWidget {
  const LogsPreviousWorkouts({super.key});

  @override
  State<LogsPreviousWorkouts> createState() => _LogsPreviousWorkoutsState();
}

class _LogsPreviousWorkoutsState extends State<LogsPreviousWorkouts> {
  final List<Tuple2<DateTime, double>> _workoutDurationDays = [];
  final List<WorkoutLog> _workoutLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: "Prev Workouts",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const SizedBox(height: 8),
          Section(
            "All Workouts - ${_workoutLogs.length}",
            child: _child(context),
          ),
        ],
      ),
    );
  }

  Widget _child(BuildContext context) {
    if (_isLoading) {
      return LoadingWrapper(
        child: ContainedList<int>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
          children: List.generate(15, (index) => index),
          childBuilder: (context, item, index) => Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider(context)),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Column(
                    children: [
                      Container(
                        color: AppColors.cell(context)[600],
                        height: 20,
                        width: 50,
                        child: Center(
                          child: Text(
                            "  ",
                            style: TextStyle(
                              color: AppColors.subtext(context),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: AppColors.cell(context)[300],
                        height: 30,
                        width: 50,
                        child: Center(
                          child: Text(
                            "  ",
                            style:
                                ttLabel(context, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      );
    } else if (_workoutLogs.isEmpty) {
      return const NoLogs();
    } else {
      return ContainedList<WorkoutLog>(
        leadingPadding: 0,
        trailingPadding: 0,
        childPadding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
        children: _workoutLogs,
        onChildTap: (context, item, index) {
          print(item.workoutLogId);
          cupertinoSheet(
            context: context,
            builder: (context) => PostWorkoutSummary(
              workoutLogId: item.workoutLogId,
              onSave: (wl) => setState(() {
                _workoutLogs[index] = wl;
              }),
            ),
          );
        },
        childBuilder: (context, item, index) => _workoutCell(context, item),
      );
    }
  }

  Widget _workoutCell(BuildContext context, WorkoutLog item) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider(context)),
            borderRadius: BorderRadius.circular(7),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Column(
              children: [
                Container(
                  color: AppColors.cell(context)[600],
                  height: 20,
                  width: 50,
                  child: Center(
                    child: Text(
                      DateFormat('MMM').format(
                        item.getCreated(),
                      ),
                      style: TextStyle(
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: AppColors.cell(context)[300],
                  height: 30,
                  width: 50,
                  child: Center(
                    child: Text(
                      item.getCreated().day.toString(),
                      style: ttLabel(context, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: ttLabel(context),
              ),
              Text(
                item.getDuration(),
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
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var db = await DatabaseProvider().database;
    var response = await db.rawQuery("""
      WITH dates AS (
        SELECT DISTINCT DATE(wl.created) as log_date
        FROM workout_log wl
        ORDER BY log_date DESC
        LIMIT 7
      )
      SELECT 
        d.log_date,
        SUM(wl.duration) as sum_duration
      FROM dates d
      JOIN workout_log wl ON DATE(wl.created) = d.log_date
      GROUP BY d.log_date
      ORDER BY d.log_date;
    """);

    for (var i in response) {
      _workoutDurationDays.add(
        Tuple2(
          DateTime.parse(i['log_date'] as String),
          (i['sum_duration'] as int).toDouble(),
        ),
      );
    }
    var logsResponse = await db.rawQuery("""
      SELECT * FROM workout_log
      ORDER BY created DESC
    """);
    for (var i in logsResponse) {
      _workoutLogs.add(await WorkoutLog.fromJson(i));
    }

    setState(() {
      _isLoading = false;
    });
  }
}

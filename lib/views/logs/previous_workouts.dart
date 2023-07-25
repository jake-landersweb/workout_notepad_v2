import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
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
            "Workout Duration By Day",
            child: AspectRatio(
              aspectRatio: 1,
              child: _child(context),
            ),
          ),
          const SizedBox(height: 16),
          if (_workoutLogs.isNotEmpty)
            Section(
              "All Workouts - ${_workoutLogs.length}",
              child: ContainedList<WorkoutLog>(
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
                children: _workoutLogs,
                onChildTap: (context, item, index) {
                  print(item.workoutLogId);
                  cupertinoSheet(
                    context: context,
                    builder: (context) => WLExercises(workoutLog: item),
                  );
                },
                childBuilder: (context, item, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.getCreatedFormatted(),
                              style: ttcaption(context),
                            ),
                            Text(
                              item.title,
                              style: ttLabel(context),
                            ),
                            Text(item.getDuration()),
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
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _child(BuildContext context) {
    if (_isLoading) {
      return LoadingWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (_workoutLogs.isEmpty) {
      return const NoLogs();
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.7),
                  getTooltipItem: (group, a, rod, b) {
                    return BarTooltipItem(
                      "${formatHHMMSS(rod.toY.toInt())}\n${formatDateTime(DateTime.fromMillisecondsSinceEpoch(group.x))}",
                      const TextStyle(),
                    );
                  },
                ),
              ),
              maxY: _workoutDurationDays
                      .reduce((a, b) => a.v2 > b.v2 ? a : b)
                      .v2 *
                  1.3,
              barGroups: [
                for (var i in _workoutDurationDays)
                  BarChartGroupData(
                    x: i.v1.millisecondsSinceEpoch,
                    barRods: [
                      BarChartRodData(
                        toY: i.v2,
                        width: (MediaQuery.of(context).size.width / 7) - 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
              ],
              titlesData: FlTitlesData(
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        formatHHMMSS(value.toInt()),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subtext(context),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "Set #${value.round() + 1}",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.subtext(context),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var db = await getDB();
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

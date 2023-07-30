import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'dart:math' as math;

class LogsWorkoutsBreakdown extends StatefulWidget {
  const LogsWorkoutsBreakdown({super.key});

  @override
  State<LogsWorkoutsBreakdown> createState() => _LogsWorkoutsBreakdownState();
}

class _LogsWorkoutsBreakdownState extends State<LogsWorkoutsBreakdown> {
  final List<Tuple2<DateTime, double>> _workoutDurationData = [];
  final List<Tuple4<String, DateTime, int, int>> _workoutStatsData = [];
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
        title: "W. Breakdown",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          // const SizedBox(height: 8),
          Section(
            "Workout Duration By Day",
            child: AspectRatio(
              aspectRatio: 1,
              child: _workoutDurations(context),
            ),
          ),
          Section(
            "Exercise and Set Count",
            child: AspectRatio(
              aspectRatio: 1,
              child: _workoutStats(context),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _workoutDurations(BuildContext context) {
    if (_isLoading) {
      return LoadingWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (_workoutDurationData.isEmpty) {
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
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
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
              maxY: _workoutDurationData
                      .reduce((a, b) => a.v2 > b.v2 ? a : b)
                      .v2 *
                  1.3,
              barGroups: [
                for (var i in _workoutDurationData)
                  BarChartGroupData(
                    x: i.v1.millisecondsSinceEpoch,
                    barRods: [
                      BarChartRodData(
                        toY: i.v2,
                        width: (MediaQuery.of(context).size.width /
                                _workoutDurationData.length) -
                            8,
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

  Widget _workoutStats(BuildContext context) {
    if (_isLoading) {
      return LoadingWrapper(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (_workoutDurationData.isEmpty) {
      return const NoLogs();
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              maxY: _workoutStatsData.reduce((a, b) => a.v4 > b.v4 ? a : b).v4 *
                  1.3,
              minY: 0,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipBgColor: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.7),
                  getTooltipItems: (touchedSpots) {
                    List<LineTooltipItem> items = [];
                    for (var i in touchedSpots) {
                      items.add(
                        LineTooltipItem(
                          "${i.barIndex == 0 ? "${_workoutStatsData[i.spotIndex].v1}\n" : ""}${i.barIndex == 0 ? "Sets: " : "Reps: "}${i.y.toInt()}",
                          ttBody(
                            context,
                            color: i.bar.color,
                          ),
                        ),
                      );
                    }
                    return items;
                  },
                ),
              ),
              titlesData: FlTitlesData(
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.round().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subtext(context),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i in _workoutStatsData)
                      FlSpot(i.v2.millisecondsSinceEpoch.toDouble(),
                          i.v4.toDouble()),
                  ],
                  barWidth: 5,
                  color: AppColors.cell(context)[800],
                  isCurved: true,
                  preventCurveOverShooting: true,
                  curveSmoothness: 0.3,
                  isStrokeCapRound: false,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    color: AppColors.cell(context)[600],
                    show: true,
                  ),
                ),
                LineChartBarData(
                  spots: [
                    for (var i in _workoutStatsData)
                      FlSpot(
                        i.v2.millisecondsSinceEpoch.toDouble(),
                        i.v3.toDouble(),
                      ),
                  ],
                  barWidth: 5,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  isCurved: true,
                  preventCurveOverShooting: true,
                  curveSmoothness: 0.3,
                  isStrokeCapRound: false,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    show: true,
                  ),
                ),
              ],
            ),
            swapAnimationCurve: Sprung(36),
            swapAnimationDuration: const Duration(milliseconds: 700),
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
        LIMIT 30
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
      _workoutDurationData.add(
        Tuple2(
          DateTime.parse(i['log_date'] as String),
          (i['sum_duration'] as int).toDouble(),
        ),
      );
    }

    var response2 = await db.rawQuery("""
      SELECT 
        wl.workoutLogId, 
        wl.title, 
        wl.created, 
        COUNT(el.exerciseLogId) AS num_exercises, 
        SUM(el.sets) AS num_sets
      FROM workout_log AS wl
      LEFT JOIN exercise_log AS el
      ON wl.workoutLogId = el.workoutLogId
      GROUP BY wl.workoutLogId
      ORDER BY wl.created
      LIMIT 15;
    """);

    for (var i in response2) {
      _workoutStatsData.add(
        Tuple4(
          i['title'] as String,
          DateTime.parse(i['created'] as String),
          i['num_exercises'] as int,
          i['num_sets'] as int,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}

import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogModel extends ChangeNotifier {
  LogModel() {
    composeData();
  }

  List<Tuple2<Exercise, int>> topExercises = [];
  List<Tuple2<ExerciseType, int>> logDistribution = [];
  List<Tuple2<DateTime, double>> workoutDurationDays = [];
  Tuple2<Exercise, int>? maxWeight;
  Tuple2<Exercise, int>? maxTime;
  Tuple2<Exercise, int>? maxReps;
  List<Exercise> recentlyLogged = [];

  Future<void> composeData() async {
    print("composing log data");
    var db = await getDB();

    // get top logged exercises for each type
    var topTypeResponse = await db.rawQuery("""
      WITH logged_exercises AS (
        SELECT *, COUNT(*) AS log_count
        FROM exercise e
        INNER JOIN exercise_log el
          ON e.exerciseId = el.exerciseId
        GROUP BY e.type, e.exerciseId, e.title
      ),
      max_logged_exercises AS (
        SELECT 
          type,
          MAX(log_count) AS max_log_count
        FROM logged_exercises
        GROUP BY type
      )
      SELECT * FROM logged_exercises le
      INNER JOIN max_logged_exercises mle
        ON le.type = mle.type AND le.log_count = mle.max_log_count
      ORDER BY le.type;
    """);

    for (var i in topTypeResponse) {
      topExercises.add(Tuple2(Exercise.fromJson(i), i['log_count'] as int));
    }

    // get exercise type distribution
    var distributionResponse = await db.rawQuery("""
      SELECT 
        e.type,
        COUNT(el.exerciseId) AS log_count
      FROM exercise e
      JOIN exercise_log el
        ON e.exerciseId = el.exerciseId
      GROUP BY e.type
      ORDER BY e.type;
    """);

    for (var i in distributionResponse) {
      logDistribution.add(Tuple2(
          exerciseTypeFromJson(i['type'] as int), i['log_count'] as int));
    }

    var durationResponse = await db.rawQuery("""
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

    for (var i in durationResponse) {
      workoutDurationDays.add(
        Tuple2(
          DateTime.parse(i['log_date'] as String),
          (i['sum_duration'] as int).toDouble(),
        ),
      );
    }

    var maxWeightResponse = await db.rawQuery("""
      SELECT 
        *,
        MAX(CASE WHEN elm.weightPost = "kg" THEN elm.weight * 2.204 ELSE elm.weight END) AS max_weight
      FROM exercise e
      JOIN exercise_log_meta elm
        ON e.exerciseId = elm.exerciseId
      GROUP BY e.exerciseId
      ORDER BY max_weight DESC
      LIMIT 1;
    """);
    var maxTimeResponse = await db.rawQuery("""
      SELECT 
        *,
        MAX(elm.time) AS max_time
      FROM exercise e
      JOIN exercise_log_meta elm
        ON e.exerciseId = elm.exerciseId
      GROUP BY e.exerciseId
      ORDER BY max_time DESC
      LIMIT 1;
    """);
    var maxRepsResponse = await db.rawQuery("""
      SELECT 
        *,
        MAX(elm.reps) AS max_reps
      FROM exercise e
      JOIN exercise_log_meta elm
        ON e.exerciseId = elm.exerciseId
      GROUP BY e.exerciseId
      ORDER BY max_reps DESC
      LIMIT 1;
    """);
    for (var i in maxWeightResponse) {
      maxWeight = Tuple2(Exercise.fromJson(i), i['max_weight'] as int);
    }
    for (var i in maxTimeResponse) {
      maxTime = Tuple2(Exercise.fromJson(i), i['max_time'] as int);
    }
    for (var i in maxRepsResponse) {
      maxReps = Tuple2(Exercise.fromJson(i), i['max_reps'] as int);
    }

    var recentResponse = await db.rawQuery("""
      SELECT * FROM exercise_log el
      JOIN exercise e ON e.exerciseId = el.exerciseId
      ORDER BY el.created DESC LIMIT 5
    """);

    for (var i in recentResponse) {
      recentlyLogged.add(Exercise.fromJson(i));
    }

    notifyListeners();
  }
}

class LogsHome extends StatefulWidget {
  const LogsHome({super.key});

  @override
  State<LogsHome> createState() => _LogsHomeState();
}

class _LogsHomeState extends State<LogsHome> {
  var _pageController = PageController();
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LogModel(),
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var lmodel = Provider.of<LogModel>(context);
    return HeaderBar(
      title: "Logs Overview",
      isLarge: true,
      horizontalSpacing: 0,
      largeTitlePadding: const EdgeInsets.only(left: 16),
      children: [
        const SizedBox(height: 16),
        // most logged for all types (2x2)
        ContainedList<Tuple4<String, IconData, Color, Widget>>(
          childPadding: EdgeInsets.zero,
          children: [
            Tuple4(
              "Previous Workouts",
              Icons.work_outline,
              Colors.green[200]!,
              const LogsPreviousWorkouts(),
            ),
            Tuple4(
              "My Max Sets",
              Icons.work_outline,
              Colors.red[200]!,
              Container(),
            ),
            Tuple4(
              "Exercise Type Distribution",
              Icons.work_outline,
              Colors.blue[200]!,
              Container(),
            ),
            Tuple4(
              "Recently Logged",
              Icons.work_outline,
              Colors.purple[200]!,
              Container(),
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

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Section(
        //     "Most Logged By Type",
        //     child: Column(
        //       children: [
        //         for (var i in lmodel.topExercises)
        //           Padding(
        //             padding: const EdgeInsets.only(bottom: 8.0),
        //             child: _mostLoggedCell(context, i),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
        // if (lmodel.logDistribution.isNotEmpty)
        //   Section(
        //     "Log Distribution",
        //     child: ConstrainedBox(
        //       constraints: BoxConstraints(maxHeight: 400),
        //       child: _distribution(context, lmodel),
        //     ),
        //   ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Section(
        //     "Max Values",
        //     child: Column(
        //       children: [
        //         if (lmodel.maxWeight != null)
        //           _maxCell(
        //             context,
        //             "Weight",
        //             lmodel.maxWeight!.v1,
        //             "${lmodel.maxWeight!.v2} lbs",
        //           ),
        //         if (lmodel.maxTime != null)
        //           _maxCell(
        //             context,
        //             "Time",
        //             lmodel.maxTime!.v1,
        //             formatHHMMSS(lmodel.maxTime!.v2),
        //           ),
        //         if (lmodel.maxReps != null)
        //           _maxCell(
        //             context,
        //             "Reps",
        //             lmodel.maxReps!.v1,
        //             "x ${lmodel.maxReps!.v2}",
        //           ),
        //       ],
        //     ),
        //   ),
        // ),

        // if (lmodel.workoutDurationDays.isNotEmpty)
        //   Section(
        //     "Workout Duration Last 7 Days",
        //     child: ConstrainedBox(
        //       constraints: BoxConstraints(maxHeight: 400),
        //       child: _sumDurationDays(context, lmodel),
        //     ),
        //   ),

        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //   child: Section(
        //     "Recently Logged",
        //     child: Column(
        //       children: [
        //         for (var i in lmodel.recentlyLogged)
        //           Clickable(
        //             onTap: () {
        //               cupertinoSheet(
        //                 context: context,
        //                 builder: (context) => ExerciseLogs(
        //                   exerciseId: i.exerciseId,
        //                   isInteractive: false,
        //                 ),
        //               );
        //             },
        //             child: ExerciseCell(exercise: i),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),

        SizedBox(
            height: (dmodel.workoutState == null ? 100 : 130) +
                (dmodel.user!.offline ? 30 : 0)),
      ],
    );
  }

  Widget _mostLoggedCell(BuildContext context, Tuple2<Exercise, int> item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Image.asset(
                    exerciseTypeIcon(item.v1.type),
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exerciseTypeTitle(item.v1.type),
                    style: ttcaption(context),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Text(
                    item.v1.title,
                    style: ttcaption(context),
                  ),
                  Text(
                    "${item.v2} Logs",
                    style: ttTitle(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _maxCell(
    BuildContext context,
    String title,
    Exercise exercise,
    String maxVal,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ttcaption(context)),
                    Text(
                      exercise.title,
                      style: ttLabel(context),
                    ),
                    const SizedBox(height: 4),
                    CategoryCell(
                      categoryId: exercise.category,
                    ),
                  ],
                ),
              ),
              Text(maxVal, style: ttTitle(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _distribution(BuildContext context, LogModel lmodel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: [
            for (var i in lmodel.logDistribution)
              PieChartSectionData(
                value: i.v2.toDouble(),
                color: exerciseTypeColor(i.v1),
                radius: 100,
                title: "${i.v2}\n${exerciseTypeTitle(i.v1)}",
                badgeWidget: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset(
                      exerciseTypeIcon(i.v1),
                      height: 30,
                      width: 30,
                    ),
                  ),
                ),
                badgePositionPercentageOffset: .98,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sumDurationDays(BuildContext context, LogModel lmodel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
              getTooltipItem: (group, a, rod, b) {
                return BarTooltipItem(
                  "${formatHHMMSS(rod.toY.toInt())}\n${formatDateTime(DateTime.fromMillisecondsSinceEpoch(group.x))}",
                  const TextStyle(),
                );
              },
            ),
          ),
          maxY: lmodel.workoutDurationDays
                  .reduce((a, b) => a.v2 > b.v2 ? a : b)
                  .v2 *
              1.3,
          barGroups: [
            for (var i in lmodel.workoutDurationDays)
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
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
    );
  }
}

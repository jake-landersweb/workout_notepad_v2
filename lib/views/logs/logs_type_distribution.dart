import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsTypeDistribution extends StatefulWidget {
  const LogsTypeDistribution({super.key});

  @override
  State<LogsTypeDistribution> createState() => _LogsTypeDistributionState();
}

class _LogsTypeDistributionState extends State<LogsTypeDistribution> {
  bool _isLoading = true;
  final List<Tuple2<Exercise, int>> _topExercises = [];
  final List<Tuple2<ExerciseType, int>> _logDistribution = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: "Type Distribution",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const SizedBox(height: 32),
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: [
                  for (var i in _logDistribution)
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
          ),
          const SizedBox(height: 16),
          Section(
            "Most Logged By Type",
            child: Column(
              children: [
                for (var i in _topExercises)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _mostLoggedCell(context, i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mostLoggedCell(BuildContext context, Tuple2<Exercise, int> item) {
    return Clickable(
      onTap: () {
        cupertinoSheet(
          context: context,
          builder: (context) => ExerciseLogs(
            exerciseId: item.v1.exerciseId,
            isInteractive: false,
          ),
        );
      },
      child: Container(
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
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var db = await getDB();
    var response = await db.rawQuery("""
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

    for (var i in response) {
      _topExercises.add(Tuple2(Exercise.fromJson(i), i['log_count'] as int));
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
      _logDistribution.add(
        Tuple2(exerciseTypeFromJson(i['type'] as int), i['log_count'] as int),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
}

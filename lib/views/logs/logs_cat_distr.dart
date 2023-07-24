import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsCategoryDistribution extends StatefulWidget {
  const LogsCategoryDistribution({
    super.key,
    required this.categories,
  });
  final List<Category> categories;

  @override
  State<LogsCategoryDistribution> createState() =>
      _LogsCategoryDistributionState();
}

class _LogsCategoryDistributionState extends State<LogsCategoryDistribution> {
  final List<Tuple2<Category, int>> _distribution = [];
  final List<Tuple4<Category, String, String, int>> _mostLogged = [];
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
        title: "Categories",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: _isLoading || _distribution.isEmpty
                  ? LoadingWrapper(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cell(context),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    )
                  : RadarChart(
                      RadarChartData(
                        tickBorderData: BorderSide.none,
                        gridBorderData: BorderSide.none,
                        radarBorderData: BorderSide.none,
                        titlePositionPercentageOffset: 0.1,
                        borderData: FlBorderData(
                          show: false,
                        ),
                        tickCount: 1,
                        ticksTextStyle: const TextStyle(
                            color: Colors.transparent, fontSize: 10),
                        dataSets: [
                          RadarDataSet(
                            fillColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            borderColor: Theme.of(context).colorScheme.primary,
                            dataEntries: [
                              for (var i in _distribution)
                                RadarEntry(value: i.v2.toDouble()),
                            ],
                          ),
                        ],
                        getTitle: (index, angle) {
                          return RadarChartTitle(
                            text:
                                "${_distribution[index].v2}\n${_distribution[index].v1.title.capitalize()}",
                            angle:
                                angle < 270 && angle > 90 ? angle - 180 : angle,
                          );
                        },
                      ),
                      swapAnimationDuration:
                          Duration(milliseconds: 150), // Optional
                      swapAnimationCurve: Curves.linear, // Optional
                    ),
            ),
          ),
          if (_mostLogged.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Section(
                "Most Logged By Category",
                child: Column(
                  children: [
                    for (var i in _mostLogged)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _cell(context, i),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(
      BuildContext context, Tuple4<Category, String, String, int> item) {
    return Clickable(
      onTap: () {
        cupertinoSheet(
          context: context,
          builder: (context) => ExerciseLogs(
            exerciseId: item.v3,
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              getImageIcon(item.v1.icon, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.v1.title.capitalize(), style: ttcaption(context)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.v2,
                            style: ttLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text("${item.v4} Logs",
                  style: ttBody(context, fontWeight: FontWeight.w700)),
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
      SELECT 
        e.category,
        COUNT(el.exerciseLogId) AS log_count
      FROM exercise e
      JOIN exercise_log el
        ON e.exerciseId = el.exerciseId
      GROUP BY e.category;
    """);
    for (var i in response) {
      // get the category
      var c = widget.categories
          .firstWhereOrNull((element) => element.categoryId == i['category']);
      if (c != null) {
        _distribution.add(Tuple2(c, i['log_count'] as int));
      }
    }

    var topCatExerciseResponse = await db.rawQuery("""
      WITH logged_exercises AS (
        SELECT 
          e.category,
          e.exerciseId,
          e.title,
          COUNT(*) AS log_count
        FROM exercise e
        INNER JOIN exercise_log el
          ON e.exerciseId = el.exerciseId
        GROUP BY e.category, e.exerciseId, e.title
      ),
      ranked_exercises AS (
        SELECT 
          le.category,
          le.exerciseId,
          le.title,
          le.log_count,
          ROW_NUMBER() OVER(PARTITION BY le.category ORDER BY le.log_count DESC) as rn
        FROM logged_exercises le
      )
      SELECT 
        category,
        exerciseId,
        title,
        log_count
      FROM ranked_exercises
      WHERE rn = 1;
    """);
    for (var i in topCatExerciseResponse) {
      var c = widget.categories
          .firstWhereOrNull((element) => element.categoryId == i['category']);
      if (c != null) {
        _mostLogged.add(Tuple4(c, i['title'] as String,
            i['exerciseId'] as String, i['log_count'] as int));
      }
    }

    _mostLogged.sort((a, b) => b.v3.compareTo(a.v3));

    setState(() {
      _isLoading = false;
    });
  }
}

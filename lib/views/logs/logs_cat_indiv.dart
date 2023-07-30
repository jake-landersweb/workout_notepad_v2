import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'dart:math' as math;

class LogsCategoryIndividual extends StatefulWidget {
  const LogsCategoryIndividual({
    super.key,
    required this.category,
  });
  final Category category;

  @override
  State<LogsCategoryIndividual> createState() => _LogsCategoryIndividualState();
}

class _LogsCategoryIndividualState extends State<LogsCategoryIndividual> {
  bool _isLoading = true;
  bool _hasError = false;

  // max vals
  Tuple3<String, DateTime, String>? _maxWeight;
  Tuple3<String, DateTime, String>? _maxTime;
  Tuple3<String, DateTime, String>? _maxReps;
  Tuple3<String, DateTime, String>? _maxSets;

  // exercise dist
  final List<Tuple2<String, int>> _exerciseDist = [];
  // tag dist
  final List<Tuple2<String, int>> _tagDist = [];

  // recently Logged
  final List<Tuple3<String, String, DateTime>> _recentlyLogged = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: widget.category.title.capitalize(),
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          Section(
            "Maxes",
            child: ContainedList<Tuple3<String, DateTime, String>>(
              childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              leadingPadding: 0,
              trailingPadding: 0,
              children: [
                if (_maxWeight != null) _maxWeight!,
                if (_maxTime != null) _maxTime!,
                if (_maxReps != null) _maxReps!,
                if (_maxSets != null) _maxSets!,
              ],
              childBuilder: (context, item, index) {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatDateTime(item.v2),
                            style: ttcaption(context),
                          ),
                          Text(item.v1),
                        ],
                      ),
                    ),
                    Text(
                      item.v3,
                      style: ttBody(
                        context,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // exercise frequency distribution
          if (_exerciseDist.isNotEmpty)
            _distGraph(context, "Execise Distribution", _exerciseDist),

          // tag distribution for category
          if (_tagDist.isNotEmpty)
            _distGraph(context, "Tag Distribution", _tagDist),

          // recently logged for category
          if (_recentlyLogged.isNotEmpty)
            Section(
              "Recently Logged",
              child: ContainedList<Tuple3<String, String, DateTime>>(
                children: _recentlyLogged,
                childPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                leadingPadding: 0,
                trailingPadding: 0,
                onChildTap: (context, item, index) {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => ExerciseLogs(
                      exerciseId: item.v1,
                      isInteractive: false,
                    ),
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
                              formatDateTime(item.v3),
                              style: ttcaption(context),
                            ),
                            Text(item.v2),
                          ],
                        ),
                      ),
                      Transform.rotate(
                        angle: math.pi / -2,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.subtext(context),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _distGraph(
    BuildContext context,
    String title,
    List<Tuple2<String, int>> data,
  ) {
    return Section(
      title,
      allowsCollapse: true,
      initOpen: true,
      child: Column(
        children: [
          // graph
          AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i in data)
                      PieChartSectionData(
                        value: i.v2.toDouble(),
                        color: ColorUtil.random(i.v1),
                        radius: 100,
                        title: i.v1
                            .split(" ")
                            .map((e) => e[0].toUpperCase())
                            .join("."),
                        badgePositionPercentageOffset: .98,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i in data)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ColorUtil.random(i.v1),
                          shape: BoxShape.circle,
                        ),
                        height: 25,
                        width: 25,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${i.v1} - ${i.v2}",
                        style: ttcaption(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var db = await getDB();
      var weightResponse = await db.rawQuery("""
        SELECT
          el.title AS title,
          el.created AS date,
          elm.weightPost,
          MAX(elm.weight) AS max_val
        FROM exercise_log_meta elm
        JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
        JOIN exercise e ON el.exerciseId = e.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        GROUP BY el.exerciseLogId, el.title, el.created
        ORDER BY max_val DESC
        LIMIT 1;
      """);
      if (weightResponse.isNotEmpty) {
        var val = weightResponse[0]['max_val'] as num;
        if (val > 0) {
          _maxWeight = Tuple3(
            weightResponse[0]['title'] as String,
            DateTime.parse(weightResponse[0]['date'] as String),
            "$val ${weightResponse[0]['weightPost']}",
          );
        }
      }
      var timeResponse = await db.rawQuery("""
        SELECT
          el.title AS title,
          el.created AS date,
          MAX(elm.time) AS max_val
        FROM exercise_log_meta elm
        JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
        JOIN exercise e ON el.exerciseId = e.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        GROUP BY el.exerciseLogId, el.title, el.created
        ORDER BY max_val DESC
        LIMIT 1;
      """);
      if (timeResponse.isNotEmpty) {
        var val = timeResponse[0]['max_val'] as num;
        if (val > 0) {
          _maxTime = Tuple3(
            timeResponse[0]['title'] as String,
            DateTime.parse(timeResponse[0]['date'] as String),
            formatHHMMSS(val as int),
          );
        }
      }
      var repsResponse = await db.rawQuery("""
        SELECT
          el.title AS title,
          el.created AS date,
          MAX(elm.reps) AS max_val
        FROM exercise_log_meta elm
        JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
        JOIN exercise e ON el.exerciseId = e.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        GROUP BY el.exerciseLogId, el.title, el.created
        ORDER BY max_val DESC
        LIMIT 1;
      """);
      if (repsResponse.isNotEmpty) {
        var val = repsResponse[0]['max_val'] as num;
        if (val > 0) {
          _maxReps = Tuple3(
            repsResponse[0]['title'] as String,
            DateTime.parse(repsResponse[0]['date'] as String),
            "x${repsResponse[0]['max_val']}",
          );
        }
      }

      var setsResponse = await db.rawQuery("""
        SELECT
          el.title AS title,
          el.created AS date,
          MAX(sets_count) AS max_val
          FROM (
            SELECT el.exerciseLogId, COUNT(elm.exerciseLogMetaId) AS sets_count
            FROM exercise_log_meta elm
            JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
            JOIN exercise e ON el.exerciseId = e.exerciseId
            WHERE e.category = '${widget.category.categoryId}'
            GROUP BY el.exerciseLogId
          ) AS sets_summary
          JOIN exercise_log el ON sets_summary.exerciseLogId = el.exerciseLogId
          ORDER BY max_val DESC, el.created DESC
          LIMIT 1;
      """);
      if (setsResponse.isNotEmpty) {
        var val = setsResponse[0]['max_val'] as num;
        if (val > 0) {
          _maxSets = Tuple3(
            setsResponse[0]['title'] as String,
            DateTime.parse(setsResponse[0]['date'] as String),
            "${setsResponse[0]['max_val']} Sets",
          );
        }
      }

      var exerciseDistResponse = await db.rawQuery("""
        SELECT
          e.title,
          e.exerciseId,
          COUNT(el.exerciseLogId) AS number_of_logs
        FROM exercise e
        LEFT JOIN exercise_log el ON e.exerciseId = el.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        GROUP BY e.exerciseId
        HAVING number_of_logs > 0
        ORDER BY number_of_logs DESC
      """);
      for (var i in exerciseDistResponse) {
        _exerciseDist.add(
          Tuple2(i['title'] as String, i['number_of_logs'] as int),
        );
      }

      var tagDistResponse = await db.rawQuery("""
        SELECT
          t.title,
          t.tagId,
          COUNT(elmt.exerciseLogMetaTagId) AS number_of_tags
        FROM tag t
        JOIN exercise_log_meta_tag elmt ON t.tagId = elmt.tagId
        JOIN exercise_log_meta elm ON elmt.exerciseLogMetaId = elm.exerciseLogMetaId
        JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
        JOIN exercise e ON el.exerciseId = e.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        GROUP BY t.tagId
        ORDER BY number_of_tags DESC
      """);
      for (var i in tagDistResponse) {
        _tagDist.add(
          Tuple2(i['title'] as String, i['number_of_tags'] as int),
        );
      }

      var recentResponse = await db.rawQuery("""
        SELECT 
          el.title,
          el.exerciseId,
          el.created AS date
        FROM exercise_log el
        JOIN exercise e ON el.exerciseId = e.exerciseId
        WHERE e.category = '${widget.category.categoryId}'
        ORDER BY el.created DESC
        LIMIT 10;
      """);
      for (var i in recentResponse) {
        _recentlyLogged.add(
          Tuple3(
            i['exerciseId'] as String,
            i['title'] as String,
            DateTime.parse(i['date'] as String),
          ),
        );
      }
    } catch (e) {
      print(e); // TODO
      _hasError = true;
    }
    setState(() {
      _isLoading = false;
    });
  }
}

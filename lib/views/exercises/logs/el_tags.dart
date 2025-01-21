import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

import 'package:workout_notepad_v2/logger.dart';

class ELTags extends StatefulWidget {
  const ELTags({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ELTags> createState() => _ELTagsState();
}

class _ELTagsState extends State<ELTags> {
  bool _isLoading = false;
  bool _hasError = false;
  final List<Tuple2<String, int>> _tagData = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingIndicator(
        color: Theme.of(context).colorScheme.primary,
      );
    } else if (_hasError) {
      return const Text("ERROR"); // TODO
    } else if (_tagData.isEmpty) {
      return Text("No data"); // TODO
    } else {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tag distribution",
                  style: ttLabel(context, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        for (var i in _tagData)
                          PieChartSectionData(
                            value: i.v2.toDouble(),
                            color: ColorUtil.random(i.v1),
                            radius: 100,
                            title: "${i.v2}\n${i.v1}",
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // if (!dmodel.hasValidSubscription()) const ELPremiumOverlay(),
        ],
      );
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var db = await DatabaseProvider().database;
      var response = await db.rawQuery("""
        SELECT 
          t.tagId,
          t.title AS tag_title,
          COUNT(elmt.exerciseLogMetaId) AS number_of_sets
        FROM tag AS t
        LEFT JOIN exercise_log_meta_tag AS elmt
        ON t.tagId = elmt.tagId
        JOIN exercise_log_meta AS elm
        ON elmt.exerciseLogMetaId = elm.exerciseLogMetaId
        JOIN exercise_log AS el
        ON elm.exerciseLogId = el.exerciseLogId
        WHERE el.exerciseId = '${widget.exercise.exerciseId}'
        GROUP BY t.tagId
        ORDER BY number_of_sets DESC;
      """);
      for (var i in response) {
        _tagData.add(
          Tuple2(i['tag_title'] as String, i['number_of_sets'] as int),
        );
      }
    } catch (e, stack) {
      logger.exception(e, stack);
      _hasError = true;
    }
    setState(() {
      _isLoading = false;
    });
  }
}

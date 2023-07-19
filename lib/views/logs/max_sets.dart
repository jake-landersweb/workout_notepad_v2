import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsMaxSets extends StatefulWidget {
  const LogsMaxSets({super.key});

  @override
  State<LogsMaxSets> createState() => _LogsMaxSetsState();
}

class _LogsMaxSetsState extends State<LogsMaxSets> {
  bool _isLoading = true;
  final List<Tuple2<Exercise, int>> _maxWeight = [];
  final List<Tuple2<Exercise, int>> _maxTime = [];
  final List<Tuple2<Exercise, int>> _maxReps = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: "Max Sets",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          if (_maxWeight.isNotEmpty)
            Section(
              "Weight",
              child: ContainedList<Tuple2<Exercise, int>>(
                children: _maxWeight,
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                childBuilder: (context, item, index) => _cell(
                  context,
                  item.v1,
                  "${item.v2} lbs",
                ),
              ),
            ),
          if (_maxTime.isNotEmpty)
            Section(
              "Timed",
              child: ContainedList<Tuple2<Exercise, int>>(
                children: _maxTime,
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                childBuilder: (context, item, index) => _cell(
                  context,
                  item.v1,
                  formatHHMMSS(item.v2),
                ),
              ),
            ),
          if (_maxWeight.isNotEmpty)
            Section(
              "Reps",
              child: ContainedList<Tuple2<Exercise, int>>(
                children: _maxReps,
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                childBuilder: (context, item, index) => _cell(
                  context,
                  item.v1,
                  "x ${item.v2}",
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, Exercise exercise, String val) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDateTime(DateTime.parse(exercise.created)),
                style: ttcaption(context),
              ),
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
        Text(val, style: ttTitle(context)),
      ],
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    var db = await getDB();
    var maxWeightResponse = await db.rawQuery("""
      SELECT 
        *,
        MAX(CASE WHEN elm.weightPost = "kg" THEN elm.weight * 2.204 ELSE elm.weight END) AS max_weight
      FROM exercise e
      JOIN exercise_log_meta elm
        ON e.exerciseId = elm.exerciseId
      GROUP BY e.exerciseId
      ORDER BY max_weight DESC
      LIMIT 3;
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
      LIMIT 3;
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
      LIMIT 3;
    """);
    for (var i in maxWeightResponse) {
      _maxWeight.add(Tuple2(Exercise.fromJson(i), i['max_weight'] as int));
    }
    for (var i in maxTimeResponse) {
      _maxTime.add(Tuple2(Exercise.fromJson(i), i['max_time'] as int));
    }
    for (var i in maxRepsResponse) {
      _maxReps.add(Tuple2(Exercise.fromJson(i), i['max_reps'] as int));
    }
    setState(() {
      _isLoading = false;
    });
  }
}

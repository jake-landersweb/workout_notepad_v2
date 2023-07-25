import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'package:workout_notepad_v2/views/root.dart';

class LogsMaxSets extends StatefulWidget {
  const LogsMaxSets({super.key});

  @override
  State<LogsMaxSets> createState() => _LogsMaxSetsState();
}

class _LogsMaxSetsState extends State<LogsMaxSets> {
  bool _isLoading = true;
  List<Tuple3<Category, Exercise, String>> _items = [];
  String _type = "Weight";

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
          const SizedBox(height: 16),
          if (_items.isNotEmpty)
            Column(
              children: [
                SegmentedPicker(
                  titles: ["Weight", "Time", "Reps"],
                  style: SegmentedPickerStyle(
                    backgroundColor: AppColors.cell(context),
                  ),
                  onSelection: (v) async {
                    setState(() {
                      _type = v as String;
                    });
                    await _fetchData();
                  },
                  selection: _type,
                ),
                for (var i in _items)
                  Section(
                    i.v1.title,
                    child: _cell(
                      context,
                      i.v1,
                      i.v2,
                      i.v3,
                    ),
                  ),
              ],
            )
          else
            const NoLogs(),
        ],
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    Category c,
    Exercise exercise,
    String val,
  ) {
    return Clickable(
      onTap: () {
        cupertinoSheet(
          context: context,
          builder: (context) => ExerciseLogs(
            exerciseId: exercise.exerciseId,
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
              getImageIcon(c.icon),
              const SizedBox(width: 8),
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
                  ],
                ),
              ),
              Text(val, style: ttBody(context, fontWeight: FontWeight.w700)),
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
    _items = [];
    var db = await getDB();
    var response = await db.rawQuery(query);
    var dmodel = context.read<DataModel>();
    for (var i in response) {
      // check category
      var c = dmodel.categories.firstWhereOrNull(
        (element) => element.categoryId == i['category'] as String,
      );
      if (c != null) {
        switch (_type) {
          case "Weight":
            _items.add(Tuple3(c, Exercise.fromJson(i), "${i['max']} lbs"));
            break;
          case "Time":
            _items.add(
                Tuple3(c, Exercise.fromJson(i), formatHHMMSS(i['max'] as int)));
            break;
          case "Reps":
            _items.add(Tuple3(c, Exercise.fromJson(i), "x ${i['max']}"));
            break;
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  String get query {
    switch (_type) {
      case "Weight":
        return """
        WITH weight_in_pounds AS (
          SELECT
            e.exerciseId,
            e.category,
            el.created AS log_created,
            CASE
              WHEN elm.weightPost = 'kg' THEN elm.weight * 2.204
              ELSE elm.weight
            END AS weight
          FROM exercise_log_meta elm
          JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
          JOIN exercise e ON el.exerciseId = e.exerciseId
          WHERE elm.weight > 0
        ),
        max_weight AS (
          SELECT
            exerciseId,
            category,
            MAX(weight) AS max_weight,
            log_created AS max_log_created
          FROM weight_in_pounds
          GROUP BY exerciseId, category
        ),
        ranked_exercises AS (
          SELECT 
            mw.exerciseId,
            mw.category,
            mw.max_weight,
            mw.max_log_created,
            ROW_NUMBER() OVER(PARTITION BY mw.category ORDER BY mw.max_weight DESC, mw.max_log_created DESC) as rn
          FROM max_weight mw
        )
        SELECT 
          re.category,
          re.max_weight AS max,
          re.max_log_created AS created,
          e.exerciseId,
          e.title,
          e.description,
          e.icon,
          e.type,
          e.sets,
          e.reps,
          e.time,
          e.updated
        FROM ranked_exercises re
        JOIN exercise e ON re.exerciseId = e.exerciseId
        WHERE rn = 1;
        """;
      case "Time":
        return """
          WITH max_time AS (
            SELECT
              e.exerciseId,
              e.category,
              MAX(elm.time) AS max_time,
              el.created AS max_log_created
            FROM exercise_log_meta elm
            JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
            JOIN exercise e ON el.exerciseId = e.exerciseId
            WHERE elm.time > 0
            GROUP BY e.exerciseId, e.category
          ),
          ranked_exercises AS (
            SELECT 
              mt.exerciseId,
              mt.category,
              mt.max_time,
              mt.max_log_created,
              ROW_NUMBER() OVER(PARTITION BY mt.category ORDER BY mt.max_time DESC) as rn
            FROM max_time mt
          )
          SELECT 
            re.category,
            re.max_time AS max,
            e.title,
            e.exerciseId,
            e.description,
            e.icon,
            e.type,
            e.sets,
            e.reps,
            e.time,
            re.max_log_created AS created,
            e.updated
          FROM ranked_exercises re
          JOIN exercise e ON re.exerciseId = e.exerciseId
          WHERE rn = 1;
        """;
      case "Reps":
        return """
          WITH max_reps AS (
            SELECT
              e.exerciseId,
              e.category,
              MAX(elm.reps) AS max_reps,
              el.created AS max_log_created
            FROM exercise_log_meta elm
            JOIN exercise_log el ON elm.exerciseLogId = el.exerciseLogId
            JOIN exercise e ON el.exerciseId = e.exerciseId
            WHERE elm.reps > 0
            GROUP BY e.exerciseId, e.category
          ),
          ranked_exercises AS (
            SELECT 
              mr.exerciseId,
              mr.category,
              mr.max_reps,
              mr.max_log_created,
              ROW_NUMBER() OVER(PARTITION BY mr.category ORDER BY mr.max_reps DESC) as rn
            FROM max_reps mr
          )
          SELECT 
            re.category,
            re.max_reps AS max,
            e.title,
            e.exerciseId,
            e.description,
            e.icon,
            e.type,
            e.sets,
            e.reps,
            e.time,
            re.max_log_created AS created,
            e.updated
          FROM ranked_exercises re
          JOIN exercise e ON re.exerciseId = e.exerciseId
          WHERE rn = 1;
        """;
      default:
        throw "Invalid type";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'package:workout_notepad_v2/views/root.dart';

class RecentExercises extends StatefulWidget {
  const RecentExercises({super.key});

  @override
  State<RecentExercises> createState() => _RecentExercisesState();
}

class _RecentExercisesState extends State<RecentExercises> {
  List<ExerciseLog> _logs = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBar(
        title: "Recently Logged",
        isLarge: true,
        leading: const [BackButton2()],
        children: [
          const SizedBox(height: 16),
          if (!_loaded)
            const Center(child: LoadingIndicator())
          else if (_logs.isEmpty)
            const NoLogs()
          else
            for (var i in _logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Clickable(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) =>
                          ExerciseLogs(exerciseId: i.exerciseId),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cell(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                          child: Text(i.title, style: ttLabel(context)),
                        ),
                        ELCell(log: i),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _init() async {
    try {
      var db = await DatabaseProvider().database;
      var response = await db.rawQuery(
          "SELECT * FROM exercise_log ORDER BY created DESC LIMIT 20");
      for (var i in response) {
        _logs.add(await ExerciseLog.fromJson(i));
      }
      setState(() {});
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "logs_recent_exercises"},
      );
      if (mounted) {
        snackbarErr(context, "There was an issue querying your data");
      }
    }
    setState(() {
      _loaded = true;
    });
  }
}

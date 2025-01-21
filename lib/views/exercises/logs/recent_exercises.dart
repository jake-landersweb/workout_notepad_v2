import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/logger.dart';

class RecentExercises extends StatefulWidget {
  const RecentExercises({super.key});

  @override
  State<RecentExercises> createState() => _RecentExercisesState();
}

class _RecentExercisesState extends State<RecentExercises> {
  List<Exercise> _logs = [];
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
              Clickable(
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => ExerciseDetail(
                      exercise: i,
                    ),
                  );
                },
                child: ExerciseCell(exercise: i),
              ),
        ],
      ),
    );
  }

  Future<void> _init() async {
    try {
      var db = await DatabaseProvider().database;
      var response = await db.rawQuery("""
            SELECT e.* FROM exercise_log el
            JOIN exercise e ON el.exerciseId = e.exerciseId
            ORDER BY el.created DESC LIMIT 20
          """);
      for (var i in response) {
        _logs.add(Exercise.fromJson(i));
      }
      setState(() {});
    } catch (e, stack) {
      logger.exception(e, stack);
      if (mounted) {
        snackbarErr(context, "There was an issue querying your data");
      }
    }
    setState(() {
      _loaded = true;
    });
  }
}

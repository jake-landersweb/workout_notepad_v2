import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';

class WLExercises extends StatefulWidget {
  const WLExercises({
    super.key,
    this.workoutLog,
    this.workoutLogId,
  });
  final WorkoutLog? workoutLog;
  final String? workoutLogId;

  @override
  State<WLExercises> createState() => _WLExercisesState();
}

class _WLExercisesState extends State<WLExercises> {
  WorkoutLog? _workoutLog;

  @override
  void initState() {
    assert(widget.workoutLog != null || widget.workoutLogId != null,
        "Both cannot be null");
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Exercise Logs",
      leading: const [comp.CloseButton2()],
      children: [
        const SizedBox(height: 16),
        if (_workoutLog != null)
          for (var i = 0; i < _workoutLog!.exerciseLogs.length; i++)
            if (_workoutLog!.exerciseLogs[i].isSuperSet)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 0, 16),
                child: Section(
                  "- ${_workoutLog!.exerciseLogs[i].title}",
                  child: ELCell(
                    log: _workoutLog!.exerciseLogs[i],
                    showDate: false,
                  ),
                ),
              )
            else
              Section(
                _workoutLog!.exerciseLogs[i].title,
                child: ELCell(
                  log: _workoutLog!.exerciseLogs[i],
                  showDate: false,
                ),
              ),
      ],
    );
  }

  Future<void> _init() async {
    late WorkoutLog wl;
    if (widget.workoutLog == null) {
      var db = await getDB();
      var response = await db.rawQuery(
          "SELECT * FROM workout_log WHERE workoutLogId = '${widget.workoutLogId}'");
      wl = await WorkoutLog.fromJson(response[0]);
    } else {
      wl = widget.workoutLog!;
    }
    setState(() {
      _workoutLog = wl;
    });
  }
}

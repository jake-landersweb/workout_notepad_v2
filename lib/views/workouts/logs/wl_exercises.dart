import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/section.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
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
  List<Tuple2<ExerciseLog, List<ExerciseLog>>> _exerciseLogs = [];

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
          for (var i in _exerciseLogs)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Section(
                i.v1.title,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cell(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ELCell(
                        log: i.v1,
                        showDate: false,
                      ),
                      if (i.v2.isNotEmpty)
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      height: 0.5,
                                      color: AppColors.divider(context),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      "SUPER-SET",
                                      style: ttBody(
                                        context,
                                        color: AppColors.subtext(context),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      height: 0.5,
                                      color: AppColors.divider(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (var j in i.v2)
                              Section(
                                j.title,
                                child: ELCell(log: j, showDate: false),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
        // for (var i = 0; i < _workoutLog!.exerciseLogs.length; i++)
        //   if (_workoutLog!.exerciseLogs[i].isSuperSet)
        //     Padding(
        //       padding: const EdgeInsets.fromLTRB(32, 0, 0, 16),
        //       child: Section(
        //         "- ${_workoutLog!.exerciseLogs[i].title}",
        //         child: ELCell(
        //           log: _workoutLog!.exerciseLogs[i],
        //           showDate: false,
        //         ),
        //       ),
        //     )
        //   else
        //     Section(
        //       _workoutLog!.exerciseLogs[i].title,
        //       child: ELCell(
        //         log: _workoutLog!.exerciseLogs[i],
        //         showDate: false,
        //       ),
        //     ),
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

    // render exercise logs as parent exercise with exercise super set children
    // loop in reverse order to get children then the parent
    List<ExerciseLog> children = [];
    for (var i in wl.exerciseLogs.reversed) {
      if (i.isSuperSet) {
        children.add(i);
      } else {
        _exerciseLogs.add(Tuple2(i, children));
        children = [];
      }
    }

    setState(() {
      _workoutLog = wl;
      _exerciseLogs = _exerciseLogs.reversed.toList();
    });
  }
}

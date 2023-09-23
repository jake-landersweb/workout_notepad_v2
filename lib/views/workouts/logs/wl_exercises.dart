import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/edit_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/section.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_edit.dart';

class WLExercises extends StatefulWidget {
  const WLExercises({
    super.key,
    this.workoutLog,
    this.workoutLogId,
    required this.onSave,
  });
  final WorkoutLog? workoutLog;
  final String? workoutLogId;
  final void Function(WorkoutLog wl) onSave;

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
      trailing: [
        if (_workoutLog != null)
          EditButton(onTap: () {
            cupertinoSheet(
              context: context,
              builder: (context) => WLEdit(
                wl: _workoutLog!,
                onSave: (wl) {
                  widget.onSave(wl);
                  Navigator.of(context).pop();
                },
              ),
            );
          })
      ],
      children: [
        const SizedBox(height: 16),
        if (_workoutLog != null) _body(context, _workoutLog!),
      ],
    );
  }

  Widget _body(BuildContext context, WorkoutLog wl) {
    return Column(
      children: [
        for (var i in wl.exerciseLogs)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cell(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  for (var j in i)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Section(
                        j.title,
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
                                log: j,
                                showDate: false,
                                backgroundColor: AppColors.cell(context)[50],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _init() async {
    late WorkoutLog wl;
    if (widget.workoutLog == null) {
      var db = await DatabaseProvider().database;
      var response = await db.rawQuery(
          "SELECT * FROM workout_log WHERE workoutLogId = '${widget.workoutLogId}'");
      wl = await WorkoutLog.fromJson(response[0]);
    } else {
      wl = widget.workoutLog!;
      wl.exerciseLogs = await wl.getExercises() ?? [];
    }

    setState(() {
      _workoutLog = wl;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/close_button.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/logs/no_logs.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_model.dart';

class WorkoutLogs extends StatefulWidget {
  const WorkoutLogs({
    super.key,
    required this.workout,
    this.onSelect,
    this.closeOnSelect = true,
  });
  final Workout workout;
  final Function(WorkoutLog log)? onSelect;
  final bool closeOnSelect;

  @override
  State<WorkoutLogs> createState() => _WorkoutLogsState();
}

class _WorkoutLogsState extends State<WorkoutLogs> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => WorkoutLogModel(workout: widget.workout),
      builder: (context, child) => _body(context, dmodel),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    var lmodel = Provider.of<WorkoutLogModel>(context);
    return HeaderBar.sheet(
      title: "Workout Logs",
      leading: const [CloseButton2()],
      children: [
        const SizedBox(height: 8),
        Text(widget.workout.title, style: ttTitle(context, size: 24)),
        const SizedBox(height: 8),
        if (!lmodel.loaded)
          const Center(child: LoadingIndicator())
        else if (lmodel.logs.isEmpty)
          const NoLogs()
        else
          for (var i in lmodel.logs)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: WorkoutLogCell(
                workoutLog: i,
                onSelect: widget.onSelect == null
                    ? null
                    : () {
                        widget.onSelect!(i);
                        if (widget.closeOnSelect) {
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      },
              ),
            ),
      ],
    );
  }
}

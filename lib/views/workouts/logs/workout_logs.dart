import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/fluid_scroll_view.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/logs/root.dart';
import 'package:workout_notepad_v2/views/workouts/logs/wl_model.dart';

class WorkoutLogs extends StatefulWidget {
  const WorkoutLogs({
    super.key,
    required this.workout,
  });
  final Workout workout;

  @override
  State<WorkoutLogs> createState() => _WorkoutLogsState();
}

class _WorkoutLogsState extends State<WorkoutLogs> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => WorkoutLogModel(workout: widget.workout),
      builder: (context, child) {
        return Navigator(
          onGenerateRoute: (settings) {
            return MaterialWithModalsPageRoute(
              settings: settings,
              builder: (context) => _body(context, dmodel),
            );
          },
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    var lmodel = Provider.of<WorkoutLogModel>(context);
    return comp.InteractiveSheet(
      header: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const comp.CloseButton2(useRoot: true),
              Text(
                widget.workout.title,
                style: ttTitle(
                  context,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              if (widget.workout.description?.isNotEmpty ?? false)
                Text(
                  widget.workout.description!,
                  style: ttLabel(
                    context,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
            ],
          ),
        );
      },
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FluidScrollView(
            children: [
              const SizedBox(height: 0),
              for (var i in lmodel.logs) WorkoutLogCell(workoutLog: i),
            ],
          ),
        );
      },
    );
  }
}

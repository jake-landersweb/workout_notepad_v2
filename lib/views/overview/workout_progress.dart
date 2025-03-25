import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/graph_circle.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/workouts/launch/launch_workout.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_time.dart';

class WorkoutProgress extends StatefulWidget {
  const WorkoutProgress({super.key});

  @override
  State<WorkoutProgress> createState() => _WorkoutProgressState();
}

class _WorkoutProgressState extends State<WorkoutProgress> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Clickable(
      onTap: () {
        showMaterialModalBottomSheet(
            context: context,
            enableDrag: true,
            builder: (context) {
              if (dmodel.workoutState == null) {
                return Container();
              } else {
                return LaunchWorkout(state: dmodel.workoutState!);
              }
            });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        height: 90,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Workout Progress",
                      style: ttLargeLabel(context, color: Colors.white),
                    ),
                    Row(
                      children: [
                        LWTime(
                          start: dmodel.workoutState!.startTime,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (dmodel.workoutState != null) const WorkoutProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// Need to use this stupid timer system to rebuild the widget because the state cannot be sourced from here

class WorkoutProgressIndicator extends StatefulWidget {
  const WorkoutProgressIndicator({
    super.key,
    this.size = 50,
    this.fontSize = 14,
  });
  final double size;
  final double fontSize;

  @override
  State<WorkoutProgressIndicator> createState() =>
      _WorkoutProgressIndicatorState();
}

class _WorkoutProgressIndicatorState extends State<WorkoutProgressIndicator> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling(); // Start the periodic rebuild
  }

  void _startPolling() {
    // Timer that triggers a rebuild every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return GraphCircle(
      size: widget.size,
      fontSize: widget.fontSize,
      value: dmodel.workoutState!.getPercentageComplete(),
      textColor: Colors.white,
      foregroundColor: _getColor(dmodel.workoutState!.getPercentageComplete()),
      backgroundColor: Colors.white.withOpacity(0.2),
    );
  }

  Color _getColor(double progress) {
    if (progress < 0.5) {
      return Colors.red.shade300;
    }
    if (progress < 0.75) {
      return Colors.amber.shade300;
    }
    return Colors.teal.shade300;
  }
}

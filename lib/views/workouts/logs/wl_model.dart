import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';

class WorkoutLogModel extends ChangeNotifier {
  final Workout workout;

  List<WorkoutLog> logs = [];

  WorkoutLogModel({required this.workout}) {
    _init();
  }

  Future<void> _init() async {
    logs = await workout.getLogs();
  }
}

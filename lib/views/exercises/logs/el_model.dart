import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

class ELModel extends ChangeNotifier {
  late Exercise exercise;
  List<ExerciseLog> logs = [];

  ELModel({
    required this.exercise,
  }) {
    init();
  }

  Future<void> init() async {
    logs = await exercise.getLogs(exercise.exerciseId);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

class CreateExerciseModel extends ChangeNotifier {
  late Exercise exercise;

  CreateExerciseModel.create(DataModel dmodel, String uid) {
    exercise = Exercise.empty(uid);
  }

  CreateExerciseModel.update(DataModel dmodel, Exercise exercise) {
    this.exercise = exercise.copy();
  }

  bool isValid() {
    if (exercise.title.isEmpty) {
      return false;
    }
    return true;
  }

  Future<Exercise?> post(DataModel dmodel, bool update) async {
    if (!isValid()) {
      return null;
    }
    int response;
    if (update) {
      response = await exercise.update();
    } else {
      response = await exercise.insert();
    }
    if (response == 0) {
      return null;
    }
    return exercise;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_detail.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CreateExerciseModel extends ChangeNotifier {
  late Exercise exercise;
  late ExerciseDetails exerciseDetail;
  File? image;
  File? video;

  CreateExerciseModel.create(DataModel dmodel, String uid) {
    exercise = Exercise.empty(uid);
    exerciseDetail = ExerciseDetails.init(exerciseId: exercise.exerciseId);
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
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "exercise_update",
        eventAttributes: {
          "exerciseId": exercise.exerciseId,
          "title": exercise.title,
        },
      );
    } else {
      response = await exercise.insert();
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "exercise_create",
        eventAttributes: {
          "exerciseId": exercise.exerciseId,
          "title": exercise.title,
        },
      );
    }
    if (response == 0) {
      return null;
    }
    return exercise;
  }
}

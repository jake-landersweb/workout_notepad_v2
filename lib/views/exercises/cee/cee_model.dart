import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

class CreateExerciseModel extends ChangeNotifier {
  late Exercise exercise;
  late List<String> categories;

  CreateExerciseModel.create(DataModel dmodel, String uid) {
    exercise = Exercise.empty(uid);
    categories = List.of(dmodel.categories.map((e) => e.title).toList());
  }

  CreateExerciseModel.update(DataModel dmodel, Exercise exercise) {
    this.exercise = exercise.copy();
    categories = List.of(dmodel.categories.map((e) => e.title).toList());
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
    bool response;
    if (update) {
      response = await exercise.update();
    } else {
      response = await exercise.insert();
    }
    if (!response) {
      return null;
    }
    if (exercise.category.isNotEmpty &&
        !dmodel.categories.map((e) => e.title).contains(exercise.category)) {
      // insert category
      var c = Category(
          title: exercise.category.toLowerCase(), userId: dmodel.user!.userId);
      await c.insert();
      await dmodel.refreshCategories();
    }
    return exercise;
  }
}

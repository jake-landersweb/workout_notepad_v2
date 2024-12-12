import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum CEWType { create, update }

class CEWModel extends ChangeNotifier {
  late Workout workout;
  late CEWType type;

  CEWModel.create() {
    workout = Workout.init();
    type = CEWType.create;
  }

  CEWModel.update(Workout workout) {
    this.workout = workout.copy();
    type = CEWType.update;
  }

  void setTitle(String val) {
    workout.title = val;
    notifyListeners();
  }

  void setDescription(String val) {
    workout.description = val;
    notifyListeners();
  }

  void reorder(List<List<Exercise>> exercises) {
    workout.setExercises(exercises); // TODO -- may cause a bug
    notifyListeners();
  }

  // adds an exercise to the workout at the specified index
  // if an exercise already exists, it will add to the super-set list
  void addExercise(int i, Exercise e) {
    workout.addExercise(i, e);
    notifyListeners();
  }

  void refreshExercises(int i, List<Exercise> exercises) {
    workout.setSuperSets(i, exercises);
    notifyListeners();
  }

  void removeExercise(int i) {
    workout.removeExercise(i);
    notifyListeners();
  }

  void removeSubExercise(int i, int j) {
    workout.removeSuperSet(i, j);
    notifyListeners();
  }

  Tuple2<String, bool> isValid() {
    if (workout.title.isEmpty) {
      return Tuple2("The title cannot be empty", false);
    }
    if (workout.getExercises().isEmpty) {
      return Tuple2("Add at least 1 exercise", false);
    }
    if (workout
        .getExercises()
        .any((element) => element.any((element2) => element2.sets == 0))) {
      return Tuple2("No exercises can have 0 sets", false);
    }
    return Tuple2("", true);
  }

  Future<bool> action() async {
    return workout.handleInsert();
  }
}

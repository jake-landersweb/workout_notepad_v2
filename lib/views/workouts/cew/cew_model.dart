import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWModel extends ChangeNotifier {
  CEWModel.create() {
    title = "";
    description = "";
    icon = "";
    _exercises = [];
  }
  CEWModel.update(Workout w) {
    // TODO: Implement
    throw "unimplemented";
  }

  late String title;
  late String description;
  late String icon;
  late List<CEWExercise> _exercises;

  List<CEWExercise> get exercises => _exercises;

  void addExercise(Exercise e) {
    _exercises.add(CEWExercise.init(e));
    notifyListeners();
  }

  void insertExercise(int index, Exercise e) {
    _exercises.insert(index, CEWExercise.init(e));
    notifyListeners();
  }

  void addExerciseChild(int index, Exercise e) {
    var cewe = _exercises.elementAt(index);
    cewe.children.add(e);
    notifyListeners();
  }

  void insertExerciseChild(int index, Exercise e, int childIndex) {
    var cewe = _exercises.elementAt(index);
    cewe.children.insert(childIndex, e);
    notifyListeners();
  }

  void removeExerciseChild(int index, Exercise e) {
    var cewe = _exercises.elementAt(index);
    cewe.children.removeWhere((element) => element.exerciseId == e.exerciseId);
    notifyListeners();
  }
}

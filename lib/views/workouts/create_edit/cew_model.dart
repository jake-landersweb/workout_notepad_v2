import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum CEWType { create, update }

class CEWModel extends ChangeNotifier {
  late Workout workout;
  late CEWType type;

  CEWModel.create() {
    workout = Workout.init();
    workout.exercises = [];
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

  void reorder(List<List<WorkoutExercise>> exericses) {
    workout.exercises = exericses;
    notifyListeners();
  }

  // adds an exercise to the workout at the specified index
  // if an exercise already exists, it will add to the super-set list
  void addExercise(int i, Exercise e) {
    var we = WorkoutExercise.fromExercise(workout, e);
    while (workout.exercises.length <= i) {
      workout.exercises.add([]);
    }
    // set superset id if need to
    if (workout.exercises[i].isNotEmpty) {
      we.supersetId = workout.exercises[i][0].supersetId;
    }
    workout.exercises[i].add(we);
    notifyListeners();
  }

  void refreshExercises(int i, List<WorkoutExercise> exercises) {
    workout.exercises[i] = exercises;
    notifyListeners();
  }

  void removeExercise(int i) {
    workout.exercises.removeAt(i);
    notifyListeners();
  }

  void removeSubExercise(int i, int j) {
    workout.exercises[i].removeAt(j);
    if (workout.exercises[i].isEmpty) {
      workout.exercises.removeAt(i);
    }
    notifyListeners();
  }

  Tuple2<String, bool> isValid() {
    if (workout.title.isEmpty) {
      return Tuple2("The title cannot be empty", false);
    }
    if (workout.exercises.isEmpty) {
      return Tuple2("Add at least 1 exercise", false);
    }
    if (workout.exercises
        .any((element) => element.any((element2) => element2.sets == 0))) {
      return Tuple2("No exercises can have 0 sets", false);
    }
    return Tuple2("", true);
  }

  Future<bool> action() async {
    try {
      var db = await DatabaseProvider().database;

      bool response = await db.transaction((txn) async {
        // when updating, remove all existing exercises
        await txn.delete(
          "workout_exercise",
          where: "workoutId = ?",
          whereArgs: [workout.workoutId],
        );

        // loop through all exercises and group and add as supersets
        var uuid = const Uuid();
        for (int i = 0; i < workout.exercises.length; i++) {
          var supersetId = uuid.v4();
          for (int j = 0; j < workout.exercises[i].length; j++) {
            // configure the exercise fields
            workout.exercises[i][j].exerciseOrder = i;
            workout.exercises[i][j].supersetId = supersetId;
            workout.exercises[i][j].supersetOrder = j;
            var r = await txn.insert(
                "workout_exercise", workout.exercises[i][j].toMap());
            if (r == 0) {
              return false;
            }
          }
        }

        // add or update the workout
        var r = await txn.insert(
          "workout",
          workout.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (r == 0) {
          return false;
        }

        return true;
      });

      if (!response) {
        throw "There was an issue completing the transaction";
      }

      return true;
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(e, StackTrace.current);
      return false;
    }
  }
}

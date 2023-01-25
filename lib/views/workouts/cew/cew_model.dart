import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class CEWModel extends ChangeNotifier {
  CEWModel.create(DataModel dmodel) {
    title = "";
    description = "";
    icon = "";
    _exercises = [];

    for (var i = 0; i < 3; i++) {
      _exercises.add(CEWExercise.init(dmodel.exercises[i].copy()));
    }
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

  void updateExercise(int index, CEWExercise e) {
    _exercises[index] = e;
    notifyListeners();
  }

  void updateSuperSetExercise(int index, Exercise e) {
    _exercises[index].exercise = e;
    notifyListeners();
  }

  void insertExerciseChild(int index, Exercise e, int childIndex) {
    var cewe = _exercises.elementAt(index);
    cewe.children.insert(childIndex, e);
    notifyListeners();
  }

  void removeExercise(int index) {
    exercises.removeAt(index);
    notifyListeners();
  }

  void removeExerciseChild(int index, Exercise e) {
    var cewe = _exercises.elementAt(index);
    cewe.children.removeWhere((element) => element.exerciseId == e.exerciseId);
    notifyListeners();
  }

  bool isValid() {
    if (title.isEmpty) {
      return false;
    }
    if (_exercises.isEmpty) {
      return false;
    }
    return true;
  }

  Future<Workout?> createWorkout(DataModel dmodel) async {
    // create the workout
    Workout w = Workout.init(dmodel.user!.userId);
    w.title = title;
    w.description = description;
    w.icon = icon;

    // create the workout exercises
    var workoutExercises = <WorkoutExercise>[];

    // compose the exercise super sets
    var exerciseSets = <ExerciseSet>[];

    // create the exercise sets from the exercise list
    for (int i = 0; i < _exercises.length; i++) {
      // create the workout exercise
      var we = WorkoutExercise.init(
        w,
        _exercises[i].exercise,
        ExerciseChildArgs(
          order: i,
          sets: _exercises[i].exercise.sets,
          reps: _exercises[i].exercise.reps,
          time: _exercises[i].exercise.time,
          timePost: _exercises[i].exercise.timePost,
        ),
      );

      workoutExercises.add(we);

      // loop through children and create exercise sets
      for (int j = 0; j < _exercises[i].children.length; j++) {
        // create an exercise set with new args
        var es = ExerciseSet.init(
          w,
          _exercises[i].exercise,
          _exercises[i].children[j],
          ExerciseChildArgs(
            order: j,
            sets: _exercises[i].children[j].sets,
            reps: _exercises[i].children[j].reps,
            time: _exercises[i].children[j].time,
            timePost: _exercises[i].children[j].timePost,
          ),
        );
        exerciseSets.add(es);
      }
    }

    var db = await getDB();
    // start a transaction
    try {
      await db.transaction((txn) async {
        int r = await txn.insert('workout', w.toMap());
        if (r == 0) {
          throw Exception("There was an issue inserting the workout");
        }

        // EXERCISE IS ALREADY INSERTED

        // add workout exercises
        for (var i in workoutExercises) {
          r = await txn.insert('workout_exercise', i.toMap());
          if (r == 0) {
            throw Exception("There was an issue inserting a workout exercise");
          }
        }

        // add exercise super sets
        for (var i in exerciseSets) {
          // add all exercise super sets
          r = await txn.insert('exercise_set', i.toMap());
          if (r == 0) {
            throw Exception("There was an issue inserting an exercise set");
          }
        }
      });
      // update the data
      await dmodel.refreshWorkouts();
      return w;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWModel extends ChangeNotifier {
  CEWModel.create(String uid) {
    workout = Workout.init();
    title = "";
    description = "";
    icon = "";
    _exercises = [];
    _showExerciseButton();
  }
  CEWModel.update(Workout w) {
    // create the exercise structure
    workout = w.copy();
    title = w.title;
    description = w.description ?? "";
    icon = w.icon;
    _exercises = [];
    updateInit(w);
  }

  Future<void> updateInit(Workout w) async {
    List<WorkoutExercise> children = await w.getChildren();

    List<CEWExercise> e = [];

    for (var i in children) {
      List<ExerciseSet> ec = await i.getChildren(w.workoutId);
      var cewe = CEWExercise.from(i, ec);
      e.add(cewe);
    }
    _exercises = e;
    notifyListeners();
    _showExerciseButton();
  }

  Future<void> _showExerciseButton() async {
    await Future.delayed(const Duration(milliseconds: 500));
    showExerciseButton = true;
    notifyListeners();
  }

  late Workout workout;
  late String title;
  late String description;
  late String icon;
  late List<CEWExercise> _exercises;
  bool showExerciseButton = false;

  List<CEWExercise> get exercises => _exercises;

  void addExercise(WorkoutExercise e) {
    _exercises.add(CEWExercise.init(e));
    notifyListeners();
  }

  void insertExercise(int index, WorkoutExercise e) {
    _exercises.insert(index, CEWExercise.init(e));
    notifyListeners();
  }

  void addExerciseChild(int index, ExerciseSet e) {
    var cewe = _exercises.elementAt(index);
    cewe.children.add(e.copy());
    notifyListeners();
  }

  void updateExercise(int index, CEWExercise e) {
    _exercises[index] = e;
    notifyListeners();
  }

  void updateSuperSetExercise(int index, WorkoutExercise e) {
    _exercises[index].exercise = e;
    notifyListeners();
  }

  void insertExerciseChild(int index, ExerciseSet e, int childIndex) {
    var cewe = _exercises.elementAt(index);
    cewe.children.insert(childIndex, e.copy());
    notifyListeners();
  }

  void removeExercise(int index) {
    exercises.removeAt(index);
    notifyListeners();
  }

  void removeExerciseChild(int index, ExerciseSet e) {
    var cewe = _exercises.elementAt(index);
    cewe.children
        .removeWhere((element) => element.exerciseSetId == e.exerciseSetId);
    notifyListeners();
  }

  void refreshExercises(List<CEWExercise> exercises) {
    _exercises
      ..clear()
      ..addAll(exercises);
    notifyListeners();
  }

  void setIcon(String icon) {
    this.icon = icon;
    notifyListeners();
  }

  void setTitle(String title) {
    this.title = title;
    notifyListeners();
  }

  void setDescription(String description) {
    this.description = description;
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
    workout.title = title;
    workout.description = description;
    workout.icon = icon;

    var db = await getDB();
    // start a transaction
    try {
      await db.transaction((txn) async {
        int r = await txn.insert('workout', workout.toMap());
        if (r == 0) {
          throw Exception("There was an issue inserting the workout");
        }

        // EXERCISE IS ALREADY INSERTED

        // set proper order
        for (int i = 0; i < exercises.length; i++) {
          exercises[i].exercise.exerciseOrder = i;
          for (int j = 0; j < exercises[i].children.length; j++) {
            exercises[i].children[j].exerciseOrder = j;
          }
        }

        // add workout exercises
        for (var i in exercises) {
          r = await txn.insert('workout_exercise', i.exercise.toMap());
          if (r == 0) {
            throw Exception("There was an issue inserting a workout exercise");
          }
          // add exercise super sets
          for (var j in i.children) {
            // add all exercise super sets
            r = await txn.insert('exercise_set', j.toMap());
            if (r == 0) {
              throw Exception("There was an issue inserting an exercise set");
            }
          }
        }
      });
      // update the data
      await dmodel.refreshWorkouts();
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "workout_create",
        eventAttributes: {
          "workoutId": workout.workoutId,
          "exercises": exercises.length,
          "title": workout.title,
        },
      );
      return workout;
    } catch (e) {
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "workout_create"},
      );
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Future<Workout?> updateWorkout(DataModel dmodel) async {
    // update the workout
    workout.title = title;
    workout.description = description;
    workout.icon = icon;

    // set proper order
    for (int i = 0; i < exercises.length; i++) {
      exercises[i].exercise.exerciseOrder = i;
      for (int j = 0; j < exercises[i].children.length; j++) {
        exercises[i].children[j].exerciseOrder = j;
      }
    }

    var db = await getDB();
    // start a transaction
    try {
      await db.transaction((txn) async {
        int r = await txn.update('workout', workout.toMap(),
            where: "workoutId = ?", whereArgs: [workout.workoutId]);
        if (r == 0) {
          throw Exception("There was an issue updating the workout");
        }

        // EXERCISES ALREADY INSERTED

        // remove all workout exercises
        r = await txn.delete(
          "workout_exercise",
          where: "workoutId = ?",
          whereArgs: [workout.workoutId],
        );

        // remove all exercise sets
        r = await txn.delete(
          "exercise_set",
          where: "workoutId = ?",
          whereArgs: [workout.workoutId],
        );

        // add workout exercises
        for (var i in exercises) {
          r = await txn.insert('workout_exercise', i.exercise.toMap());
          if (r == 0) {
            throw Exception("There was an issue inserting a workout exercise");
          }
          // add exercise super sets
          for (var j in i.children) {
            // add all exercise super sets
            r = await txn.insert(
              'exercise_set',
              j.toMap(),
            );
            if (r == 0) {
              throw Exception("There was an issue inserting an exercise set");
            }
          }
        }
      });
      // update the data
      await dmodel.fetchData();
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "workout_update",
        eventAttributes: {
          "workoutId": workout.workoutId,
          "exercises": exercises.length,
          "title": workout.title,
        },
      );
      notifyListeners();
      return workout;
    } catch (e) {
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "workout_update"},
      );
      if (kDebugMode) {
        print(e);
      }

      return null;
    }
  }
}

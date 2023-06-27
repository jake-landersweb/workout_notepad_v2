import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class TimerInstance {
  late int index;
  int? childIndex;
  late DateTime startTime;

  TimerInstance({
    required this.index,
    this.childIndex,
    required this.startTime,
  });
}

class LaunchWorkoutModelState {
  late String userId;
  late int workoutIndex;
  late Workout workout;
  late List<WorkoutExercise> exercises;
  late PageController pageController;
  late WorkoutLog wl;
  late DateTime startTime;
  List<List<ExerciseSet>> exerciseChildren = [];
  List<ExerciseLog> exerciseLogs = [];
  List<List<ExerciseLog>> exerciseChildLogs = [];
  late double offsetY;
  List<TimerInstance> timerInstances = [];

  LaunchWorkoutModelState({
    required this.userId,
    this.workoutIndex = 0,
    required this.workout,
    required this.exercises,
    required this.pageController,
    required this.wl,
    required this.startTime,
    this.offsetY = -5,
  });

  int getCurrentSeconds() {
    return DateTime.now().difference(startTime).inSeconds;
  }
}

class LaunchWorkoutModel extends ChangeNotifier {
  late LaunchWorkoutModelState state;

  LaunchWorkoutModel(LaunchWorkoutModelState s) {
    state = s;
    init();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    state.offsetY = 0;
    state.pageController.animateToPage(
      state.workoutIndex,
      duration: const Duration(milliseconds: 700),
      curve: Sprung.overDamped,
    );
    notifyListeners();
  }

  void setIndex(int index) {
    state.workoutIndex = index;
    notifyListeners();
  }

  void setPage(int index) {
    state.pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
    );
  }

  void setLogReps(int index, int row, int val) {
    state.exerciseLogs[index].metadata[row].reps = val;
    notifyListeners();
  }

  void setLogWeight(int index, int row, int val) {
    state.exerciseLogs[index].metadata[row].weight = val;
    notifyListeners();
  }

  void setLogWeightPost(int index, String val) {
    state.exerciseLogs[index].weightPost = val;
    notifyListeners();
  }

  void setLogTime(int index, int row, int val) {
    state.exerciseLogs[index].metadata[row].time = val;
    notifyListeners();
  }

  void setLogSaved(int index, int row, bool val) {
    state.exerciseLogs[index].metadata[row].saved = val;
    notifyListeners();
  }

  void removeLogSet(int index, int row) {
    state.exerciseLogs[index].removeSet(row);
    notifyListeners();
  }

  void addLogSet(int index) {
    state.exerciseLogs[index].addSet();
    notifyListeners();
  }

  void setLogChildReps(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].reps = val;
    notifyListeners();
  }

  void setLogChildWeight(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].weight = val;
    notifyListeners();
  }

  void setLogChildWeightPost(int i, int j, String val) {
    state.exerciseChildLogs[i][j].weightPost = val;
    notifyListeners();
  }

  void setLogChildTime(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].time = val;
    notifyListeners();
  }

  void setLogChildSaved(int i, int j, int row, bool val) {
    state.exerciseChildLogs[i][j].metadata[row].saved = val;
    notifyListeners();
  }

  void removeLogChildSet(int i, int j, int row) {
    state.exerciseChildLogs[i][j].removeSet(row);
    notifyListeners();
  }

  void addLogChildSet(int i, int j) {
    state.exerciseChildLogs[i][j].addSet();
    notifyListeners();
  }

  Future<void> finishWorkout(DataModel dmodel) async {
    // loop through all logs and create log records
    for (var i in state.exerciseLogs) {
      // remove all logs entries that are not complete
      i.metadata.removeWhere((element) => !element.saved);
      // check if empty
      if (i.metadata.isEmpty) {
        continue;
      }
      // add log
      await i.insert();
    }

    // loop through all log children to create records
    for (var i in state.exerciseChildLogs) {
      for (var j in i) {
        j.metadata.removeWhere((element) => !element.saved);
        if (j.metadata.isEmpty) {
          continue;
        }
        await j.insert();
      }
    }

    // determine duration workout has gone on
    state.wl.duration = state.getCurrentSeconds();

    // insert the workout
    await state.wl.insert();

    dmodel.stopWorkout();
  }

  Future<void> addExercise(
    Exercise exercise,
    int index, {
    bool push = false,
  }) async {
    // exercise is not part of workout, need to add it.
    WorkoutExercise we = WorkoutExercise.fromExercise(state.workout, exercise);
    we.exerciseOrder =
        index - 1; // TODO -- may need to remap all exercise index orders
    await we.insert();

    var log = ExerciseLog.workoutInit(
      state.userId,
      we.exerciseId,
      state.wl.workoutLogId,
      we,
    );

    if (index >= state.exercises.length) {
      // add onto end
      state.exercises.add(we);
      state.exerciseChildren.add([]);
      state.exerciseLogs.add(log);
      state.exerciseChildLogs.add([]);
    } else {
      if (push) {
        // insert at index
        state.exercises.insert(index, we);
        state.exerciseChildren.insert(index, []);
        state.exerciseLogs.insert(index, log);
        state.exerciseChildLogs.insert(index, []);
      } else {
        // remove old
        var resp = await state.exercises[index].delete(state.workout.workoutId);
        if (!resp) {
          print("There was an error deleting the exercise");
          notifyListeners();
          return;
        }

        // replace existing
        state.exercises[index] = we;
        state.exerciseChildren[index] = [];
        state.exerciseLogs[index] = log;
        state.exerciseChildLogs[index] = [];
      }
    }
    notifyListeners();
  }

  Future<void> handleSuperSets(
    int index,
    List<ExerciseSet> sets,
  ) async {
    // delete all old exercise sets
    for (var i in state.exerciseChildren[index]) {
      await i.delete(state.workout.workoutId);
    }

    // new log list
    List<ExerciseLog> logs = [];

    // add to exercises
    for (int i = 0; i < sets.length; i++) {
      sets[i].exerciseOrder = i + 1;
      await sets[i].insert(
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var log = ExerciseLog.exerciseSetInit(
        state.userId,
        sets[i].childId,
        sets[i].parentId,
        state.wl.workoutLogId,
        sets[i],
      );
      logs.add(log);
    }
    // add to current workout session state
    state.exerciseChildren[index] = sets;
    state.exerciseChildLogs[index] = logs;
    notifyListeners();
  }
}

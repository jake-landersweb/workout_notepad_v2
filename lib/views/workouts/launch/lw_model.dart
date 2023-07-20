import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';

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
  CollectionItem? collectionItem;
  bool isEmpty;

  LaunchWorkoutModelState({
    this.workoutIndex = 0,
    required this.workout,
    required this.exercises,
    required this.pageController,
    required this.wl,
    required this.startTime,
    this.offsetY = -5,
    this.collectionItem,
    this.isEmpty = false,
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

    // set all unsaved next to this val
    for (int i = row + 1; i < state.exerciseLogs[index].metadata.length; i++) {
      if (!state.exerciseLogs[index].metadata[i].saved) {
        state.exerciseLogs[index].metadata[i].reps = val;
      }
    }
    notifyListeners();
  }

  void setLogWeight(int index, int row, int val) {
    state.exerciseLogs[index].metadata[row].weight = val;
    // save all next unsaved
    for (int i = row + 1; i < state.exerciseLogs[index].metadata.length; i++) {
      if (!state.exerciseLogs[index].metadata[i].saved) {
        state.exerciseLogs[index].metadata[i].weight = val;
      }
    }
    notifyListeners();
  }

  void setLogWeightPost(int index, int j, String val) {
    state.exerciseLogs[index].metadata[j].weightPost = val;
    notifyListeners();
  }

  void setLogTime(int index, int row, int val) {
    state.exerciseLogs[index].metadata[row].time = val;
    // set all unsaved next
    for (int i = row + 1; i < state.exerciseLogs[index].metadata.length; i++) {
      if (!state.exerciseLogs[index].metadata[i].saved) {
        state.exerciseLogs[index].metadata[i].time = val;
      }
    }
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

  void onTagClick(int index, int setIndex, Tag tag) {
    if (state.exerciseLogs[index].metadata[setIndex].tags
        .any((element) => element.tagId == tag.tagId)) {
      state.exerciseLogs[index].metadata[setIndex].tags.removeWhere(
        (element) => element.tagId == tag.tagId,
      );
      return;
    }
    // remove all tags for now to support only single tags on sets
    // TODO -- implement multiple tags
    state.exerciseLogs[index].metadata[setIndex].tags
        .removeWhere((element) => true);
    state.exerciseLogs[index].metadata[setIndex].addTag(tag);
    notifyListeners();
  }

  void setLogChildReps(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].reps = val;
    // set all next not saved
    for (int g = row + 1;
        g < state.exerciseChildLogs[i][j].metadata.length;
        g++) {
      if (!state.exerciseChildLogs[i][j].metadata[g].saved) {
        state.exerciseChildLogs[i][j].metadata[g].reps = val;
      }
    }
    notifyListeners();
  }

  void setLogChildWeight(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].weight = val;
    // set all next not saved
    for (int g = row + 1;
        g < state.exerciseChildLogs[i][j].metadata.length;
        g++) {
      if (!state.exerciseChildLogs[i][j].metadata[g].saved) {
        state.exerciseChildLogs[i][j].metadata[g].weight = val;
      }
    }
    notifyListeners();
  }

  void setLogChildWeightPost(int i, int j, int setIndex, String val) {
    state.exerciseChildLogs[i][j].metadata[setIndex].weightPost = val;
    notifyListeners();
  }

  void setLogChildTime(int i, int j, int row, int val) {
    state.exerciseChildLogs[i][j].metadata[row].time = val;
    // set all next not saved
    for (int g = row + 1;
        g < state.exerciseChildLogs[i][j].metadata.length;
        g++) {
      if (!state.exerciseChildLogs[i][j].metadata[g].saved) {
        state.exerciseChildLogs[i][j].metadata[g].time = val;
      }
    }
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

  void onTagClickChild(int index, int childIndex, int setIndex, Tag tag) {
    if (state.exerciseChildLogs[index][childIndex].metadata[setIndex].tags
        .any((element) => element.tagId == tag.tagId)) {
      state.exerciseChildLogs[index][childIndex].metadata[setIndex].tags
          .removeWhere(
        (element) => element.tagId == tag.tagId,
      );
      return;
    }
    // remove all tags for now to support only single tags on sets
    // TODO -- implement multiple tags
    state.exerciseChildLogs[index][childIndex].metadata[setIndex].tags
        .removeWhere((element) => true);
    state.exerciseChildLogs[index][childIndex].metadata[setIndex].addTag(tag);
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

    // if there is a collection item, attach this log id to it
    if (dmodel.workoutState!.collectionItem != null) {
      // TODO -- find out why state.wl.collectionItem is NULL
      print("adding workoutlogid to collectionItem");
      dmodel.workoutState!.collectionItem!.workoutLogId = state.wl.workoutLogId;
      await dmodel.workoutState!.collectionItem!.insert(
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // create a snapshot of the workout
    var db = await getDB();
    var snp = await state.workout.toSnapshot();
    await db.insert("workout_snapshot", snp.toMap());

    await dmodel.stopWorkout();
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
      eid: we.exerciseId,
      wlid: state.wl.workoutLogId,
      exercise: we,
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
        eid: sets[i].childId,
        parentEid: sets[i].parentId,
        wlid: state.wl.workoutLogId,
        exercise: sets[i],
      );
      logs.add(log);
    }
    // add to current workout session state
    state.exerciseChildren[index] = sets;
    state.exerciseChildLogs[index] = logs;
    notifyListeners();
  }
}

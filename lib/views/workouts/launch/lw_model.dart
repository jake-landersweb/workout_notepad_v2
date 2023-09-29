// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sprung/sprung.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class TimerInstance {
  late String workoutExerciseId;
  late DateTime startTime;

  TimerInstance({
    required this.workoutExerciseId,
    required this.startTime,
  });
}

class LaunchWorkoutModelState {
  late int workoutIndex;
  late Workout workout;
  late List<List<WorkoutExercise>> exercises;
  late PageController pageController;
  late WorkoutLog wl;
  late DateTime startTime;
  late String userId;
  List<List<ExerciseLog>> exerciseLogs = [];
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
    required this.userId,
    this.offsetY = -5,
    this.collectionItem,
    this.isEmpty = false,
  });

  int getCurrentSeconds() {
    return DateTime.now().difference(startTime).inSeconds;
  }

  // for NR
  Map<String, dynamic> toMap() => {
        "workoutIndex": workoutIndex,
        "workout": workout.toMap(),
        "exercises": [
          for (var i in exercises) [for (var j in i) j.toMap()]
        ],
        "exerciseLogs": [
          for (var i in exerciseLogs) [for (var j in i) j.toMap()]
        ],
        "wl": wl.toMap(),
        "startTime": startTime.millisecondsSinceEpoch,
        "collectionItem": collectionItem?.toMap(),
        "isEmpty": isEmpty,
      };
}

class LaunchWorkoutModel extends ChangeNotifier {
  late LaunchWorkoutModelState state;

  LaunchWorkoutModel({required this.state}) {
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

  void setReps(int i, int j, int m, int reps) {
    // set this and future metadata
    for (int idx = m; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      if (state.exerciseLogs[i][j].metadata[idx].saved && idx != m) continue;
      state.exerciseLogs[i][j].metadata[idx].reps = reps;
    }
    notifyListeners();
  }

  void setWeight(int i, int j, int m, int weight) {
    // set this and future metadata
    for (int idx = m; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      if (state.exerciseLogs[i][j].metadata[idx].saved && idx != m) continue;
      state.exerciseLogs[i][j].metadata[idx].weight = weight;
    }
    notifyListeners();
  }

  void setWeightPost(int i, int j, String post) {
    // set this and future metadata
    for (int idx = 0; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      state.exerciseLogs[i][j].metadata[idx].weightPost = post;
    }
    notifyListeners();
  }

  void setTime(int i, int j, int m, int time) {
    // set this and future metadata
    for (int idx = m; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      if (state.exerciseLogs[i][j].metadata[idx].saved && idx != m) continue;
      state.exerciseLogs[i][j].metadata[idx].time = time;
    }
    notifyListeners();
  }

  void setSaved(int i, int j, int m, bool saved) {
    state.exerciseLogs[i][j].metadata[m].saved = saved;
    notifyListeners();
  }

  void addSet(int i, int j, Tag? defaultTag) {
    state.exerciseLogs[i][j].addSet(defaultTag: defaultTag);
    notifyListeners();
  }

  void removeSet(int i, int j, int m) {
    state.exerciseLogs[i][j].removeSet(m);
    notifyListeners();
  }

  void onTagClick(int i, int j, int m, Tag tag) {
    if (state.exerciseLogs[i][j].metadata[m].tags
        .any((element) => element.tagId == tag.tagId)) {
      state.exerciseLogs[i][j].metadata[m].tags.removeWhere(
        (element) => element.tagId == tag.tagId,
      );
      return;
    }
    state.exerciseLogs[i][j].metadata[m].addTag(tag);
    notifyListeners();
  }

  Future<bool> addExercise(int i, int j, Exercise exercise) async {
    try {
      // create a workout exercise and log
      var we = WorkoutExercise.fromExercise(state.workout, exercise);
      var el = ExerciseLog.workoutInit(
        workoutLog: state.wl,
        exercise: we,
      );
      we.supersetOrder = j;
      el.supersetOrder = j;

      // do operations inside of transaction
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        if (i >= state.exercises.length) {
          // add to new list
          state.exercises.add([we]);
          state.exerciseLogs.add([el]);
          int r = await txn.insert("workout_exercise", we.toMap());
          if (r == 0) {
            throw "There was an issue adding this exericse";
          }
        } else if (j == state.exercises[i].length) {
          // adding to existing list

          if (j > 0) {
            we.supersetId = state.exercises[i][0].supersetId;
            el.supersetId = state.exerciseLogs[i][0].supersetId;
          }
          state.exercises[i].add(we);
          state.exerciseLogs[i].add(el);
          // add this exercise to the workout
          int r = await txn.insert("workout_exercise", we.toMap());
          if (r == 0) {
            throw "There was an issue adding the exericse";
          }
        } else {
          // replace an existing exercise
          we.supersetId = state.exercises[i][0].supersetId;
          el.supersetId = state.exercises[i][0].supersetId;

          // delete the old exercise
          int r = await txn.rawDelete(
            "DELETE FROM workout_exercise WHERE workoutExerciseId = ?",
            [state.exercises[i][j].workoutExerciseId],
          );
          if (r == 0) {
            throw "There was an issue deleting the old exercise";
          }

          // replace the existing exercise
          state.exercises[i][j] = we;
          state.exerciseLogs[i][j] = el;

          // insert into database
          r = await txn.insert("workout_exercise", we.toMap());
          if (r == 0) {
            throw "There was an issue adding the exercise into the workout";
          }
        }
      });
      // if here, then it worked
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {
          "userId": state.userId,
          "i": i,
          "j": j,
          "state": jsonEncode(state.toMap()),
        },
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeExercise(int i, int j) async {
    try {
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        int r = await txn.rawDelete(
          "DELETE FROM workout_exercise WHERE workoutExerciseId = ?",
          [state.exercises[i][j].workoutExerciseId],
        );
        if (r == 0) {
          throw "There was no workout exercise deleted";
        }

        // configure state
        state.exercises[i].removeAt(j);
        state.exerciseLogs[i].removeAt(j);
        if (state.exercises[i].isEmpty) {
          state.pageController.animateToPage(
            state.workoutIndex - 1,
            duration: const Duration(milliseconds: 700),
            curve: Sprung.overDamped,
          );
          state.exercises.removeAt(i);
          state.exerciseLogs.removeAt(i);
        }
      });
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {
          "userId": state.userId,
          "i": i,
          "j": j,
          "state": jsonEncode(state.toMap()),
        },
      );
      notifyListeners();
      return false;
    }
  }

  void refresh() {
    notifyListeners();
  }

  Future<Tuple2<bool, String>> finishWorkout(DataModel dmodel) async {
    try {
      if (state.exercises.isEmpty) {
        await dmodel.stopWorkout(isCancel: true);
        return Tuple2(
            true, "The exercise was empty, so this workout was not saved.");
      }
      var db = await DatabaseProvider().database;
      // remove all metadata that is not valid
      for (var i in state.exerciseLogs) {
        for (var j in i) {
          j.metadata.removeWhere((element) => !element.saved);
        }
      }

      // capture the duration of the workout
      state.wl.duration = state.getCurrentSeconds();

      // perform the update on the database
      try {
        await db.transaction((txn) async {
          // insert exercise logs
          for (int i = 0; i < state.exerciseLogs.length; i++) {
            for (int j = 0; j < state.exerciseLogs[i].length; j++) {
              // check for valid metadata
              if (state.exerciseLogs[i][j].metadata.isNotEmpty) {
                // insert exercise
                int r = await txn.insert(
                  "exercise_log",
                  state.exerciseLogs[i][j].toMap(),
                );
                if (r == 0) {
                  throw "There was an issue inserting the exercise log";
                }

                // insert the metadata
                for (int m = 0;
                    m < state.exerciseLogs[i][j].metadata.length;
                    m++) {
                  await txn.insert(
                    "exercise_log_meta",
                    state.exerciseLogs[i][j].metadata[m].toMap(),
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );
                  // insert tags
                  for (int c = 0;
                      c < state.exerciseLogs[i][j].metadata[m].tags.length;
                      c++) {
                    await txn.insert(
                      "exercise_log_meta_tag",
                      state.exerciseLogs[i][j].metadata[m].tags[c].toMap(),
                      conflictAlgorithm: ConflictAlgorithm.replace,
                    );
                  }
                }
              }
            }
          }

          // insert the workout
          await txn.insert(
            "workout_log",
            state.wl.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        });
      } catch (e) {
        print(e);
        NewrelicMobile.instance.recordError(
          e,
          StackTrace.current,
          attributes: {
            "err_code": "workout_save",
            "state": jsonEncode(state.toMap()),
          },
          isFatal: true,
        );
        return Tuple2(false,
            "There was an issue saving your workout to the database. Support has been notified.");
      }

      // create a snapshot of the workout
      if (dmodel.user!.subscriptionType != SubscriptionType.none) {
        try {
          var snp = await state.workout.toSnapshot(db);
          await db.insert("workout_snapshot", snp.toMap());
        } catch (error) {
          print(error);
          NewrelicMobile.instance.recordError(
            error,
            StackTrace.current,
            attributes: {
              "err_code": "workout_snapshot",
              "state": jsonEncode(state.toMap()),
            },
          );
          return Tuple2(false,
              "Your workout was successfully saved, but there was an issue creating a snapshot of the workout. You can safely cancel this workout and not lose progress.");
        }
      }

      await dmodel.stopWorkout();
      return Tuple2(true, "");
    } catch (oops) {
      print(oops);
      NewrelicMobile.instance.recordError(
        oops,
        StackTrace.current,
        attributes: {
          "err_code": "workout_unknown",
          "state": jsonEncode(state.toMap()),
        },
      );
      return Tuple2(false,
          "There was an unknown issue when saving the workout. Support has been notified");
    }
  }

  Future<void> handleFinish(BuildContext context, DataModel dmodel) async {
    // send the request
    var response = await finishWorkout(dmodel);
    if (response.v1) {
      if (response.v2.isNotEmpty) {
        snackbarStatus(
          context,
          response.v2,
          duration: const Duration(seconds: 6),
        );
      }
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      snackbarErr(
        context,
        response.v2,
        duration: const Duration(seconds: 6),
      );
    }
  }
}

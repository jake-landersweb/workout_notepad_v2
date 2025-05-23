// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:opentelemetry/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprung/sprung.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/otel.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class TimerInstance {
  late String workoutExerciseId;
  late DateTime startTime;

  TimerInstance({
    required this.workoutExerciseId,
    required this.startTime,
  });

  TimerInstance.fromJson(Map<String, dynamic> data) {
    workoutExerciseId = data['workoutExerciseId'];
    startTime = DateTime.fromMillisecondsSinceEpoch(data['startTime']);
  }

  Map<String, dynamic> toMap() => {
        "workoutExerciseId": workoutExerciseId,
        "startTime": startTime.millisecondsSinceEpoch,
      };
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

  Future<bool> dumpToFile() async {
    print("writing workout state to file ...");
    // create the object
    var obj = {
      "workoutIndex": workoutIndex,
      "workout": workout.toDump(),
      "exercises": [
        for (var i in exercises) [for (var j in i) j.toMapRAW()]
      ],
      "wl": wl.toDump(),
      "startTime": startTime.millisecondsSinceEpoch,
      "userId": userId,
      "exerciseLogs": [
        for (var i in exerciseLogs) [for (var j in i) j.toDump()]
      ],
      "offsetY": offsetY,
      "timerInstances": [for (var i in timerInstances) i.toMap()],
      "isEmpty": isEmpty,
    };

    // write to file
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/workout_state.tmp');
      await file.writeAsString(jsonEncode(obj));
      print("success.");
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  static Future<LaunchWorkoutModelState?> loadFromFile() async {
    try {
      // check if file exists
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/workout_state.tmp');

      if (!file.existsSync()) {
        return null;
      }

      // read the data
      String raw = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(raw);

      var workoutIndex = data['workoutIndex'];
      var workout = await Workout.fromJson(data['workout']);
      var exercises = [
        for (var i in data['exercises'])
          [for (var j in i) WorkoutExercise.fromJson(j)]
      ];
      var pageController = PageController(initialPage: 0);
      var wl = await WorkoutLog.fromJson(data['wl']);
      var startTime = DateTime.fromMillisecondsSinceEpoch(data['startTime']);
      var userId = data['userId'];
      var exerciseLogs = [
        for (var i in data['exerciseLogs'])
          [for (var j in i) await ExerciseLog.fromDump(j)]
      ];
      var offsetY = data['offsetY'];
      var timerInstances = [
        for (var i in data['timerInstances']) TimerInstance.fromJson(i)
      ];
      var isEmpty = data['isEmpty'];

      var state = LaunchWorkoutModelState(
        workoutIndex: workoutIndex,
        workout: workout,
        exercises: exercises,
        pageController: pageController,
        wl: wl,
        startTime: startTime,
        userId: userId,
        offsetY: offsetY,
        isEmpty: isEmpty,
      );
      state.exerciseLogs = exerciseLogs;
      state.timerInstances = timerInstances;

      // delete the file
      await file.delete();
      return state;
    } catch (e, stack) {
      print(e);
      print(stack);
      return null;
    }
  }

  Future<void> deleteFile() async {
    // check if file exists
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/workout_state.tmp');

    if (file.existsSync()) {
      await file.delete();
    }
  }

  double getPercentageComplete() {
    int total = 0;
    int complete = 0;

    for (var group in exerciseLogs) {
      for (var log in group) {
        for (var meta in log.metadata) {
          total += 1;
          if (meta.saved) {
            complete += 1;
          }
        }
      }
    }

    if (total == 0) {
      return 0;
    }

    return complete / total;
  }
}

class LaunchWorkoutModel extends ChangeNotifier {
  late LaunchWorkoutModelState state;
  late Span _span;

  LaunchWorkoutModel({required this.state}) {
    // setup the span to run
    _span = GlobalTelemetry.startSpan(
      "workout_launch",
      attributes: [
        Attribute.fromString("workoutId", state.workout.workoutId),
        Attribute.fromString("workoutLogId", state.wl.workoutLogId),
        Attribute.fromInt("numExercises", state.exercises.length),
      ],
    );
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
    _span.addEvent("setReps", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
      Attribute.fromInt("value", reps),
    ]);
    notifyListeners();
  }

  void setWeight(int i, int j, int m, int weight) {
    // set this and future metadata
    for (int idx = m; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      if (state.exerciseLogs[i][j].metadata[idx].saved && idx != m) continue;
      state.exerciseLogs[i][j].metadata[idx].weight = weight;
    }
    _span.addEvent("setWeight", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
      Attribute.fromInt("value", weight),
    ]);
    notifyListeners();
  }

  void setWeightPost(int i, int j, String post) {
    // set this and future metadata
    for (int idx = 0; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      state.exerciseLogs[i][j].metadata[idx].weightPost = post;
    }
    _span.addEvent("setWeightPost", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
      Attribute.fromString("value", post),
    ]);
    notifyListeners();
  }

  void setTime(int i, int j, int m, int time) {
    // set this and future metadata
    for (int idx = m; idx < state.exerciseLogs[i][j].metadata.length; idx++) {
      if (state.exerciseLogs[i][j].metadata[idx].saved && idx != m) continue;
      state.exerciseLogs[i][j].metadata[idx].time = time;
    }
    _span.addEvent("setTime", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
      Attribute.fromInt("value", time),
    ]);
    notifyListeners();
  }

  void setSaved(int i, int j, int m, bool saved, {DateTime? savedDate}) {
    state.exerciseLogs[i][j].metadata[m].saved = saved;
    // only set once
    if (state.exerciseLogs[i][j].metadata[m].savedDate == null) {
      state.exerciseLogs[i][j].metadata[m].savedDate =
          savedDate ?? DateTime.now();
    }
    _span.addEvent("setSaved", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
      Attribute.fromBoolean("value", saved),
    ]);
    notifyListeners();
  }

  void addSet(int i, int j, Tag? defaultTag) {
    state.exerciseLogs[i][j].addSet(defaultTag: defaultTag);
    _span.addEvent("addSet", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
    ]);
    notifyListeners();
  }

  void removeSet(int i, int j, int m) {
    state.exerciseLogs[i][j].removeSet(m);
    _span.addEvent("removeSet", attributes: [
      Attribute.fromString("exercise", state.exercises[i][j].title),
    ]);
    notifyListeners();
  }

  void onTagClick(int i, int j, int m, Tag tag) {
    if (state.exerciseLogs[i][j].metadata[m].tags
        .any((element) => element.tagId == tag.tagId)) {
      state.exerciseLogs[i][j].metadata[m].tags.removeWhere(
        (element) => element.tagId == tag.tagId,
      );
      notifyListeners();
      return;
    }
    state.exerciseLogs[i][j].metadata[m].addTag(tag);
    notifyListeners();
  }

  Future<bool> addExercise(
      int i, int j, Exercise exercise, Tag? defaultTag) async {
    try {
      // create a workout exercise and log
      var we = WorkoutExercise.fromExercise(state.workout, exercise);
      var el = ExerciseLog.workoutInit(
        workoutLog: state.wl,
        exercise: we,
        defaultTag: defaultTag,
      );
      we.supersetOrder = j;
      el.supersetOrder = j;

      // remove if a timer exists for this item
      if (i < state.timerInstances.length) {
        state.timerInstances.removeWhere(
          (element) =>
              element.workoutExerciseId ==
              state.exercises[i][j].workoutExerciseId,
        );
      }

      // do operations inside of transaction
      if (i >= state.exercises.length) {
        // add to new list
        state.exercises.add([we]);
        state.exerciseLogs.add([el]);
      } else if (j == state.exercises[i].length) {
        // adding to existing list

        if (j > 0) {
          we.supersetId = state.exercises[i][0].supersetId;
          el.supersetId = state.exerciseLogs[i][0].supersetId;
        }
        state.exercises[i].add(we);
        state.exerciseLogs[i].add(el);
      } else {
        // replace an existing exercise
        we.supersetId = state.exercises[i][0].supersetId;
        el.supersetId = state.exercises[i][0].supersetId;

        // replace the existing exercise
        state.exercises[i][j] = we;
        state.exerciseLogs[i][j] = el;
      }

      // -- OLD CODE FOR EDITING THE BASE WORKOUT DIRECTLY
      // var db = await DatabaseProvider().database;
      // await db.transaction((txn) async {
      //   if (i >= state.exercises.length) {
      //     // add to new list
      //     state.exercises.add([we]);
      //     state.exerciseLogs.add([el]);
      //     int r = await txn.insert("workout_exercise", we.toMap());
      //     if (r == 0) {
      //       throw "There was an issue adding this exericse";
      //     }
      //   } else if (j == state.exercises[i].length) {
      //     // adding to existing list

      //     if (j > 0) {
      //       we.supersetId = state.exercises[i][0].supersetId;
      //       el.supersetId = state.exerciseLogs[i][0].supersetId;
      //     }
      //     state.exercises[i].add(we);
      //     state.exerciseLogs[i].add(el);
      //     // add this exercise to the workout
      //     int r = await txn.insert("workout_exercise", we.toMap());
      //     if (r == 0) {
      //       throw "There was an issue adding the exericse";
      //     }
      //   } else {
      //     // replace an existing exercise
      //     we.supersetId = state.exercises[i][0].supersetId;
      //     el.supersetId = state.exercises[i][0].supersetId;

      //     // delete the old exercise
      //     int r = await txn.rawDelete(
      //       "DELETE FROM workout_exercise WHERE workoutExerciseId = ?",
      //       [state.exercises[i][j].workoutExerciseId],
      //     );
      //     if (r == 0) {
      //       throw "There was an issue deleting the old exercise";
      //     }

      //     // replace the existing exercise
      //     state.exercises[i][j] = we;
      //     state.exerciseLogs[i][j] = el;

      //     // insert into database
      //     r = await txn.insert("workout_exercise", we.toMap());
      //     if (r == 0) {
      //       throw "There was an issue adding the exercise into the workout";
      //     }
      //   }
      // });
      // if here, then it worked
      _span.addEvent("add_exercise");
      _span.setAttribute(
          Attribute.fromInt("numExercises", state.exercises.length));
      notifyListeners();
      return true;
    } catch (e, stack) {
      logger.exception(e, stack, data: {
        "userId": state.userId,
        "i": i,
        "j": j,
        "state": jsonEncode(state.toMap()),
      });
      notifyListeners();
      return false;
    } finally {}
  }

  Future<bool> removeExercise(int i, int j) async {
    try {
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
      // -- OLD CODE FOR EDITING THE BASE WORKOUT
      // var db = await DatabaseProvider().database;
      // await db.transaction((txn) async {
      //   int r = await txn.rawDelete(
      //     "DELETE FROM workout_exercise WHERE workoutExerciseId = ?",
      //     [state.exercises[i][j].workoutExerciseId],
      //   );
      //   if (r == 0) {
      //     throw "There was no workout exercise deleted";
      //   }

      //   // configure state
      //   state.exercises[i].removeAt(j);
      //   state.exerciseLogs[i].removeAt(j);
      //   if (state.exercises[i].isEmpty) {
      //     state.pageController.animateToPage(
      //       state.workoutIndex - 1,
      //       duration: const Duration(milliseconds: 700),
      //       curve: Sprung.overDamped,
      //     );
      //     state.exercises.removeAt(i);
      //     state.exerciseLogs.removeAt(i);
      //   }
      // });
      notifyListeners();
      return true;
    } catch (e, stack) {
      logger.exception(
        e,
        stack,
        data: {
          "userId": state.userId,
          "i": i,
          "j": j,
          "state": jsonEncode(state.toMap()),
        },
      );
      _span.addEvent("remove_exercise");
      _span.setAttribute(
          Attribute.fromInt("numExercises", state.exercises.length));
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
                // ensure order integrity
                state.exerciseLogs[i][j].exerciseOrder = i;
                state.exerciseLogs[i][j].supersetOrder = j;

                // insert exercise
                int r = await txn.insert(
                  "exercise_log",
                  state.exerciseLogs[i][j].toMap(),
                );
                if (r == 0) {
                  throw "There was an issue inserting the exercise log";
                }

                // remove possible metadata objects

                // insert the metadata
                for (int m = 0;
                    m < state.exerciseLogs[i][j].metadata.length;
                    m++) {
                  await txn.insert(
                    "exercise_log_meta",
                    state.exerciseLogs[i][j].metadata[m].toMap(),
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );

                  // remove duplicate tags based on tag id
                  final seenTags = <String>{};
                  List<ExerciseLogMetaTag> pruned = [];

                  for (var item in state.exerciseLogs[i][j].metadata[m].tags) {
                    if (seenTags.add(item.tagId)) {
                      pruned.add(item);
                    }
                  }
                  // insert tags
                  for (var elmt in pruned) {
                    await txn.insert(
                      "exercise_log_meta_tag",
                      elmt.toMap(),
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
      } catch (e, stack) {
        logger.exception(
          e,
          stack,
          data: {
            "err_code": "workout_save",
            "state": jsonEncode(state.toMap()),
          },
        );
        return Tuple2(false,
            "There was an issue saving your workout to the database. Support has been notified.");
      }

      // create a snapshot of the workout
      // if (dmodel.hasValidSubscription()) {
      //   try {
      //     var snp = await state.workout.toSnapshot(db);
      //     await db.insert("workout_snapshot", snp.toMap());
      //   }  catch (error, stack) { logger.exception(e, stack);
      //     print(error);
      //     NewrelicMobile.instance.recordError(
      //       error,
      //       StackTrace.current,
      //       attributes: {
      //         "err_code": "workout_snapshot",
      //         "state": jsonEncode(state.toMap()),
      //       },
      //     );
      //     return Tuple2(false,
      //         "Your workout was successfully saved, but there was an issue creating a snapshot of the workout. You can safely cancel this workout and not lose progress.");
      //   }
      // }

      await dmodel.stopWorkout();
      _span.setStatus(StatusCode.ok);
      return Tuple2(true, "");
    } catch (error, stack) {
      _span
        ..setStatus(StatusCode.error, error.toString())
        ..recordException(error, stackTrace: stack);

      logger.exception(error, stack, data: {
        "err_code": "workout_unknown",
        "state": jsonEncode(state.toMap()),
      });
      return Tuple2(false,
          "There was an unknown issue when saving the workout. Support has been notified");
    } finally {
      GlobalTelemetry.endSpan(_span);
    }
  }

  Future<bool> saveWorkoutAsTemplate(String title) async {
    try {
      var db = await DatabaseProvider().database;
      await db.transaction((txn) async {
        // create a new workout
        var tmpWorkout = Workout.init();
        tmpWorkout.title = title;

        // loop through all exercises and group and add as supersets
        var uuid = const Uuid();
        for (int i = 0; i < state.exercises.length; i++) {
          var supersetId = uuid.v4();
          for (int j = 0; j < state.exercises[i].length; j++) {
            // create a clone
            var tmpExercise = state.exercises[i][j].clone(tmpWorkout);
            // configure the exercise fields
            tmpExercise.exerciseOrder = i;
            tmpExercise.supersetId = supersetId;
            tmpExercise.supersetOrder = j;
            var r = await txn.insert("workout_exercise", tmpExercise.toMap());
            if (r == 0) {
              throw 'failed to insert the workout exericse';
            }
          }
        }

        // add or update the workout
        var r = await txn.insert(
          "workout",
          tmpWorkout.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        if (r == 0) {
          throw 'failed to insert the workout';
        }
      });
      // set the title of the current workout (just for looks)
      state.workout.title = title;
      notifyListeners();
      return true;
    } catch (e, stack) {
      logger.exception(
        e,
        stack,
        data: {
          "err_code": "save_workout_as_template",
          "state": jsonEncode(state.toMap()),
        },
      );
      return false;
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
      dmodel.toggleShowPostWorkoutScreen();
    } else {
      snackbarErr(
        context,
        response.v2,
        duration: const Duration(seconds: 6),
      );
    }
  }

  bool handleEdit(DataModel dmodel, Workout workout) {
    try {
      // construct a map of workoutExerciseId
      Iterable<ExerciseLog> existingLogs = state.exerciseLogs.flattened;
      print(existingLogs.map((e) => "${e.workoutExerciseId}"));

      // hold a reference of the new logs
      List<List<ExerciseLog>> newLogs = [];

      var exercises = workout.getExercises() as List<List<WorkoutExercise>>;
      print(exercises.flattened.map((e) => "${e.getUniqueId()}"));

      // loop over the new exercises, and attempt to match the log to the
      for (var group in exercises) {
        List<ExerciseLog> logGroup = [];
        for (var exercise in group) {
          var log = existingLogs.firstWhereOrNull(
            (l) => l.workoutExerciseId == exercise.getUniqueId(),
          );
          if (log == null) {
            print("LOG IS NULL");
            var wl = ExerciseLog.workoutInit(
              workoutLog: state.wl,
              exercise: exercise,
              defaultTag:
                  dmodel.tags.firstWhereOrNull((element) => element.isDefault),
            );
            logGroup.add(wl);
          } else {
            logGroup.add(log);
          }
        }
        newLogs.add(logGroup);
      }

      // set the new values
      state.exercises = exercises;
      state.exerciseLogs = newLogs;
      state.wl.title = workout.title;
      state.wl.description = workout.description;
      notifyListeners();
      return true;
    } catch (error, stack) {
      print(error);
      print(stack);
      return false;
    }
  }

  @override
  void dispose() {
    // ensure the span gets disposed if the workout is cancelled
    _span.addEvent("cancel");
    GlobalTelemetry.endSpan(_span);
    super.dispose();
  }
}

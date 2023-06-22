// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/load_tests.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';

enum LoadStatus { init, noUser, done }

class DataModel extends ChangeNotifier {
  DataModel() {
    initTest(delete: false);
    // init();
  }

  LoadStatus loadStatus = LoadStatus.init;

  Color color = appColors.first;

  bool? _lightStatus;
  bool? get lightStatus => _lightStatus;
  void toggleLightStatus(bool? status) {
    _lightStatus = status;
    notifyListeners();
  }

  LaunchWorkoutModelState? workoutState;

  Future<LaunchWorkoutModelState> createWorkoutState(Workout workout) async {
    workoutState = null;
    notifyListeners();
    workoutState = LaunchWorkoutModelState(
      userId: user!.userId,
      workout: workout,
      exercises: [],
      pageController: PageController(initialPage: 0),
      wl: WorkoutLog.init(user!.userId, workout),
      startTime: DateTime.now(),
    );
    if (workoutState!.exercises.isEmpty) {
      // get the exercise children
      workoutState!.exercises = await workoutState!.workout.getChildren();
    }
    for (int i = 0; i < workoutState!.exercises.length; i++) {
      var tmp = await workoutState!.exercises[i]
          .getChildren(workoutState!.workout.workoutId);
      workoutState!.exerciseChildren.add(tmp);
      // create the log group for each exercise
      workoutState!.exerciseLogs.add(
        ExerciseLog.workoutInit(
          workoutState!.userId,
          workoutState!.exercises[i].exerciseId,
          workoutState!.wl.workoutLogId,
          workoutState!.exercises[i],
        ),
      );

      // create the logs for the children as well
      workoutState!.exerciseChildLogs.add([]);
      for (var j in tmp) {
        workoutState!.exerciseChildLogs[i].add(
          ExerciseLog.workoutInit(
            workoutState!.userId,
            j.childId,
            workoutState!.wl.workoutLogId,
            j,
          ),
        );
      }
    }
    return workoutState!;
  }

  void stopWorkout() {
    workoutState = null;
    notifyListeners();
  }

  Future<void> setColor(Color c) async {
    var prefs = await SharedPreferences.getInstance();
    var r = await prefs.setString("color", c.toString());
    if (r) {
      color = c;
    }
    notifyListeners();
  }

  User? user;

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  Future<void> refreshCategories() async {
    _categories = await Category.getList(user!.userId);
    notifyListeners();
  }

  List<WorkoutCategories> _workouts = [];
  List<WorkoutCategories> get workouts => _workouts;
  Future<void> refreshWorkouts() async {
    _workouts = await WorkoutCategories.getList(user!.userId);
    notifyListeners();
  }

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;
  Future<void> refreshExercises() async {
    _exercises = await Exercise.getList(user!.userId);
    notifyListeners();
  }

  Future<void> init() async {
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey("userId")) {
      log("[INIT] User does not exist");
      // create a user record
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }

    // get the user
    user = await User.fromId(prefs.getString("userId")!);
    if (user == null) {
      log("[INIT] userId in prefs is invalid");
      prefs.remove("userId");
      // create new user
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }

    // get the color
    var c = prefs.getString("color");
    if (c != null) {
      try {
        var tmp = appColors.firstWhere((element) => element.toString() == c);
        setColor(tmp);
      } catch (e) {}
    }

    log("[INIT] User exists");

    // get all user data
    await fetchData(user!.userId);
    loadStatus = LoadStatus.done;
    notifyListeners();
  }

  Future<void> initTest({bool? delete}) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString("userId", "1");
    if (delete ?? false) {
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
      User u = User.init();
      u.userId = "1";
      await u.insert();
      await loadTests();
    }

    // get the color
    var c = prefs.getString("color");
    if (c != null) {
      try {
        var tmp = appColors.firstWhere((element) => element.toString() == c);
        setColor(tmp);
      } catch (e) {}
    }

    var db = await getDB();
    var response = await db.query('workout_log');

    user = await User.fromId(prefs.getString("userId")!);
    await fetchData(user!.userId);
  }

  Future<void> fetchData(String userId) async {
    var getC = Category.getList(userId);
    var getW = WorkoutCategories.getList(userId);
    var getE = Exercise.getList(userId);
    _categories = await getC;
    _workouts = await getW;
    _exercises = await getE;
    loadStatus = LoadStatus.done;

    notifyListeners();
  }
}

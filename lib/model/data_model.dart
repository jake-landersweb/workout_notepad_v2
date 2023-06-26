// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:http/http.dart' as http;

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
      await importData();
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

  Future<void> exportToJSON() async {
    // get the database
    var db = await getDB();

    // get data
    var users = await db.query("user");
    var categories = await db.query("category");
    var exercises = await db.query("exercise");
    var exerciseSets = await db.query("exercise_set");
    var workouts = await db.query("workout");
    var workoutExercises = await db.query("workout_exercise");
    var exerciseLogs = await db.query("exercise_log");
    var workoutLogs = await db.query("workout_log");

    // create structured data
    Map<String, dynamic> data = {
      "users": users,
      "categories": categories,
      "exercises": exercises,
      "exerciseSets": exerciseSets,
      "workouts": workouts,
      "workoutExercises": workoutExercises,
      "exerciseLogs": exerciseLogs,
      "workoutLogs": workoutLogs,
    };

    // encode to json
    String encoded = jsonEncode(data);

    // send to url
    var response = await http.Client().post(
      Uri.parse(
          "https://4q849d280b.execute-api.us-west-2.amazonaws.com/api/v2/export"),
      headers: {"Content-type": "application/json"},
      body: encoded,
    );

    print(response.statusCode);
  }

  Future<void> importData({bool delete = true}) async {
    if (delete) {
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
    }
    // load / create database
    var db = await getDB();

    // read file
    String json = await rootBundle.loadString("sql/init.json");
    Map<String, dynamic> data = const JsonDecoder().convert(json);

    Future<void> load(String table, List<dynamic> objects) async {
      for (var i in objects) {
        await db.insert(table, i, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // load all data
    await load("user", data['users']);
    await load("category", data['categories']);
    await load("exercise", data['exercises']);
    await load("exercise_set", data['exerciseSets']);
    await load("workout", data['workouts']);
    await load("workout_exercise", data['workoutExercises']);
    await load("exercise_log", data['exerciseLogs']);
    await load("workout_log", data['workoutLogs']);
  }
}

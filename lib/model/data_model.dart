// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:http/http.dart' as http;

enum LoadStatus { init, noUser, done, expired }

class DataModel extends ChangeNotifier {
  User? user;
  User? expiredAnonUser;
  LoadStatus loadStatus = LoadStatus.init;
  Color color = const Color(0xFF418a2f);

  DataModel() {
    init();
  }

  Future<void> createAnonymousUser(BuildContext context) async {
    var u = await User.loginAnon();
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: const Text("There was an issue getting your account."),
        ),
      );
      return;
    }
    await init(u: u);
  }

  Future<void> loginUser(
    BuildContext context,
    auth.UserCredential credential,
  ) async {
    var u = await User.loginAuth(credential, convertFromAnon: user != null);
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[300],
          content: const Text("There was an issue getting your account."),
        ),
      );
      return;
    }
    await init(u: u);
  }

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  Future<void> refreshCategories() async {
    _categories = await Category.getList();
    notifyListeners();
  }

  List<WorkoutCategories> _workouts = [];
  List<WorkoutCategories> get workouts => _workouts;
  Future<void> refreshWorkouts() async {
    _workouts = await WorkoutCategories.getList();
    notifyListeners();
  }

  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;
  Future<void> refreshExercises() async {
    _exercises = await Exercise.getList();
    notifyListeners();
  }

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;
  Future<void> refreshTags() async {
    _tags = await Tag.getList();
    notifyListeners();
  }

  Future<void> init({User? u}) async {
    // delete the database
    // await deleteDB();

    if (u != null) {
      // user already authenticated, fetch all data
      user = u;
      await fetchData();
      loadStatus = LoadStatus.done;
      notifyListeners();
      return;
    }

    // check for saved userId
    var prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userId")) {
      print("[INIT] userId not saved in preferences");
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }

    // get the user
    var tmp = await User.fromId(prefs.getString("userId")!);
    if (tmp == null) {
      print("[INIT] There was no user found with the userId");
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }

    if (tmp.isAnon) {
      print("[INIT] Anon user");
      // check if expired
      if (tmp.expireEpoch < DateTime.now().millisecondsSinceEpoch) {
        print("[INIT] This anon user is expired");
        expiredAnonUser = tmp;
        loadStatus = LoadStatus.expired;
        notifyListeners();
        return;
      } else {
        print("[INIT] Anon user is valid");
        user = tmp;
      }
    } else {
      // user not anon, make sure there is a valid firebase instance
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        log("[INIT] No user loaded in firebase");
        loadStatus = LoadStatus.noUser;
        notifyListeners();
        return;
      } else {
        print("[INIT] valid firebase user");
        print(firebaseUser);
        user = tmp;
      }
    }

    print("[INIT] finished user validation");
    print(user);

    // get all user data
    await fetchData();
    loadStatus = LoadStatus.done;
  }

  Future<void> initTest({bool? delete}) async {
    if (delete ?? false) {
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
      await importData();
    }

    await fetchData();
  }

  Future<void> fetchData() async {
    var getC = Category.getList();
    var getW = WorkoutCategories.getList();
    var getE = Exercise.getList();
    var getT = Tag.getList();
    _categories = await getC;
    _workouts = await getW;
    _exercises = await getE;
    _tags = await getT;
    loadStatus = LoadStatus.done;

    notifyListeners();
  }

  bool? _lightStatus;
  bool? get lightStatus => _lightStatus;
  void toggleLightStatus(bool? status) {
    _lightStatus = status;
    notifyListeners();
  }

  Future<void> logout() async {
    // create a snapshot of their data
    // TODO --
    await deleteDB();
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("userId");
    user = null;
    loadStatus = LoadStatus.noUser;
    notifyListeners();
  }

  LaunchWorkoutModelState? workoutState;
  Future<LaunchWorkoutModelState> createWorkoutState(Workout workout) async {
    workoutState = null;
    notifyListeners();
    workoutState = LaunchWorkoutModelState(
      workout: workout,
      exercises: [],
      pageController: PageController(initialPage: 0),
      wl: WorkoutLog.init(workout),
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
          workoutState!.exercises[i].exerciseId,
          workoutState!.wl.workoutLogId,
          workoutState!.exercises[i],
        ),
      );

      // create the logs for the children as well
      workoutState!.exerciseChildLogs.add([]);
      for (var j in tmp) {
        workoutState!.exerciseChildLogs[i].add(
          ExerciseLog.exerciseSetInit(
            j.childId,
            j.parentId,
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

  Future<void> exportToJSON() async {
    // get the database
    var db = await getDB();

    // get data
    var categories = await db.query("category");
    var exercises = await db.query("exercise");
    var exerciseSets = await db.query("exercise_set");
    var workouts = await db.query("workout");
    var workoutExercises = await db.query("workout_exercise");
    var exerciseLogs = await db.query("exercise_log");
    var workoutLogs = await db.query("workout_log");
    var tags = await db.query("tag");

    // create structured data
    Map<String, dynamic> data = {
      "categories": categories,
      "exercises": exercises,
      "exerciseSets": exerciseSets,
      "workouts": workouts,
      "workoutExercises": workoutExercises,
      "exerciseLogs": exerciseLogs,
      "workoutLogs": workoutLogs,
      "tags": tags,
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
    print("IMPORTING DATA");
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
    await load("category", data['categories']);
    await load("exercise", data['exercises']);
    await load("exercise_set", data['exerciseSets']);
    await load("workout", data['workouts']);
    await load("workout_exercise", data['workoutExercises']);
    await load("exercise_log", data['exerciseLogs']);
    await load("workout_log", data['workoutLogs']);
    await load("tag", data['tags']);
    notifyListeners();
  }

  Future<void> deleteDB() async {
    String path = join(await getDatabasesPath(), 'workout_notepad.db');
    await databaseFactory.deleteDatabase(path);
  }
}

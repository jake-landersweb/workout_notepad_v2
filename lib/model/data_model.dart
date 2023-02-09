// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/load_tests.dart';
import 'package:path/path.dart';

enum LoadStatus { init, noUser, done }

class DataModel extends ChangeNotifier {
  DataModel() {
    initTest(delete: false);
  }

  LoadStatus loadStatus = LoadStatus.init;

  MaterialColor color = Colors.deepPurple;
  Future<void> setColor(String c) async {
    var prefs = await SharedPreferences.getInstance();
    var r = await prefs.setString("color", c);
    if (r) {
      color = appColorMap[c]!;
    }
    notifyListeners();
  }

  bool? isLight;
  Future<void> setIsLight(bool val) async {
    var prefs = await SharedPreferences.getInstance();
    var r = await prefs.setBool("isLight", val);
    if (r) {
      isLight = val;
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
      setColor(c);
    }

    // set color scheme
    var il = prefs.getBool("isLight");
    if (il != null) {
      setIsLight(il);
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
      setColor(c);
    }

    // set color scheme
    var il = prefs.getBool("isLight");
    if (il != null) {
      setIsLight(il);
    }

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

  Color accentColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return color[600]!;
    } else {
      return color[200]!;
    }
  }

  Color cellColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return color[100]!;
    } else {
      return color[500]!;
    }
  }
}

final List<MaterialColor> appColors = [
  Colors.blue,
  Colors.blueGrey,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.green,
  Colors.grey,
  Colors.indigo,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.lime,
  Colors.orange,
  Colors.pink,
  Colors.purple,
  Colors.red,
  Colors.teal,
];

final Map<String, MaterialColor> appColorMap = {
  Colors.blue.toString(): Colors.blue,
  Colors.blueGrey.toString(): Colors.blueGrey,
  Colors.brown.toString(): Colors.brown,
  Colors.cyan.toString(): Colors.cyan,
  Colors.deepOrange.toString(): Colors.deepOrange,
  Colors.deepPurple.toString(): Colors.deepPurple,
  Colors.green.toString(): Colors.green,
  Colors.grey.toString(): Colors.grey,
  Colors.indigo.toString(): Colors.indigo,
  Colors.lightBlue.toString(): Colors.lightBlue,
  Colors.lightGreen.toString(): Colors.lightGreen,
  Colors.lime.toString(): Colors.lime,
  Colors.orange.toString(): Colors.orange,
  Colors.pink.toString(): Colors.pink,
  Colors.purple.toString(): Colors.purple,
  Colors.red.toString(): Colors.red,
  Colors.teal.toString(): Colors.teal,
};

MaterialColor getAppColor(String color) {
  return appColorMap[color] ?? Colors.deepPurple;
}

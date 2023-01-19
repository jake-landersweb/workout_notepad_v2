import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/load_tests.dart';
import 'package:path/path.dart';

enum LoadStatus { init, noUser, done }

class DataModel extends ChangeNotifier {
  LoadStatus loadStatus = LoadStatus.init;
  MaterialColor color = Colors.deepPurple;

  User? _user;
  User? get user => _user;

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;
  List<Exercise> _exercises = [];
  List<Exercise> get exercises => _exercises;

  DataModel() {
    initTest(delete: true);
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
    _user = await User.fromId(prefs.getString("userId")!);
    if (user == null) {
      log("[INIT] userId in prefs is invalid");
      prefs.remove("userId");
      // create new user
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }

    log("[INIT] User exists");

    // get all user data
    await fetchData(user!.id);
    loadStatus = LoadStatus.done;
    notifyListeners();
  }

  Future<void> initTest({bool? delete}) async {
    if (delete ?? false) {
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
      User u = User.init();
      u.id = "1";
      await u.insert();
      await loadTests();
    }
    await fetchData("1");
  }

  Future<void> fetchData(String userId) async {
    var getC = Category.getList(userId);
    var getW = Workout.getList(userId);
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

// ignore_for_file: depend_on_referenced_packages, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/home.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:http/http.dart' as http;

enum LoadStatus { init, noUser, done, expired }

class DataModel extends ChangeNotifier {
  HomeScreen _currentTabScreen = HomeScreen.overview;
  HomeScreen get currentTabScreen => _currentTabScreen;
  void setTabScreen(HomeScreen screen) {
    _currentTabScreen = screen;
    notifyListeners();
  }

  User? user;
  User? expiredAnonUser;
  LoadStatus loadStatus = LoadStatus.init;
  Color color = const Color(0xFF418a2f);
  List<SnapshotMetadataItem> currentMetadata = [];

  DataModel() {
    init();
  }

  Future<void> createAnonymousUser(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
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
    prefs.setString("user", jsonEncode(u.toMap()));
    await init(u: u);
  }

  Future<void> loginUser(
    BuildContext context,
    auth.UserCredential credential,
  ) async {
    var prefs = await SharedPreferences.getInstance();
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
    prefs.setString("user", jsonEncode(u.toMap()));
    await init(u: u);
  }

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  Future<void> refreshCategories() async {
    _categories = await Category.getList();
    notifyListeners();
  }

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;
  Future<void> refreshWorkouts() async {
    _workouts = await Workout.getList();
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

  List<Collection> _collections = [];
  List<Collection> get collections => _collections;
  Future<void> refreshCollections() async {
    _collections = await Collection.getList();
  }

  CollectionItem? _nextWorkout;
  CollectionItem? get nextWorkout => _nextWorkout;
  Future<void> refreshNextWorkout() async {
    _getNextWorkout();
    notifyListeners();
  }

  List<Snapshot> _snapshots = [];
  List<Snapshot> get snapshots => _snapshots;

  Future<void> init({User? u}) async {
    var prefs = await SharedPreferences.getInstance();

    // set to index page
    _currentTabScreen = HomeScreen.overview;
    notifyListeners();

    // TODO delete and re-create
    // await importData();

    // check for saved userId
    if (!prefs.containsKey("user")) {
      print("[INIT] user not saved in preferences");
      await clearData();
      return;
    }

    // get the saved user
    user = User.fromJson(jsonDecode(prefs.getString("user")!));

    // check to make sure the expire epoch is valid
    if (user!.expireEpoch != -1 &&
        user!.expireEpoch < DateTime.now().millisecondsSinceEpoch) {
      // user is not longer valid
      print("[INIT] The anon user has expired");
      await clearData(ls: LoadStatus.expired);
      return;
    }

    print("[INIT] app state is valid. Fetching user in background to ensure");
    getUser(); // run non-asynchonously to allow for no internet
    await fetchData();
    loadStatus = LoadStatus.done;
    notifyListeners();
  }

  /// run the get user call in a separate function to allow for
  /// offline app usage. If the user gets online, then we can run this function
  /// to check if the user is back online. Then can verify user data
  Future<void> getUser() async {
    try {
      if (user == null) {
        print("[GET_USER] ERROR the user was null");
        await clearData();
        return;
      }

      // TODO for testing offline
      // throw "";

      // TODO testing time taking data to load
      // await Future.delayed(const Duration(seconds: 5));

      // get the user
      var tmp = await User.fromId(user!.userId);
      if (tmp == null) {
        print("[GET_USER] There was no user found with the userId");
        await clearData();
        return;
      }

      print("[GET_USER] valid user found in AWS");

      if (tmp.isAnon) {
        print("[GET_USER] Anon user");
        // check if expired
        if (tmp.expireEpoch < DateTime.now().millisecondsSinceEpoch) {
          print("[GET_USER] This anon user is expired");
          await clearData(ls: LoadStatus.expired);
          return;
        } else {
          print("[GET_USER] Anon user is valid");
          user = tmp;
        }
      } else {
        // user not anon, make sure there is a valid firebase instance
        auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          print("[GET_USER] No user loaded in firebase");
          await clearData();
          return;
        } else {
          print("[GET_USER] valid firebase user");
          print(firebaseUser);
          user = tmp;
        }
      }

      print("[GET_USER] the user is valid");
      print(user);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(user!.toMap()));
      notifyListeners();
      // do not snapshot anon data
      if (!user!.isAnon) {
        handleSnapshotInit();
      }
    } catch (error) {
      print(
          "GET_USER there was an error fetching the user. Assuming user is offline");
      user!.offline = true;
      notifyListeners();
    }
  }

  // fetched and determines whether a snapshot needs to be created
  // on init
  Future<void> handleSnapshotInit() async {
    // get the user snapshots
    var snp = await Snapshot.getList(user!.userId);
    if (snp == null) {
      print("There was an issue fetching all snapshots");
      // TODO -- handle errors
      return;
    }
    if (snp.isEmpty) {
      await snapshotData();
      return;
    }

    if (snp.first.created <
        DateTime.now()
            .subtract(const Duration(hours: 8))
            .millisecondsSinceEpoch) {
      print(
        "last snapshot is older than 8 hours, creating a new snapshot",
      );
      var sn = await Snapshot.snapshotDatabase(user!.userId);
      if (sn == null) {
        print("There was an error snapshotting the data");
        return;
      }
      var snp = await Snapshot.getList(user!.userId);
      if (snp == null) {
        print("There was an issue getting the new snapshot list");
        return;
      }
      _snapshots = snp;
      notifyListeners();
    } else {
      print("The user's snapshots are up to date");
      // snapshots are up to date
      _snapshots = snp;
      notifyListeners();
    }
  }

  Future<bool> snapshotData() async {
    // do not snapshot anon data
    if (user!.isAnon) {
      return true;
    }
    // snapshot the data for the first time
    var snps = await Snapshot.snapshotDatabase(user!.userId);
    if (snps == null) {
      // TODO -- handle errors
      print("There was an issue creating the snapshot");
      return false;
    }
    _snapshots = snps;
    notifyListeners();
    return true;
  }

  Future<void> fetchData() async {
    var db = await getDB();
    var getC = Category.getList(db: db);
    var getW = Workout.getList(db: db);
    var getE = Exercise.getList(db: db);
    var getT = Tag.getList(db: db);
    var getCo = Collection.getList(db: db);
    var getNW = _getNextWorkout(db: db);
    var getMD = currentDataMetadata(db: db);

    // run all asynchronously at the same time
    List<dynamic> results =
        await Future.wait([getC, getW, getE, getT, getCo, getNW, getMD]);

    _categories = results[0];
    _workouts = results[1];
    _exercises = results[2];
    _tags = results[3];
    _collections = results[4];
    _nextWorkout = results[5];
    currentMetadata = results[6];
    notifyListeners();
  }

  bool? _lightStatus;
  bool? get lightStatus => _lightStatus;
  void toggleLightStatus(bool? status) {
    _lightStatus = status;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // create a snapshot of their data
    var sn = await Snapshot.snapshotDatabase(user!.userId);
    var cont = true;
    if (sn == null) {
      await showAlert(
        context: context,
        title: "An Error Occured",
        body: Text(
            "There was an issue creating a snapshot of your exercise data, if you logout now, you may lose your workout information."),
        cancelText: "Cancel",
        cancelBolded: true,
        onCancel: () {
          cont = false;
        },
        submitColor: Colors.red,
        submitText: "I'm Sure",
        onSubmit: () {
          cont = true;
        },
      );
    }
    if (cont) {
      await deleteDB();
      await clearData();
      notifyListeners();
    }
  }

  Future<void> clearData({LoadStatus ls = LoadStatus.noUser}) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    user = null;
    loadStatus = ls;
    notifyListeners();
  }

  LaunchWorkoutModelState? workoutState;
  Future<LaunchWorkoutModelState> createWorkoutState(
    Workout workout, {
    CollectionItem? collectionItem,
    bool isEmpty = false,
  }) async {
    workoutState = null;
    notifyListeners();
    workoutState = LaunchWorkoutModelState(
      workout: workout,
      exercises: [],
      pageController: PageController(initialPage: 0),
      wl: WorkoutLog.init(workout),
      startTime: DateTime.now(),
      collectionItem: collectionItem,
      isEmpty: isEmpty,
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
          eid: workoutState!.exercises[i].exerciseId,
          wlid: workoutState!.wl.workoutLogId,
          exercise: workoutState!.exercises[i],
          defaultTag: tags.firstWhereOrNull((element) => element.isDefault),
        ),
      );

      // create the logs for the children as well
      workoutState!.exerciseChildLogs.add([]);
      for (var j in tmp) {
        workoutState!.exerciseChildLogs[i].add(
          ExerciseLog.exerciseSetInit(
            eid: j.childId,
            parentEid: j.parentId,
            wlid: workoutState!.wl.workoutLogId,
            exercise: j,
            defaultTag: tags.firstWhereOrNull((element) => element.isDefault),
          ),
        );
      }
    }
    return workoutState!;
  }

  Future<void> stopWorkout({bool isCancel = false}) async {
    if (workoutState!.isEmpty && isCancel) {
      print("Deleting this temporary workout");
      var db = await getDB();
      await db.rawQuery(
        "DELETE from workout WHERE workoutId = '${workoutState!.workout.workoutId}'",
      );
    }
    if (!isCancel) {
      // create a snapshot of the database in background
      snapshotData();
    }
    workoutState = null;
    await fetchData();
    notifyListeners();
  }

  Future<CollectionItem?> _getNextWorkout({Database? db}) async {
    db ??= await getDB();
    CollectionItem? nextWorkout;

    // next workout
    var yesterday = DateTime.now().subtract(const Duration(days: 1));
    var response = await db.rawQuery("""
      SELECT ci.*, c.title
      FROM collection_item ci
      JOIN collection c ON ci.collectionId = c.collectionId
      WHERE ci.date > '${yesterday.millisecondsSinceEpoch}'
      AND ci.workoutLogId IS NULL
      ORDER BY ci.date LIMIT 1
    """);
    if (response.isNotEmpty) {
      nextWorkout = await CollectionItem.fromJson(response[0]);
    }

    return nextWorkout;
  }

  /// a list of metadata objects that reflect the current state of the database
  Future<List<SnapshotMetadataItem>> currentDataMetadata({Database? db}) async {
    db ??= await getDB();
    // get all table names
    var response =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    List<SnapshotMetadataItem> data = [];

    for (var i in response) {
      var r = await db.query(i['name'] as String);
      data.add(
        SnapshotMetadataItem(table: i['name'] as String, length: r.length),
      );
    }
    return data;
  }

  //
  Future<bool> importSnapshot(
    Snapshot snapshot, {
    bool delete = true,
  }) async {
    try {
      print("IMPORTING DATA");
      if (delete) {
        String path = join(await getDatabasesPath(), 'workout_notepad.db');
        await databaseFactory.deleteDatabase(path);
      }
      // load / create database
      var db = await getDB();

      // read file
      // String json = await rootBundle.loadString("sql/init.json");
      // Map<String, dynamic> data = const JsonDecoder().convert(json);
      // // remove dynamodb fields
      // data.remove("id");
      // data.remove("created");

      // get the snapshot file data
      var data = await snapshot.getFileData();
      if (data == null) {
        print("There was an issue importing the data");
        return false;
      }

      for (var key in data.keys) {
        for (var i in data[key]) {
          await db.insert(
            key,
            i,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await init();
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> deleteDB() async {
    String path = join(await getDatabasesPath(), 'workout_notepad.db');
    await databaseFactory.deleteDatabase(path);
  }
}

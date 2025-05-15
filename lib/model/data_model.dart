// ignore_for_file: depend_on_referenced_packages, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';
import 'package:workout_notepad_v2/data/workout_template_exercise.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/logger/events/generic.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:workout_notepad_v2/model/env.dart';
import 'package:workout_notepad_v2/model/pocketbaseAuth.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';

enum LoadStatus { init, noUser, done, expired }

enum LoadingStatus { loading, error, done }

enum SyncStatus { loading, inSync, outOfSync, error }

enum PaymentLoadStatus {
  none,
  loading,
  complete,
  paymentError,
  verifyError,
  error
}

class DataModel extends ChangeNotifier {
  // global client to use
  final client = Client(client: http.Client());
  final purchaseClient = GoClient(client: http.Client());

  PocketBase? pb;

  User? user;
  User? expiredAnonUser;
  SubscriptionRecord? subscription;
  LoadStatus loadStatus = LoadStatus.init;
  Color color = const Color(0xFF418a2f);
  PaymentLoadStatus paymentLoadStatus = PaymentLoadStatus.none;
  bool hasNoData = false;
  bool showRecommendedUpdate = false;
  bool hasRecommendedUpdate = false;
  bool showForcedUpdate = false;
  String? currentPromoCode;
  SyncStatus dataSyncStatus = SyncStatus.loading;
  bool showPostWorkoutScreen = false;

  DataModel({String? defaultUser}) {
    init(defaultUser: defaultUser);
  }

  Future<void> createAnonymousUser(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    var u = await User.loginAnon();
    if (u == null) {
      snackbarErr(context, "There was an issue getting your account.");
      return;
    }
    prefs.setString("user", jsonEncode(u.toMap()));
    await init(u: u);
  }

  Future<void> loginUserPocketbase(
    BuildContext context, {
    required String userId,
    required String email,
    required String provider,
    String displayName = "",
    String avatar = "",
  }) async {
    print("LOGIN");
    loadStatus = LoadStatus.init;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    var u = await User.loginPocketbase(
      userId: userId,
      email: email,
      provider: provider,
      displayName: displayName,
      avatar: avatar,
      convertFromAnon: user != null,
      anonUserId: user?.anonUserId,
    );
    if (u == null) {
      snackbarErr(context, "There was an issue getting your account.");
      loadStatus = LoadStatus.noUser;
      notifyListeners();
      return;
    }
    prefs.setString("user", jsonEncode(u.toMap()));
    if (user == null) {
      // check if there are snapshots for this user
      var serverSnapshots = await Snapshot.getList(u.userId);
      // import the first snapshot as the user's data
      if (serverSnapshots != null && serverSnapshots.isNotEmpty) {
        // sorted by first = latest on server
        await importSnapshot(serverSnapshots.first);
      }
    } else {
      // save on the user
      u.anonUserId = user!.userId;
      prefs.setString("user", jsonEncode(u.toMap()));
    }
    await init(u: u);
  }

  Future<void> init({User? u, String? defaultUser}) async {
    // set default metadata for the logger
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    logger.setAttribute("app_version", packageInfo.version);
    logger.setAttribute("app_buildNumber", packageInfo.buildNumber);
    logger.setAttribute("app_store", packageInfo.installerStore);

    print("INIT");
    loadStatus = LoadStatus.done;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();

    // for pumping information with tests
    if (defaultUser != null) {
      prefs.setString("user", defaultUser);
    }

    // create the pb client
    pb = PocketBase(
      'https://pocketbase.sapphirenw.com',
      authStore: SharedPreferencesAuthStore(prefs),
    );

    // check for saved userId
    if (!prefs.containsKey("user")) {
      print("[INIT] user not saved in preferences");
      await clearData();
      return;
    }

    // var db = await DatabaseProvider().database;
    // await db.rawQuery("DELETE FROM workout_template");
    // var db = await DatabaseProvider().database;
    // var resp = await db.rawQuery("SELECT * FROM workout_template_exercise");
    // print(resp);

    // get the saved user
    user = User.fromJson(jsonDecode(prefs.getString("user")!));

    // set some global logger attributes
    logger.setAttribute("user.userId", user!.userId);
    logger.setAttribute("user.subscriptionType", user!.subscriptionType.name);
    logger.setAttribute("user.email", user!.email ?? "");

    print("userId = ${user!.userId}");

    // init revenue cat
    await initRevenueCat(user!);

    // check to make sure the expire epoch is valid
    if (user!.expireEpoch != -1 &&
        user!.expireEpoch < DateTime.now().millisecondsSinceEpoch) {
      // user is not longer valid
      print("[INIT] The anon user has expired");
      print(user!.expireEpoch);
      print(DateTime.fromMillisecondsSinceEpoch(user!.expireEpoch));
      print(DateTime.now());
      loadStatus = LoadStatus.expired;
      notifyListeners();
      return;
    }

    print("[INIT] app state is valid. Fetching user in background to ensure");
    await fetchData();
    getUser(); // run non-asynchonously to allow for no internet
    // getSubscription(user!.userId); // get subscription status async as well
    checkUpdate(); // get app version asynchronously as well
    checkWorkoutState(); // see if there is a workout launch state to load
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
      var userResponse = await User.fromId(user!.userId);

      // only clear data if the response from the server told us this user does not exist
      if (userResponse.v1 == 404) {
        await clearData();
        return;
      }

      // legacy error throwing
      if (userResponse.v2 == null) {
        throw "user is null, unknown error";
      }

      // legacy variable
      var tmp = userResponse.v2!;
      print("[GET_USER] valid user found in AWS");

      if (tmp.isAnon) {
        print("[GET_USER] Anon user");
        // check if expired
        if (tmp.expireEpoch < DateTime.now().millisecondsSinceEpoch) {
          print("[GET_USER] This anon user is expired");
          loadStatus = LoadStatus.expired;
          notifyListeners();
          return;
        } else {
          print("[GET_USER] Anon user is valid");
          user = tmp;
        }
      } else {
        // TODO -- replace with pocketbase auth
        // // user not anon, make sure there is a valid firebase instance
        // auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
        // if (firebaseUser == null) {
        //   print("[GET_USER] No user loaded in firebase");
        //   user = tmp;

        //   // ignore this
        //   // await clearData();
        //   // return;
        // } else {
        //   print("[GET_USER] valid firebase user");
        //   print(firebaseUser);
        //   user = tmp;
        // }
        user = tmp;
      }

      print("[GET_USER] the user is valid");
      print(user);
      var prefs = await SharedPreferences.getInstance();
      prefs.setString("user", jsonEncode(user!.toMap()));
      logger.setAttribute("user.subscriptionType", user!.subscriptionType.name);

      notifyListeners();
      // do not snapshot anon data
      if (!user!.isAnon) {
        handleSnapshotInit();
      }
    } catch (error, stack) {
      logger.exception(error, stack);
      print(
          "GET_USER there was an error fetching the user. Assuming user is offline");
      notifyListeners();
    }
  }

  Future<void> getSubscription(String userId) async {
    try {
      // check for offline record for the user
      var prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("subscription")) {
        subscription = SubscriptionRecord.fromJson(
            jsonDecode(prefs.get("subscription") as String));
        print("Found saved record: active=${subscription!.active}");
        notifyListeners();
      }

      print("Checking for a subscription record ...");
      var s = await SubscriptionRecord.fromUserId(userId);
      subscription = s;
      if (subscription != null) {
        print("Record found. active=${subscription!.active}");
        prefs.setString("subscription", jsonEncode(subscription!.toJson()));
      }
      notifyListeners();
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
    }
    print(subscription);
  }

  // fetched and determines whether a snapshot needs to be created
  // on init
  Future<void> handleSnapshotInit() async {
    // get the user snapshots
    var serverSnapshots = await Snapshot.getList(user!.userId);
    if (serverSnapshots == null) {
      print("There was an issue fetching all snapshots");
      // TODO -- handle errors
      return;
    }
    if (serverSnapshots.isEmpty) {
      await snapshotData();
      return;
    }

    var shouldSnapshot = false;

    var currSnap = await Snapshot.databaseSignature(user!.userId);
    checkForReview(currSnap);

    if (serverSnapshots.first.sha256Hash == null) {
      print(
          "The snapshot does not contain a hash, using old method to compare database");
      shouldSnapshot = !currSnap.compareMetadata(serverSnapshots.first);
    } else {
      var localContent = await Snapshot.getLocalData();
      logger.info("comparing sha256", {
        "device": localContent['sha256Hash'],
        "server": serverSnapshots.first.sha256Hash
      });
      shouldSnapshot =
          localContent['sha256Hash'] != serverSnapshots.first.sha256Hash!;
    }

    // check if there is a need for a snapshot
    // ask for review in the background
    if (shouldSnapshot) {
      print("snapshot signatures do not match, snapshotting data");

      var response = await snapshotData();
      if (!response) {
        print("There was an error snapshotting the data");
        return;
      }
      var newSnapshots = await Snapshot.getList(user!.userId);
      if (newSnapshots == null) {
        print("There was an issue getting the new snapshot list");
        return;
      }
      _snapshots = newSnapshots;
      notifyListeners();
    } else {
      print("The current snapshot signature matches the current data");
      // snapshots are up to date
      _snapshots = serverSnapshots;
      dataSyncStatus = SyncStatus.inSync;
      notifyListeners();
    }
  }

  Future<bool> snapshotData() async {
    try {
      dataSyncStatus = SyncStatus.loading;
      notifyListeners();
      // do not snapshot in debug mode
      if (foundation.kDebugMode) {
        dataSyncStatus = SyncStatus.inSync;
        notifyListeners();
        return true;
      }

      // do not snapshot anon data
      if (user!.isAnon) {
        dataSyncStatus = SyncStatus.inSync;
        notifyListeners();
        return true;
      }

      // snapshot the data
      var snps = await Snapshot.snapshotDatabase(user!.userId);
      if (snps == null) {
        throw "There was an issue creating the snapshot";
      }
      logger.info("snapshot created");
      _snapshots = snps;
      dataSyncStatus = SyncStatus.inSync;
      notifyListeners();
      return true;
    } catch (e, s) {
      logger.exception(e, s);
      dataSyncStatus = SyncStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchData({bool checkData = true}) async {
    try {
      var db = await DatabaseProvider().database;
      var getC = Category.getList(db: db);
      var getW = Workout.getList(db: db);
      var getDw = Workout.getTemplates(db: db);
      var getWt = WorkoutTemplate.getLocalTemplates(db: db);
      var getE = Exercise.getList(db: db);
      var getT = Tag.getList(db: db);

      // run all asynchronously at the same time
      List<dynamic> results = await Future.wait(
        [getC, getW, getDw, getWt, getE, getT],
      );

      _categories = results[0];
      _workouts = results[1];
      _defaultWorkouts = results[2];
      _workoutTemplates = results[3];
      _exercises = results[4];
      _tags = results[5];
      _allWorkouts = await _getAllWorkouts();

      // check if the user has data
      if (checkData) {
        if (workouts.isEmpty && exercises.isEmpty) {
          // check if there are snapshots for this user
          var serverSnapshots = await Snapshot.getList(user!.userId);
          if (serverSnapshots != null && serverSnapshots.isNotEmpty) {
            // sorted by first = latest on server
            await importSnapshot(serverSnapshots.first);
          } else {
            print("user has no data, adding basic data");
            // add some base categories and tags
            await importDefaults();
            hasNoData = true;
          }
        }
      }
      notifyListeners();
    } catch (error, stack) {
      print(error);
      print(stack);
    }
  }

  bool? _lightStatus;
  bool? get lightStatus => _lightStatus;
  void toggleLightStatus(bool? status) {
    _lightStatus = status;
    notifyListeners();
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

  List<Workout> _defaultWorkouts = [];
  List<Workout> get defaultWorkouts => _defaultWorkouts;
  Future<void> refreshDefaultWorkouts() async {
    _defaultWorkouts = await Workout.getTemplates();
    notifyListeners();
  }

  List<WorkoutTemplate> _workoutTemplates = [];
  List<WorkoutTemplate> get workoutTemplates => _workoutTemplates;
  Future<void> refreshWorkoutTemplates() async {
    _workoutTemplates = await WorkoutTemplate.getLocalTemplates();
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

  List<Workout> _allWorkouts = [];
  List<Workout> get allWorkouts => _allWorkouts;
  Future<void> refreshAllWorkouts() async {
    _allWorkouts = await _getAllWorkouts();
    notifyListeners();
  }

  Future<List<Workout>> _getAllWorkouts() async {
    var db = await DatabaseProvider().database;

    var res = await db.rawQuery("""
      WITH
        -- 1) For each workoutId that appears in workout_log, pick its latest timestamp
        last_logs AS (
          SELECT
            workoutId,
            MAX(created) AS last_log
          FROM   workout_log
          GROUP  BY workoutId
        ),

        -- 2) Union the two "sources" into one list, one row per workoutId
        base AS (
          SELECT
            w.workoutId       AS workoutId,
            w.title           AS title,
            w.description     AS description,
            w.icon            AS icon,
            w.template        AS is_template,
            w.created         AS created,
            w.updated         AS updated,
            NULL              AS id,
            NULL              AS keywords,
            NULL              AS metadata,
            NULL              AS level,
            NULL              AS estTime,
            NULL              AS backgroundColor,
            NULL              AS imageId,
            NULL              AS sha256,
            NULL              AS createdAt,
            NULL              AS updatedAt
          FROM   workout AS w

          UNION ALL

          SELECT
            t.workoutId       AS workoutId,
            t.title           AS title,
            t.description     AS description,
            NULL              AS icon,
            NULL              AS is_template,
            NULL              AS created,
            NULL              AS updated,
            t.id              AS id,
            t.keywords        AS keywords,
            t.metadata        AS metadata,
            t.level           AS level,
            t.estTime         AS estTime,
            t.backgroundColor AS backgroundColor,
            t.imageId         AS imageId,
            t.sha256          AS sha256,
            t.createdAt       AS createdAt,
            t.updatedAt       AS updatedAt
          FROM   workout_template AS t
        )

      -- 3) LEFT JOIN to last_logs to pull in the most recent log time (if any)
      SELECT
        b.*,
        ll.last_log AS last_log
      FROM base AS b
      LEFT JOIN last_logs AS ll
        ON b.workoutId = ll.workoutId

      -- Order by the maximum of workout creation date and last log date
      -- For workout table, use created; for workout_template table, use createdAt
      ORDER BY
        CASE
          WHEN ll.last_log IS NOT NULL THEN
            MAX(COALESCE(b.created, b.createdAt), ll.last_log)
          ELSE
            COALESCE(b.created, b.createdAt)
        END DESC;
    """);

    List<Workout> response = [];

    for (var i in res) {
      if (i['id'] != null) {
        // workout template
        var template = WorkoutTemplate.fromJson({"template": i});
        template.fetchChildren(db: db);
        response.add(template);
      } else {
        // normal workout
        response.add(await Workout.fromJson(i));
      }
    }

    print(response.length);
    return response;
  }

  CollectionItem? _nextWorkout;
  CollectionItem? get nextWorkout => _nextWorkout;
  Future<void> refreshNextWorkout() async {
    // _getNextWorkout();
    // notifyListeners();
  }

  List<Snapshot> _snapshots = [];
  List<Snapshot> get snapshots => _snapshots;

  // templates
  List<WorkoutTemplate>? remoteTemplates;
  bool loadingRemoteTemplates = true;

  Future<void> logout(BuildContext context) async {
    // create a snapshot of their data
    // var response = await snapshotData();
    var cont = true;
    // if (!response) {
    //   await showAlert(
    //     context: context,
    //     title: "An Error Occured",
    //     body: Text(
    //         "There was an issue creating a snapshot of your exercise data, if you logout now, you may lose some data."),
    //     cancelText: "Cancel",
    //     cancelBolded: true,
    //     onCancel: () {
    //       cont = false;
    //     },
    //     submitColor: Colors.red,
    //     submitText: "I'm Sure",
    //     onSubmit: () {
    //       cont = true;
    //     },
    //   );
    // }
    if (cont) {
      await deleteDB();
      await clearData();
      await Purchases.logOut();
    }
    notifyListeners();
  }

  Future<void> delete() async {
    // create a snapshot of their data
    await snapshotData();
    await user!.delete();
    await deleteDB();
    await clearData();
    notifyListeners();
  }

  Future<void> clearData({LoadStatus ls = LoadStatus.noUser}) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    user = null;
    loadStatus = ls;
    if (pb != null) {
      pb!.authStore.clear();
    }
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
      userId: user!.userId,
    );
    if (workoutState!.exercises.isEmpty) {
      // get the exercise children
      if (workoutState!.workout is WorkoutTemplate) {
        workoutState!.exercises = workoutState!.workout
            .getExercises()
            .map((group) => group
                .map((e) => (e as WorkoutTemplateExercise).toWorkoutExercise())
                .toList())
            .toList();
      } else {
        workoutState!.exercises = await workoutState!.workout.getChildren();
      }
    }

    // create the exercise log state
    for (int i = 0; i < workoutState!.exercises.length; i++) {
      List<ExerciseLog> logs = [];
      for (int j = 0; j < workoutState!.exercises[i].length; j++) {
        // create the log group for each exercise
        var wl = ExerciseLog.workoutInit(
          workoutLog: workoutState!.wl,
          exercise: workoutState!.exercises[i][j],
          defaultTag: tags.firstWhereOrNull((element) => element.isDefault),
        );
        logs.add(wl);
      }
      workoutState!.exerciseLogs.add(logs);
    }

    logger.info("user starting workout", {
      "workoutId": workoutState!.workout.workoutId,
      "title": workoutState!.workout.title,
    });
    return workoutState!;
  }

  Future<void> stopWorkout({bool isCancel = false}) async {
    if (workoutState!.isEmpty && isCancel) {
      print("Deleting this temporary workout");
      var db = await DatabaseProvider().database;
      await db.rawQuery(
        "DELETE from workout WHERE workoutId = '${workoutState!.workout.workoutId}'",
      );
    }
    if (!isCancel) {
      // create a snapshot of the database in background
      snapshotData();
      logger.info("user finished workout");
    } else {
      logger.info("user cancelled workout");
    }
    // delete the temp file if created
    await workoutState!.deleteFile();
    workoutState = null;
    await fetchData();
    notifyListeners();
  }

  Future<bool> importSnapshot(Snapshot snapshot) async {
    try {
      print("IMPORTING DATA");
      loadStatus = LoadStatus.init;
      notifyListeners();
      var dbProvider = DatabaseProvider();
      var r = await dbProvider.delete();
      if (!r) {
        print("there was an issue deleting the database");
        return false;
      }
      var db = await DatabaseProvider().database;

      // compose list of valid tables
      var tableResponse = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      var validTables = [for (var i in tableResponse) i['name']];
      var invalidTables = ["android_metadata"];

      // get the snapshot file data
      var data = await snapshot.getRemoteFileData();
      if (data == null) {
        print("There was an issue importing the data");
        return false;
      }

      print("performing transaction");
      await db.transaction((txn) async {
        for (var key in data.keys) {
          if (validTables.contains(key) && !invalidTables.contains(key)) {
            for (var i in data[key]) {
              await txn.insert(
                key,
                i,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        }
      });

      await init();
      notifyListeners();
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  Future<void> checkForReview(Snapshot databaseSig) async {
    if (user == null) {
      return;
    }
    if (user!.created == null) {
      return;
    }
    var numWorkouts = databaseSig.metadata
        .firstWhereOrNull((element) => element.table == "workout");
    if (numWorkouts == null) {
      return;
    }
    if (numWorkouts.length == 0) {
      return;
    }

    var prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("asked_review")) {
      return;
    }

    // check for specific requirements
    if (user!.created! >
        DateTime.now().add(Duration(days: 3)).millisecondsSinceEpoch) {
      // ask for review
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        await prefs.setBool("asked_review", true);
      }
    }
  }

  Future<void> checkUpdate() async {
    print("debug [UPDATE] checking for required update asynchronously ...");
    var prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // send the request
    var response = await client.fetch("/mobile-metadata/$currentVersion");

    // check for errors
    if (response.statusCode != 200) {
      print(
          "debug [UPDATE] there was an issue checking for the mobile metadata");
      return;
    }

    // parse the body
    Map<String, dynamic> body = jsonDecode(response.body);

    if (body['status'] != 200) {
      print("debug [UPDATE] there was an issue with the request: $body");
      return;
    }

    // check rules for showing an update screen
    if (body['body']['force_update']) {
      print("debug [UPDATE] a forced update has been detected");
      // show non-dismissable model
      showForcedUpdate = true;
    } else if (body['body']['recommend_update']) {
      hasRecommendedUpdate = true;
      print("debug [UPDATE] a recommended update has been detected");
      // check if this version has already been recommended
      var rec = prefs.get("recommend_version");
      if ((rec ?? currentVersion) != body['body']['current_version']) {
        print("debug [UPDATE] showing the recommended update screen");
        // show recommend alert
        showRecommendedUpdate = true;

        // update the stored value so the alert does not fire again
        prefs.setString("recommend_version", body['body']['current_version']);
      }
    }
    print("debug [UPDATE] successfully checked");
    notifyListeners();
  }

  // see if there is a valid workout state that was dumped on program exit
  Future<void> checkWorkoutState() async {
    print("checking for a saved workout state ...");
    var s = await LaunchWorkoutModelState.loadFromFile();
    if (s != null) {
      print("saved workout state found, relaunching workout");
      workoutState = s;
      notifyListeners();
    } else {
      print("no saved state found");
    }
  }

  Future<void> toggleShowPostWorkoutScreen() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    showPostWorkoutScreen = true;
    notifyListeners();
  }

  Future<bool> importTests() async {
    try {
      await deleteDB();
      await importDefaults();
      String json = await rootBundle.loadString("sql/templates.json");
      Map<String, dynamic> data = const JsonDecoder().convert(json);

      var db = await DatabaseProvider().database;

      for (var key in data.keys) {
        if (key != "exercise") continue;
        for (var i in data[key]) {
          await db.insert(
            key,
            i,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print("successfully added testing data");
      await fetchData(checkData: false);
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  Future<bool> importOldData() async {
    try {
      await deleteDB();
      // await importDefaults();
      String json = await rootBundle.loadString("sql/new-data.json");
      Map<String, dynamic> data = const JsonDecoder().convert(json);

      var db = await DatabaseProvider().database;

      for (var key in data.keys) {
        for (var i in data[key]) {
          await db.insert(
            key,
            i,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print("successfully added testing data");
      await fetchData(checkData: false);
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  Future<bool> importDefaults() async {
    try {
      String json = await rootBundle.loadString("sql/pre-init.json");
      Map<String, dynamic> data = const JsonDecoder().convert(json);

      var db = await DatabaseProvider().database;

      for (var key in data.keys) {
        for (var i in data[key]) {
          await db.insert(
            key,
            i,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print("successfully added default data");
      await fetchData(checkData: false);
      return true;
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  Future<void> deleteDB() async {
    await DatabaseProvider().delete();
  }

  bool hasValidSubscription() {
    // return false;
    // legacy users
    if ((user?.subscriptionType ?? "") == SubscriptionType.wn_unlocked) {
      return true;
    }

    // use the field set from revenue cat
    return _hasValidEntitlement;
  }

  Future<void> initRevenueCat(User user) async {
    try {
      logger.debug("Initializing RevenueCat");
      await Purchases.setLogLevel(LogLevel.debug);

      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(RC_GOOG_API_KEY);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(RC_APPL_API_KEY);
      } else {
        logger.error(
            "invalid platform detected when initializting the RevenueCat sdk");
        return;
      }

      await Purchases.configure(configuration..appUserID = user.userId);

      logger.debug("Successfully configured RevenueCat");

      // init the check on whether the user has the entitlement or not
      await _checkUserHasValidEntitlement();

      // add a listener to ensure the status is updated in real time
      Purchases.addCustomerInfoUpdateListener((customerInfo) async {
        _checkUserHasValidEntitlement(customerInfo: customerInfo);
      });
      logger.debug("Successfully initialized RevenueCat");
    } catch (e, stack) {
      logger.exception(e, stack, message: "failed to init RevenueCat");
    }
  }

  bool _hasValidEntitlement = false;
  Future<void> _checkUserHasValidEntitlement({
    CustomerInfo? customerInfo,
  }) async {
    customerInfo ??= await Purchases.getCustomerInfo();
    EntitlementInfo? entitlement =
        customerInfo.entitlements.all[RC_ENTITLEMENT_ID];
    _hasValidEntitlement = entitlement?.isActive ?? false;

    logger.event(
      GenericEvent("revenue-cat-entitlement-change", metadata: {
        "allPurchaseDates": customerInfo.allPurchaseDates,
        "activeSubscriptions": customerInfo.activeSubscriptions,
        "isActive": entitlement?.isActive,
      }),
    );

    notifyListeners();
  }
}

extension IAPUtils on PurchaseDetails {
  Map<String, dynamic> toMap() {
    return {
      "error": {
        "code": error?.code,
        "details": error?.details,
        "message": error?.message,
        "source": error?.source,
      },
      "pendingCompletePurchase": pendingCompletePurchase,
      "productId": productID,
      "purchaseId": purchaseID,
      "status": status.name,
      "transactionDate": transactionDate,
      "verificationData": {
        "localVerificationData": verificationData.localVerificationData,
        "serverVerificationData": verificationData.serverVerificationData,
        "source": verificationData.source,
      },
    };
  }

  Map<String, dynamic> print() {
    return {
      "error": {
        "code": error?.code,
        "details": error?.details,
        "message": error?.message,
        "source": error?.source,
      },
      "pendingCompletePurchase": pendingCompletePurchase,
      "productId": productID,
      "purchaseId": purchaseID,
      "status": status.name,
      "transactionDate": transactionDate,
    };
  }
}

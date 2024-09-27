// ignore_for_file: depend_on_referenced_packages, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:workout_notepad_v2/model/pocketbaseAuth.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/home.dart';
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
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  // late StreamSubscription<AuthStoreEvent> _pocketbaseAuth;

  HomeScreen _currentTabScreen = HomeScreen.overview;
  HomeScreen get currentTabScreen => _currentTabScreen;
  void setTabScreen(HomeScreen screen) {
    _currentTabScreen = screen;
    notifyListeners();
  }

  // global client to use
  final client = Client(client: http.Client());
  final purchaseClient = PurchaseClient(client: http.Client());

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

  DataModel() {
    // create the subscription notifier
    _subscription =
        InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "payment_exception"},
      );
    });

    init();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (var purchaseDetails in purchaseDetailsList) {
      await _handlePurchaseRecord(purchaseDetails);
    }
  }

  Future<void> _handlePurchaseRecord(PurchaseDetails details) async {
    print("[PURCHASE] Handling Purchase");
    print(details.print());
    paymentLoadStatus = PaymentLoadStatus.loading;
    notifyListeners();

    try {
      // check for payment errors
      if (details.status == PurchaseStatus.error) {
        _recordPaymentError(
          "There was an error in the purchase itself",
          details,
          "purchase_error",
        );
        await InAppPurchase.instance.completePurchase(details);
        paymentLoadStatus = PaymentLoadStatus.paymentError;
        notifyListeners();
        return;
      }

      if (details.status == PurchaseStatus.canceled) {
        print("The payment was cancelled");
        await InAppPurchase.instance.completePurchase(details);
        paymentLoadStatus = PaymentLoadStatus.error;
        notifyListeners();
        return;
      }

      // check for missing metadata
      if ((details.purchaseID?.isEmpty ?? true) || details.productID.isEmpty) {
        print("There was missing metadata in the purchase request, ignoring");
        return;
      }

      // if pending, ignore
      if (details.status == PurchaseStatus.pending) {
        print("the purchase is still pending");
        paymentLoadStatus = PaymentLoadStatus.loading;
        notifyListeners();
        return;
      }

      // check if update notification
      if (hasValidSubscription()) {
        // TODO -- need to handle update logic here
        // it is possible we are being notified of ended subscription here
        // server events will handle this.
        print("handling update notification");
        paymentLoadStatus = PaymentLoadStatus.none;
        notifyListeners();
        await InAppPurchase.instance.completePurchase(details);
        return;
      }

      // check for new payments
      if (details.status == PurchaseStatus.purchased ||
          details.status == PurchaseStatus.restored) {
        print("The purchase was successful");
        paymentLoadStatus = PaymentLoadStatus.loading;
        notifyListeners();

        // validate the purchase on the server
        // this will create the purchase record needed for the store events
        bool isValid = await _verifyPurchase(details);
        if (!isValid) {
          // log this error, but let the purchase continue. Can revoke later as needed.
          _recordPaymentError(
            "There was an error verifying the payment",
            details,
            "payment_verify",
          );
        }

        // complete the purchase
        await NewrelicMobile.instance.recordCustomEvent(
          "WN_Metric",
          eventName: "payment_complete",
          eventAttributes: {
            "userId": user!.userId,
            "transactionDate": details.transactionDate,
          },
        );
        await InAppPurchase.instance.completePurchase(details);
        print("[PURCHASE] Successfully assigned purchase");
        paymentLoadStatus = PaymentLoadStatus.complete;
        notifyListeners();
        return;
      } else {
        print("Unknown status");
        await InAppPurchase.instance.completePurchase(details);
        paymentLoadStatus = PaymentLoadStatus.error;
        notifyListeners();
        return;
      }
    } catch (error) {
      print(error);
      _recordPaymentError(
        error,
        details,
        "payment_unknown",
      );
      await InAppPurchase.instance.completePurchase(details);
      paymentLoadStatus = PaymentLoadStatus.error;
      notifyListeners();
    }
  }

  void _recordPaymentError(
    dynamic error,
    PurchaseDetails details,
    String errCode,
  ) {
    NewrelicMobile.instance.recordError(
      error,
      StackTrace.current,
      attributes: {
        "err_code": errCode,
        "details": jsonEncode(details.toMap()),
      },
    );
    print("[PURCHASE] **ERROR**");
    print(error);
  }

  Future<bool> _verifyPurchase(PurchaseDetails details) async {
    var response = await purchaseClient.put(
      "/users/${user!.userId}/verifyPurchase",
      {},
      jsonEncode({
        "purchaseDetails": details.toMap(),
        "promoCode": currentPromoCode,
      }),
    );
    if (response.statusCode == 200) {
      print("Successfully verified purchase"); // TODO
      return true;
    } else {
      print("There was error verifying the purchase"); // TODO
      print(response.body);
      return false;
    }
  }

  Future<void> createAnonymousUser(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    var u = await User.loginAnon();
    if (u == null) {
      snackbarErr(context, "There was an issue getting your account.");
      return;
    }
    await NewrelicMobile.instance.recordCustomEvent(
      "WN_Metric",
      eventName: "login_anon",
      eventAttributes: {"userId": u.userId},
    );
    prefs.setString("user", jsonEncode(u.toMap()));
    await init(u: u);
  }

  Future<void> loginUser(
    BuildContext context,
    auth.UserCredential credential,
  ) async {
    print("LOGIN");
    loadStatus = LoadStatus.init;
    notifyListeners();
    var prefs = await SharedPreferences.getInstance();
    var u = await User.loginAuth(
      credential,
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
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "anon_convert",
        eventAttributes: {"new_user_id": u.userId, "old_user_id": user!.userId},
      );
      // save on the user
      u.anonUserId = user!.userId;
      prefs.setString("user", jsonEncode(u.toMap()));
    }
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
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "anon_convert",
        eventAttributes: {"new_user_id": u.userId, "old_user_id": user!.userId},
      );
      // save on the user
      u.anonUserId = user!.userId;
      prefs.setString("user", jsonEncode(u.toMap()));
    }
    await init(u: u);
  }

  Future<void> init({User? u}) async {
    print("INIT");
    loadStatus = LoadStatus.done;
    notifyListeners();

    var prefs = await SharedPreferences.getInstance();

    // create the pb client
    pb = PocketBase(
      'https://pocketbase.sapphirenw.com',
      authStore: SharedPreferencesAuthStore(prefs),
    );

    // set to index page
    _currentTabScreen = HomeScreen.overview;
    notifyListeners();

    // check for saved userId
    if (!prefs.containsKey("user")) {
      print("[INIT] user not saved in preferences");
      await clearData();
      return;
    }

    // get the saved user
    user = User.fromJson(jsonDecode(prefs.getString("user")!));

    print(user?.subscriptionType);

    print("userId = ${user!.userId}");

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
    getSubscription(user!.userId); // get subscription status async as well
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
          loadStatus = LoadStatus.expired;
          notifyListeners();
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
          user = tmp;

          // ignore this
          // await clearData();
          // return;
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

      // set user id in newrelic
      await NewrelicMobile.instance.setUserId(user!.userId);

      notifyListeners();
      // do not snapshot anon data
      if (!user!.isAnon) {
        handleSnapshotInit();
      }
    } catch (error) {
      NewrelicMobile.instance.recordError(
        error,
        StackTrace.current,
        attributes: {"err_code": "fetch_user"},
      );
      print(
          "GET_USER there was an error fetching the user. Assuming user is offline");
      user!.offline = true;
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
    } catch (e) {
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
      print("comparing sha256");
      var localContent = await Snapshot.getLocalData();
      print(localContent['sha256Hash']);
      print(serverSnapshots.first.sha256Hash);
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
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "snapshot_create",
      );
      _snapshots = snps;
      dataSyncStatus = SyncStatus.inSync;
      notifyListeners();
      return true;
    } catch (e, s) {
      print(e);
      print(s);
      NewrelicMobile.instance.recordError(
        e,
        s,
        attributes: {"err_code": "snapshot_create"},
      );
      dataSyncStatus = SyncStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchData({bool checkData = true}) async {
    var db = await DatabaseProvider().database;
    var getC = Category.getList(db: db);
    var getW = Workout.getList(db: db);
    var getWt = Workout.getTemplates(db: db);
    var getE = Exercise.getList(db: db);
    var getT = Tag.getList(db: db);

    // run all asynchronously at the same time
    List<dynamic> results = await Future.wait([getC, getW, getWt, getE, getT]);

    _categories = results[0];
    _workouts = results[1];
    _workoutTemplates = results[2];
    _exercises = results[3];
    _tags = results[4];

    // check if the user has data
    if (checkData) {
      if (workouts.isEmpty && exercises.isEmpty) {
        print("user has no data, adding basic data");
        // add some base categories and tags
        await importDefaults();
        hasNoData = true;
      }
    }
    notifyListeners();
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

  List<Workout> _workoutTemplates = [];
  List<Workout> get workoutTemplates => _workoutTemplates;
  Future<void> refreshWorkoutTemplates() async {
    _workoutTemplates = await Workout.getTemplates();
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
    // _collections = await Collection.getList();
  }

  CollectionItem? _nextWorkout;
  CollectionItem? get nextWorkout => _nextWorkout;
  Future<void> refreshNextWorkout() async {
    // _getNextWorkout();
    // notifyListeners();
  }

  List<Snapshot> _snapshots = [];
  List<Snapshot> get snapshots => _snapshots;

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
      auth.FirebaseAuth.instance.signOut();
    }
    notifyListeners();
  }

  Future<void> delete() async {
    // create a snapshot of their data
    await snapshotData();
    await user!.delete();
    await deleteDB();
    await clearData();
    auth.FirebaseAuth.instance.signOut();
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
      workoutState!.exercises = await workoutState!.workout.getChildren();
    }

    // create the exercise log state
    for (int i = 0; i < workoutState!.exercises.length; i++) {
      List<ExerciseLog> logs = [];
      for (int j = 0; j < workoutState!.exercises[i].length; j++) {
        // create the log group for each exercise
        logs.add(
          ExerciseLog.workoutInit(
            workoutLog: workoutState!.wl,
            exercise: workoutState!.exercises[i][j],
            defaultTag: tags.firstWhereOrNull((element) => element.isDefault),
          ),
        );
      }
      workoutState!.exerciseLogs.add(logs);
    }

    await NewrelicMobile.instance.recordCustomEvent(
      "WN_Metric",
      eventName: "workout_start",
      eventAttributes: {
        "workoutId": workoutState!.workout.workoutId,
        "title": workoutState!.workout.title,
      },
    );
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
      NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "workout_finish",
      );
    } else {
      NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "workout_cancel",
      );
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
    } catch (e) {
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
    print("[UPDATE] checking for required update asynchronously ...");
    var prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // send the request
    var response = await client.fetch("/mobile-metadata/$currentVersion");

    // check for errors
    if (response.statusCode != 200) {
      print("[UPDATE] there was an issue checking for the mobile metadata");
      // ignore for now, but log to NEW RELIC
      // TODO
      NewrelicMobile.instance.recordError(
        "Failed to fetch the mobile metadata",
        null,
        attributes: {"err_code": "mobile_metadata"},
      );
      return;
    }

    // parse the body
    Map<String, dynamic> body = jsonDecode(response.body);

    if (body['status'] != 200) {
      print("[UPDATE] there was an issue with the request: $body");
      return;
    }

    // check rules for showing an update screen
    if (body['body']['force_update']) {
      print("[UPDATE] a forced update has been detected");
      // show non-dismissable model
      showForcedUpdate = true;
    } else if (body['body']['recommend_update']) {
      hasRecommendedUpdate = true;
      print("[UPDATE] a recommended update has been detected");
      // check if this version has already been recommended
      var rec = prefs.get("recommend_version");
      if ((rec ?? currentVersion) != body['body']['current_version']) {
        print("[UPDATE] showing the recommended update screen");
        // show recommend alert
        showRecommendedUpdate = true;

        // update the stored value so the alert does not fire again
        prefs.setString("recommend_version", body['body']['current_version']);
      }
    }
    print("[UPDATE] successfully checked");
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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

    return subscription?.active == 1;
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

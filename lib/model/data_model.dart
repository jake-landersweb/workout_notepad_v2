// ignore_for_file: depend_on_referenced_packages, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/home.dart';
import 'package:workout_notepad_v2/views/workouts/launch/root.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:http/http.dart' as http;

enum LoadStatus { init, noUser, done, expired }

enum LoadingStatus { loading, error, done }

enum PaymentLoadStatus { none, loading, complete, error }

class DataModel extends ChangeNotifier {
  late StreamSubscription<List<PurchaseDetails>> _subscription;

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
  PaymentLoadStatus paymentLoadStatus = PaymentLoadStatus.none;

  DataModel() {
    // create the subscription
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
    print("[PURCHASE] Handling Purchase with productID: ${details.productID}");
    try {
      if (details.status == PurchaseStatus.pending) {
        print("[PURCHASE] purchase pending");
        paymentLoadStatus = PaymentLoadStatus.loading;
        notifyListeners();
      } else {
        if (details.status == PurchaseStatus.error) {
          _recordPaymentError(
            "There was an error in the purchase itself",
            details,
            "purchase_error",
          );
          paymentLoadStatus = PaymentLoadStatus.error;
          notifyListeners();
        } else if (details.status == PurchaseStatus.purchased ||
            details.status == PurchaseStatus.restored) {
          if (user!.isPremiumUser()) {
            print(
              "[PURCHASE] duplicate event found, completing and ignoring. This event will be handled by the server",
            );
            await InAppPurchase.instance.completePurchase(details);
            print("[PURCHASE] duplicate purchaseId = ${details.purchaseID}");
            // TODO - add this to the user_purchaseId table
            return;
          } else {
            var valid = await _verifyPurchase(details);
            if (valid) {
              var assignResponse = await _assignPurchase(details);
              if (assignResponse) {
                await NewrelicMobile.instance.recordCustomEvent(
                  "WN_Metric",
                  eventName: "payment_complete",
                  eventAttributes: {
                    "userId": user!.userId,
                    "transactionDate": details.transactionDate,
                  },
                );
                print("[PURCHASE] Successfully assigned purchase");
                paymentLoadStatus = PaymentLoadStatus.complete;
                await init();
                notifyListeners();
              } else {
                _recordPaymentError(
                  "There was an error assigning the payment",
                  details,
                  "payment_assign",
                );
                paymentLoadStatus = PaymentLoadStatus.error;
                notifyListeners();
              }
            } else {
              _recordPaymentError(
                "There was an error verifying the purchase",
                details,
                "purchase_verify",
              );
              paymentLoadStatus = PaymentLoadStatus.error;
              notifyListeners();
              // if there was an error verifying, escape the function because it SHOULD NOT be verrified
              return;
            }
          }
        }
      }
    } catch (error) {
      _recordPaymentError(
        error,
        details,
        "payment_unknown",
      );
      paymentLoadStatus = PaymentLoadStatus.error;
      notifyListeners();
    }
    // complete the purchase NO MATTER WHAT
    if (details.pendingCompletePurchase) {
      await InAppPurchase.instance.completePurchase(details);
      print("[PURCHASE] Successfully acknowledged purchase");
      print("-- DETAILS --");
      print("productID: ${details.productID}");
      print("purchaseID: ${details.purchaseID}");
      print("transactionDate: ${details.transactionDate}");
      print("source: ${details.verificationData.source}");
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
        "productID": details.productID,
        "purchaseID": details.purchaseID ?? "",
        "transactionDate": details.transactionDate ?? "",
        "source": details.verificationData.source,
        "serverVerificationData":
            details.verificationData.serverVerificationData,
        "localVerificationData": details.verificationData.localVerificationData,
        "pendingCompletePurchase":
            details.pendingCompletePurchase ? "true" : "false",
      },
    );
    print("[PURCHASE] **ERROR**");
    print(error);
  }

  Future<bool> _verifyPurchase(PurchaseDetails details) async {
    var client = Client(client: http.Client());

    var response = await client.put(
      "/users/${user!.userId}/verifyPurchase",
      {},
      jsonEncode({
        "platform": Platform.isIOS ? "ios" : "android",
        "productId": details.productID,
        "token": details.verificationData.serverVerificationData,
        "isSandbox": foundation.kDebugMode,
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

  Future<bool> _assignPurchase(PurchaseDetails details) async {
    var client = Client(client: http.Client());

    var response = await client.put(
      "/users/${user!.userId}/assignPurchase",
      {},
      jsonEncode({
        "productId": details.productID,
        "transactionDate": int.parse(details.transactionDate!),
        "purchaseId": details.purchaseID,
      }),
    );
    if (response.statusCode == 200) {
      print("Successfully attached purchase");
      // update the user record to reflect this
      await getUser();
      return true;
    } else {
      print("There was error attaching the purchase"); // TODO
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
    var prefs = await SharedPreferences.getInstance();
    var u = await User.loginAuth(credential, convertFromAnon: user != null);
    if (u == null) {
      snackbarErr(context, "There was an issue getting your account.");
      return;
    }
    if (user != null) {
      await NewrelicMobile.instance.recordCustomEvent(
        "WN_Metric",
        eventName: "anon_convert",
        eventAttributes: {"new_user_id": u.userId, "old_user_id": user!.userId},
      );
    }
    prefs.setString("user", jsonEncode(u.toMap()));
    // check if there are snapshots for this user
    var serverSnapshots = await Snapshot.getList(u.userId);
    // import the first snapshot as the user's data
    if (serverSnapshots != null && serverSnapshots.isNotEmpty) {
      // sorted by first = latest on server
      await importSnapshot(serverSnapshots.first);
    }
    await init(u: u);
  }

  Future<void> init({User? u}) async {
    loadStatus = LoadStatus.done;
    notifyListeners();
    // const Set<String> _kIds = <String>{'wn_premium'};
    // final ProductDetailsResponse response =
    //     await InAppPurchase.instance.queryProductDetails(_kIds);
    // for (var i in response.productDetails) {
    //   print(i.id);
    //   print(i.description);
    // }
    // final PurchaseParam purchaseParam = PurchaseParam(
    //   productDetails: response.productDetails[0],
    // );
    // var purchaseResponse = await InAppPurchase.instance
    //     .buyNonConsumable(purchaseParam: purchaseParam);
    // print(purchaseResponse);

    var prefs = await SharedPreferences.getInstance();

    // set to index page
    _currentTabScreen = HomeScreen.overview;
    notifyListeners();

    // var db = await getDB();
    // var response = await db.rawUpdate(
    //     "UPDATE workout_log SET duration = '6944' WHERE workoutLogId = '91a1e334-ca18-4a53-b7be-0c8fe6bc71da'");
    // print(response);
    // return;
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

    // // check if the premium estimated expire epoch is overdue
    // if (user!.subscriptionEstimatedExpireEpoch != null) {
    //   print("Checking to make sure user still has a valid subscription ...");
    //   print("User epoch:   ${user!.subscriptionEstimatedExpireEpoch!}");
    //   print("Client epoch: ${DateTime.now().millisecondsSinceEpoch}");
    //   if (user!.subscriptionEstimatedExpireEpoch! <
    //       DateTime.now().millisecondsSinceEpoch) {
    //     print("The user's subscription has expired");
    //     user!.subscriptionType = SubscriptionType.none;
    //   } else {
    //     print("User has a valid subscription");
    //   }
    // }

    print("[INIT] app state is valid. Fetching user in background to ensure");
    await fetchData();
    getUser(); // run non-asynchonously to allow for no internet
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

    if (serverSnapshots.first.created <
        DateTime.now()
            .subtract(const Duration(hours: 8))
            .millisecondsSinceEpoch) {
      print(
        "last snapshot is older than 8 hours, creating a new snapshot",
      );
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
      print("The user's snapshots are up to date");
      // snapshots are up to date
      _snapshots = serverSnapshots;
      notifyListeners();
    }
  }

  Future<bool> snapshotData() async {
    // do not snapshot in debug mode
    if (foundation.kDebugMode) {
      return true;
    }
    // do not snapshot anon data
    if (user!.isAnon) {
      return true;
    }

    // snapshot the data
    var snps = await Snapshot.snapshotDatabase(user!.userId);
    if (snps == null) {
      NewrelicMobile.instance.recordError(
        "There was an issue snapshotting the database",
        StackTrace.current,
        attributes: {"err_code": "snapshot_create"},
      );
      // TODO -- handle errors
      print("There was an issue creating the snapshot");
      return false;
    }
    await NewrelicMobile.instance.recordCustomEvent(
      "WN_Metric",
      eventName: "snapshot_create",
    );
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

    // run all asynchronously at the same time
    List<dynamic> results = await Future.wait([getC, getW, getE, getT]);

    _categories = results[0];
    _workouts = results[1];
    _exercises = results[2];
    _tags = results[3];
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
    var response = await snapshotData();
    var cont = true;
    if (!response) {
      await showAlert(
        context: context,
        title: "An Error Occured",
        body: Text(
            "There was an issue creating a snapshot of your exercise data, if you logout now, you may lose some data."),
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
      auth.FirebaseAuth.instance.signOut();
      notifyListeners();
    }
  }

  Future<void> delete(BuildContext context) async {
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
      var db = await getDB();
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
    workoutState = null;
    await fetchData();
    notifyListeners();
  }

  Future<bool> importSnapshot(Snapshot snapshot) async {
    try {
      print("IMPORTING DATA");
      loadStatus = LoadStatus.init;
      notifyListeners();
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
      // load / create database
      var db = await getDB();

      // read file
      // String json = await rootBundle.loadString("sql/init.json");
      // Map<String, dynamic> data = const JsonDecoder().convert(json);
      // // remove dynamodb fields
      // data.remove("id");
      // data.remove("created");

      // compose list of valid tables
      var tableResponse = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      var validTables = [for (var i in tableResponse) i['name']];
      var invalidTables = ["android_metadata"];

      // get the snapshot file data
      var data = await snapshot.getFileData();
      if (data == null) {
        print("There was an issue importing the data");
        return false;
      }

      for (var key in data.keys) {
        if (validTables.contains(key) && !invalidTables.contains(key)) {
          for (var i in data[key]) {
            await db.insert(
              key,
              i,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
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

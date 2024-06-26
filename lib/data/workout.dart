import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/data/workout_snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/icons.dart';

class WorkoutCloneObject {
  final Workout workout;
  final List<List<WorkoutExercise>> exercises;

  WorkoutCloneObject({
    required this.workout,
    required this.exercises,
  });
}

class Workout {
  late String workoutId;
  late String title;
  String? description;
  late String icon;
  late String created;
  late String updated;
  late bool template;

  // not stored in database
  late List<String> categories;
  late List<List<WorkoutExercise>> exercises;

  Workout({
    required this.workoutId,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
    required this.template,
    required this.categories,
    required this.exercises,
  });

  Workout.init() {
    var uuid = const Uuid();
    workoutId = uuid.v4();
    title = "";
    description = "";
    icon = "";
    created = "";
    updated = "";
    template = false;
    categories = [];
    exercises = [];
  }

  Workout copy() => Workout(
        workoutId: workoutId,
        title: title,
        description: description,
        template: false,
        icon: icon,
        created: created,
        updated: updated,
        categories: [for (var i in categories) i],
        exercises: [
          for (var i in exercises) [for (var j in i) j.clone(this)]
        ],
      );

  static Future<Workout> fromJson(Map<String, dynamic> json) async {
    var w = Workout(
      workoutId: json['workoutId'],
      title: json['title'],
      description: json['description'],
      template: json['template'] == 0 ? false : true,
      icon: json['icon'],
      created: json['created'],
      updated: json['updated'],
      categories: [],
      exercises: [],
    );
    w.exercises = await w.getChildren();
    w.categories = await w.getCategories();
    return w;
  }

  Map<String, dynamic> toMap() {
    return {
      "workoutId": workoutId,
      "title": title,
      "icon": icon,
      "template": template ? 1 : 0,
      "description": description,
    };
  }

  Map<String, dynamic> toDump() {
    return {
      "workoutId": workoutId,
      "title": title,
      "description": description,
      "template": template ? 1 : 0,
      "icon": icon,
      "created": created,
      "updated": updated,
    };
  }

  Image getIcon({double? size}) {
    return getImageIcon(icon, size: size);
  }

  Future<List<List<WorkoutExercise>>> getChildren({Database? db}) async {
    db ??= await DatabaseProvider().database;
    String query = """
      SELECT * FROM exercise e
      JOIN workout_exercise we ON we.exerciseId = e.exerciseId
      WHERE we.workoutId = '$workoutId'
      ORDER BY we.exerciseOrder
    """;
    final List<Map<String, dynamic>> results = await db.rawQuery(query.trim());

    final Map<String, List<WorkoutExercise>> groupedData = {};

    // group by the supersetId
    for (final Map<String, dynamic> result in results) {
      final exercise = WorkoutExercise.fromJson(result);
      groupedData[exercise.supersetId] =
          groupedData.putIfAbsent(exercise.supersetId, () => [])..add(exercise);
    }

    // sort exercises
    var exercises = groupedData.values
        .sorted((a, b) => a[0].exerciseOrder.compareTo(b[0].exerciseOrder));
    // sort supersets
    for (final List<WorkoutExercise> ss in exercises) {
      ss.sort((a, b) => a.supersetOrder.compareTo(b.supersetOrder));
    }

    return exercises;
  }

  Future<List<String>> getCategories() async {
    var exercises = await getChildren();
    List<String> c = [];
    for (var i in exercises) {
      for (var j in i) {
        if (j.category.isNotEmpty) {
          c.add(j.category);
        }
      }
    }
    return c.toSet().toList();
  }

  static Future<List<Workout>> getList({Database? db}) async {
    db ??= await DatabaseProvider().database;
    var response = await db.rawQuery("""
      SELECT * FROM workout
      WHERE template == 0
      ORDER BY created DESC
    """);
    List<Workout> w = [];
    for (var i in response) {
      w.add(await Workout.fromJson(i));
    }
    return w;
  }

  static Future<List<Workout>> getTemplates({Database? db}) async {
    db ??= await DatabaseProvider().database;
    var response = await db.rawQuery("""
      SELECT * FROM workout
      WHERE template == 1
      ORDER BY created DESC
    """);
    List<Workout> w = [];
    for (var i in response) {
      w.add(await Workout.fromJson(i));
    }
    return w;
  }

  Future<List<WorkoutLog>> getLogs() async {
    var db = await DatabaseProvider().database;
    String sql = """
      SELECT * FROM workout_log WHERE workoutId = '$workoutId'
      ORDER BY created DESC
    """;
    var response = await db.rawQuery(sql);
    List<WorkoutLog> logs = [];
    for (var i in response) {
      logs.add(await WorkoutLog.fromJson(i));
    }
    return logs;
  }

  /// Creates a clone of a workout and its exercises and its exercise sets
  /// all with new ids for a new object
  Future<WorkoutCloneObject> clone(String newTitle) async {
    var clonedWorkout = copy();
    clonedWorkout.workoutId = const Uuid().v4();
    clonedWorkout.title = newTitle;
    var origChildren = await getChildren();
    List<List<WorkoutExercise>> clonedChildren = [];

    for (var i in origChildren) {
      List<WorkoutExercise> tmp = [];
      for (var j in i) {
        tmp.add(j.clone(clonedWorkout));
      }
      clonedChildren.add(tmp);
    }

    return WorkoutCloneObject(
      workout: clonedWorkout,
      exercises: clonedChildren,
    );
  }

  /// for storing the workout information as a JSON string, to allow for
  /// previous lookback on how a workout evolves
  Future<WorkoutSnapshot> toSnapshot(Database db) async {
    // initial workout data
    Map<String, dynamic> jsonData = toMap();
    List<List<Map<String, dynamic>>> childData = [];
    // get children
    var children = await getChildren(db: db);
    for (var i in children) {
      List<Map<String, dynamic>> tmp = [];
      for (var j in i) {
        tmp.add(j.toMapRAW());
      }
      childData.add(tmp);
    }
    jsonData['children'] = childData;
    return WorkoutSnapshot.init(workoutId: workoutId, jsonData: jsonData);
  }

  /// get all of the snapshots for this workout
  Future<List<WorkoutSnapshot>> getSnapshots() async {
    var db = await DatabaseProvider().database;
    var response = await db.rawQuery("""
      SELECT * FROM workout_snapshot
      WHERE workoutId = '$workoutId'
      ORDER BY CREATED DESC
    """);
    List<WorkoutSnapshot> snapshots = [];
    for (var i in response) {
      snapshots.add(WorkoutSnapshot.fromJson(i));
    }
    return snapshots;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

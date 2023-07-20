import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/data/workout_snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/icons.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class WorkoutCloneObject {
  final Workout workout;
  final List<Tuple2<WorkoutExercise, List<ExerciseSet>>> exercises;

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

  // not stored in database
  late List<String> categories;
  late List<WorkoutExercise> exercises;

  Workout({
    required this.workoutId,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
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
    categories = [];
    exercises = [];
  }

  Workout copy() => Workout(
        workoutId: workoutId,
        title: title,
        description: description,
        icon: icon,
        created: created,
        updated: updated,
        categories: [for (var i in categories) i],
        exercises: [for (var i in exercises) i.copy()],
      );

  static Future<Workout> fromJson(Map<String, dynamic> json) async {
    var w = Workout(
      workoutId: json['workoutId'],
      title: json['title'],
      description: json['description'],
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
      "description": description,
    };
  }

  Image getIcon({double? size}) {
    return getImageIcon(icon, size: size);
  }

  Future<List<WorkoutExercise>> getChildren() async {
    final db = await getDB();
    String query = """
      SELECT * FROM exercise e
      JOIN workout_exercise we ON we.exerciseId = e.exerciseId
      WHERE we.workoutId = '$workoutId'
      ORDER BY we.exerciseOrder
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(query.trim());
    List<WorkoutExercise> e = [];
    for (var i in response) {
      e.add(WorkoutExercise.fromJson(i));
    }
    return e;
  }

  Future<List<String>> getCategories() async {
    var exercises = await getChildren();
    List<String> c = [];
    for (var i in exercises) {
      if (i.category.isNotEmpty) {
        c.add(i.category);
      }
    }
    return c.toSet().toList();
  }

  static Future<List<Workout>> getList({Database? db}) async {
    db ??= await getDB();
    var response = await db.rawQuery("""
      SELECT * FROM workout
      ORDER BY created DESC
    """);
    List<Workout> w = [];
    for (var i in response) {
      w.add(await Workout.fromJson(i));
    }
    return w;
  }

  Future<List<WorkoutLog>> getLogs() async {
    var db = await getDB();
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
    List<Tuple2<WorkoutExercise, List<ExerciseSet>>> clonedChildren = [];

    for (var i in origChildren) {
      var tmpChildren = await i.getChildren(workoutId);
      List<ExerciseSet> clonedSets = [];
      var clonedWorkoutExercise = i.clone(clonedWorkout);
      for (var j in tmpChildren) {
        var clonedSet = j.clone(clonedWorkout, clonedWorkoutExercise);
        clonedSets.add(clonedSet);
      }
      clonedChildren.add(Tuple2(clonedWorkoutExercise, clonedSets));
    }

    return WorkoutCloneObject(
      workout: clonedWorkout,
      exercises: clonedChildren,
    );
  }

  /// for storing the workout information as a JSON string, to allow for
  /// previous lookback on how a workout evolves
  Future<WorkoutSnapshot> toSnapshot() async {
    // initial workout data
    Map<String, dynamic> jsonData = toMap();
    List<Map<String, dynamic>> childData = [];
    // get children
    var children = await getChildren();
    for (var i in children) {
      Map<String, dynamic> childJsonData = i.toMapRAW();
      List<Map<String, dynamic>> childChildData = [];
      var cchildren = await i.getChildren(workoutId);
      for (var j in cchildren) {
        childChildData.add(j.toMapRAW());
      }
      childJsonData['children'] = childChildData;
      childData.add(childJsonData);
    }
    jsonData['children'] = childData;
    return WorkoutSnapshot.init(workoutId: workoutId, jsonData: jsonData);
  }

  /// get all of the snapshots for this workout
  Future<List<WorkoutSnapshot>> getSnapshots() async {
    var db = await getDB();
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

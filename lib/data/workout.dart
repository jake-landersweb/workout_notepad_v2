import 'package:flutter/material.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
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

  // --- Constructors

  Workout({
    required this.workoutId,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
  });

  Workout.init() {
    var uuid = const Uuid();
    workoutId = uuid.v4();
    title = "";
    description = "";
    icon = "";
    created = "";
    updated = "";
  }

  Workout copy() => Workout(
        workoutId: workoutId,
        title: title,
        description: description,
        icon: icon,
        created: created,
        updated: updated,
      );

  Workout.fromJson(Map<String, dynamic> json) {
    workoutId = json['workoutId'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    created = json['created'];
    updated = json['updated'];
  }

  Workout.fromTest(Map<String, dynamic> json) {
    workoutId = json['workoutId'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'] ?? "";
    created = "";
    updated = "";
  }

  // --- Class Methods

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

  // --- DB Methods

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'workout',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
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

  static Future<List<Workout>> getList() async {
    final db = await getDB();
    final List<Map<String, dynamic>> response = await db.query('workout');
    List<Workout> w = [];
    for (var i in response) {
      w.add(Workout.fromJson(i));
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
      logs.add(WorkoutLog.fromJson(i));
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

  @override
  String toString() {
    return toMap().toString();
  }
}

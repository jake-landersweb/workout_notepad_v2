import 'package:flutter/material.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/icons.dart';

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

  Workout.init(String uid) {
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

  @override
  String toString() {
    return toMap().toString();
  }
}

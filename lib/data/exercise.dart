import 'package:flutter/material.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class Exercise {
  late String exerciseId;
  late String userId;
  late String category;
  late String title;
  String? description;
  late String icon;
  late String created;
  late String updated;
  late int type;
  late int sets;
  late int reps;
  late int time;
  late String timePost;

  // --- Constructors

  Exercise({
    required this.exerciseId,
    required this.userId,
    required this.category,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
    required this.type,
    required this.reps,
    required this.sets,
    required this.time,
    required this.timePost,
  });

  Exercise.empty(String uid) {
    var uuid = const Uuid();
    exerciseId = uuid.v4();
    userId = uid;
    category = "";
    title = "";
    description = "";
    icon = "";
    created = "";
    updated = "";
    type = 0;
    reps = 1;
    sets = 1;
    time = 0;
    timePost = "sec";
  }

  Exercise copy() => Exercise(
        exerciseId: exerciseId,
        userId: userId,
        category: category,
        title: title,
        description: description,
        icon: icon,
        created: created,
        updated: updated,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        timePost: timePost,
      );

  Exercise.fromJson(Map<String, dynamic> json) {
    exerciseId = json['exerciseId'];
    userId = json['userId'];
    category = json['category'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    created = json['created'];
    updated = json['updated'];
    type = json['type'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = json['timePost'];
  }

  Exercise.fromTest(Map<String, dynamic> json) {
    exerciseId = json['exerciseId'];
    userId = "1";
    category = json['category'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'] ?? "";
    created = "";
    updated = "";
    type = json['type'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = "";
  }

  Exercise.testWorkoutChild(Map<String, dynamic> json, Exercise e) {
    exerciseId = json['exerciseId'];
    userId = "1";
    category = json['category'] ?? e.category;
    title = json['title'] ?? e.title;
    description = json['description'] ?? e.description;
    created = "";
    updated = "";
    type = json['type'] ?? e.type;
    sets = json['sets'] ?? e.sets;
    reps = json['reps'] ?? e.reps;
    time = json['time'] ?? e.time;
    timePost = json['timePost'] ?? e.timePost;
  }

  // --- Class methods

  Map<String, dynamic> toMap() {
    return {
      "exerciseId": exerciseId,
      "userId": userId,
      "category": category,
      "title": title,
      "description": description,
      "icon": icon,
      "type": type,
      "reps": reps,
      "sets": sets,
      "time": time,
      "timePost": timePost,
    };
  }

  Image getIcon({double? size}) {
    return getImageIcon(icon, size: size);
  }

  // Database methods

  Future<bool> insert() async {
    final db = await getDB();
    var response = await db.insert(
      'exercise',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response != 0;
  }

  Future<bool> update() async {
    final db = await getDB();
    var response = await db.update(
      'exercise',
      toMap(),
      where: "exerciseId = ?",
      whereArgs: [exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response != 0;
  }

  Future<List<Exercise>> getChildren(String workoutId) async {
    final db = await getDB();
    String query = """
      SELECT * FROM exercise e
      JOIN exercise_set es ON e.exerciseId = es.parentId
      WHERE es.parentId = '$exerciseId' AND es.workoutId = '$workoutId'
      ORDER BY es.exerciseOrder
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(query.trim());
    List<Exercise> e = [];
    for (var i in response) {
      e.add(Exercise.fromJson(i));
    }
    return e;
  }

  static Future<List<Exercise>> getList(String userId) async {
    final db = await getDB();
    var sql = """
      SELECT * FROM exercise
      WHERE userId = '$userId'
      ORDER BY created DESC
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(sql);
    List<Exercise> w = [];
    for (var i in response) {
      w.add(Exercise.fromJson(i));
    }
    return w;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

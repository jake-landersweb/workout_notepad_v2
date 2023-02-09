import 'package:flutter/material.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class Exercise extends ExerciseBase {
  late String exerciseId;
  late String userId;
  late String created;
  late String updated;

  // --- Constructors

  Exercise({
    required this.exerciseId,
    required this.userId,
    required this.created,
    required this.updated,
    required super.title,
    required super.category,
    required super.description,
    required super.icon,
    required super.type,
    required super.sets,
    required super.reps,
    required super.time,
    required super.timePost,
  });

  Exercise.empty(String uid) : super.empty() {
    var uuid = const Uuid();
    exerciseId = uuid.v4();
    userId = uid;
    category = "";
    created = "";
    updated = "";
  }

  Exercise copy() => Exercise(
        exerciseId: exerciseId,
        userId: userId,
        category: category,
        created: created,
        updated: updated,
        title: title,
        description: description,
        icon: icon,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        timePost: timePost,
      );

  Exercise.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    exerciseId = json['exerciseId'];
    userId = json['userId'];
    created = json['created'];
    updated = json['updated'];
  }

  Exercise.fromTest(Map<String, dynamic> json)
      : super(
          title: json['title'],
          category: json['category'],
          description: json['description'] ?? "",
          icon: json['icon'] ?? "",
          type: json['type'],
          sets: json['sets'],
          reps: json['reps'],
          time: json['time'],
          timePost: json['timePost'] ?? "",
        ) {
    exerciseId = json['exerciseId'];
    userId = "1";
    category = json['category'];
  }

  // --- Class methods

  @override
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

  // Database methods

  @override
  Future<int> insert() async {
    final db = await getDB();
    var response = await db.insert(
      'exercise',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response;
  }

  @override
  Future<int> update() async {
    final db = await getDB();
    var response = await db.update(
      'exercise',
      toMap(),
      where: "exerciseId = ?",
      whereArgs: [exerciseId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return response;
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

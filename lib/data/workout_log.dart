import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutLog {
  late String workoutLogId;
  late String userId;
  late String workoutId;
  late String title;
  String? description;
  late int duration;
  String? note;
  late String created;
  late String updated;

  WorkoutLog({
    required this.workoutLogId,
    required this.userId,
    required this.workoutId,
    required this.title,
    required this.description,
    required this.duration,
    this.note,
    required this.created,
    required this.updated,
  });

  WorkoutLog.init(String uid, Workout w) {
    var uuid = const Uuid();
    workoutLogId = uuid.v4();
    userId = uid;
    workoutId = w.workoutId;
    title = w.title;
    description = w.description;
    duration = 0;
    created = "";
    updated = "";
  }

  WorkoutLog.fromJson(Map<String, dynamic> json) {
    workoutLogId = json['workoutLogId'];
    userId = json['userId'];
    workoutId = json['workoutId'];
    title = json['title'];
    description = json['description'];
    duration = json['duration'];
    note = json['note'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toMap() {
    return {
      "workoutLogId": workoutLogId,
      "userId": userId,
      "workoutId": workoutId,
      "title": title,
      "description": description,
      "duration": duration,
      "note": note,
    };
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'workout_log',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    return response;
  }

  Future<List<ExerciseLog>> getExercises() async {
    var db = await getDB();
    String sql = """
      SELECT * FROM exercise_log WHERE workoutLogId = '$workoutLogId'
      AND userId = '$userId'
      ORDER BY created DESC
    """;
    var response = await db.rawQuery(sql);
    List<ExerciseLog> logs = [];
    for (var i in response) {
      logs.add(ExerciseLog.fromJson(i));
    }
    return logs;
  }

  static Future<List<WorkoutLog>> getRecentLogs(String userId) async {
    var db = await getDB();
    String sql = """
      SELECT * FROM workout_log WHERE userId = '$userId'
      ORDER BY CREATED DESC
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

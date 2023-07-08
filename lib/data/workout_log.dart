import 'package:intl/intl.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutLog {
  late String workoutLogId;
  late String workoutId;
  late String title;
  String? description;
  late int duration;
  String? note;
  late String created;
  late String updated;

  // private runtime fields
  List<ExerciseLog>? _exericseLogs;

  WorkoutLog({
    required this.workoutLogId,
    required this.workoutId,
    required this.title,
    required this.description,
    required this.duration,
    this.note,
    required this.created,
    required this.updated,
  });

  WorkoutLog copy() => WorkoutLog(
        workoutLogId: workoutLogId,
        workoutId: workoutId,
        title: title,
        description: description,
        duration: duration,
        created: created,
        updated: updated,
      );

  WorkoutLog.init(Workout w) {
    var uuid = const Uuid();
    workoutLogId = uuid.v4();
    workoutId = w.workoutId;
    title = w.title;
    description = w.description;
    duration = 0;
    created = "";
    updated = "";
  }

  WorkoutLog.fromJson(Map<String, dynamic> json) {
    workoutLogId = json['workoutLogId'];
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

  Future<List<ExerciseLog>> getExercises({bool forceReload = false}) async {
    if (forceReload || _exericseLogs == null) {
      var db = await getDB();
      String sql = """
      SELECT * FROM exercise_log WHERE workoutLogId = '$workoutLogId'
      ORDER BY created DESC
    """;
      var response = await db.rawQuery(sql);
      List<ExerciseLog> logs = [];
      for (var i in response) {
        logs.add(ExerciseLog.fromJson(i));
      }
      _exericseLogs = logs;
      return logs;
    } else {
      return _exericseLogs!;
    }
  }

  static Future<List<WorkoutLog>> getRecentLogs() async {
    var db = await getDB();
    String sql = """
      SELECT * FROM workout_log
      ORDER BY CREATED DESC
    """;
    var response = await db.rawQuery(sql);
    List<WorkoutLog> logs = [];
    for (var i in response) {
      logs.add(WorkoutLog.fromJson(i));
    }
    return logs;
  }

  DateTime getCreated() => DateTime.parse(created);
  String getCreatedFormatted() {
    var d = getCreated();
    var f = DateFormat("MMM d, y");
    return f.format(d);
  }

  DateTime getUpdated() => DateTime.parse(updated);
  String getUpdatedFormatted() {
    var d = getUpdated();
    var f = DateFormat("MMM d, y");
    return f.format(d);
  }

  String getDuration() {
    return _formatHHMMSS(duration);
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

String _formatHHMMSS(int seconds) {
  int hours = (seconds / 3600).truncate();
  seconds = (seconds % 3600).truncate();
  int minutes = (seconds / 60).truncate();

  String hoursStr = (hours).toString().padLeft(2, '0');
  String minutesStr = (minutes).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  String out = "$secondsStr sec";

  if (minutes != 0) {
    out = "$minutesStr min, $out";
  }

  if (hours != 0) {
    out = "$hoursStr hr, $out";
  }

  return out;
}

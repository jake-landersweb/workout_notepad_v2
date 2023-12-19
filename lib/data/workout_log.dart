import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class WorkoutLog {
  late String workoutLogId;
  late String workoutId;
  late String title;
  String? description;
  late int duration;
  String? note;

  late String created;
  late String updated;
  CollectionItem? collectionItem;

  // not stored in database
  late List<List<ExerciseLog>> exerciseLogs;

  WorkoutLog({
    required this.workoutLogId,
    required this.workoutId,
    required this.title,
    required this.description,
    required this.duration,
    this.note,
    required this.created,
    required this.updated,
    this.collectionItem,
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
    exerciseLogs = [];
  }

  static Future<WorkoutLog> fromJson(
    Map<String, dynamic> json, {
    Database? db,
  }) async {
    var wl = WorkoutLog(
      workoutLogId: json['workoutLogId'],
      workoutId: json['workoutId'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      note: json['note'],
      created: json['created'],
      updated: json['updated'],
    );
    wl.exerciseLogs = await wl.getExercises(db: db) ?? [];
    return wl;
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

  Map<String, dynamic> toDump() {
    return {
      "workoutLogId": workoutLogId,
      "workoutId": workoutId,
      "title": title,
      "description": description,
      "duration": duration,
      "note": note,
      "created": created,
      "updated": updated,
    };
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await DatabaseProvider().database;
    var response = await db.insert(
      'workout_log',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    return response;
  }

  Future<List<List<ExerciseLog>>?> getExercises({
    bool forceReload = false,
    Database? db,
  }) async {
    try {
      db ??= await DatabaseProvider().database;
      String query = """
        SELECT * FROM exercise_log WHERE workoutLogId = '$workoutLogId'
        ORDER BY exerciseOrder
      """;
      final List<Map<String, dynamic>> results =
          await db.rawQuery(query.trim());

      final Map<String, List<ExerciseLog>> groupedData = {};

      // group by the supersetId
      for (final Map<String, dynamic> result in results) {
        final exercise = await ExerciseLog.fromJson(result);
        groupedData[exercise.supersetId] = groupedData.putIfAbsent(
            exercise.supersetId, () => [])
          ..add(exercise);
      }

      // Sort each group by supersetOrder
      for (final List<ExerciseLog> exercises in groupedData.values) {
        exercises.sort((a, b) => a.supersetOrder.compareTo(b.supersetOrder));
      }

      return groupedData.values.toList();
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<WorkoutLog>> getRecentLogs() async {
    var db = await DatabaseProvider().database;
    String sql = """
      SELECT * FROM workout_log
      ORDER BY CREATED DESC
    """;
    var response = await db.rawQuery(sql);
    List<WorkoutLog> logs = [];
    for (var i in response) {
      logs.add(await WorkoutLog.fromJson(i));
    }
    return logs;
  }

  // trick to parse db date as utc time
  DateTime getCreated() => DateTime.parse("${created}Z").toLocal();

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

class WorkoutLogCalendarDataSource extends CalendarDataSource {
  WorkoutLogCalendarDataSource(List<WorkoutLog> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].getCreated();
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].getCreated();
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return ColorUtil.random(appointments![index].workoutId);
  }

  @override
  bool isAllDay(int index) {
    return true;
  }
}

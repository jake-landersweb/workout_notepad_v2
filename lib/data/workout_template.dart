import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template_exercise.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class WorkoutTemplate extends Workout {
  WorkoutTemplate({
    required this.id,
    required this.keywords,
    required this.metadata,
    required this.level,
    required this.estTime,
    required this.backgroundColor,
    this.imageId,
    required this.sha256,
    required this.createdAt,
    required this.updatedAt,
    required super.workoutId,
    required super.title,
    super.description,
    required super.icon,
    required super.created,
    required super.updated,
    required super.template,
    required super.categories,
    List<List<WorkoutTemplateExercise>>? exercises,
  }) {
    _exercises = exercises ?? [];
  }

  late int id;
  late String keywords;
  late Map<String, dynamic> metadata;
  late String level;
  late String estTime;
  late String backgroundColor;
  String? imageId;
  late String sha256;
  late DateTime createdAt;
  late DateTime updatedAt;

  List<List<WorkoutTemplateExercise>> _exercises = [];

  @override
  WorkoutTemplate copy() => WorkoutTemplate(
        id: id,
        keywords: keywords,
        metadata: metadata,
        level: level,
        estTime: estTime,
        backgroundColor: backgroundColor,
        sha256: sha256,
        createdAt: createdAt,
        updatedAt: updatedAt,
        workoutId: workoutId,
        title: title,
        icon: icon,
        created: created,
        updated: updated,
        template: template,
        categories: categories,
        description: description,
        imageId: imageId,
        exercises: _exercises
            .map((group) => group.map((e) => e.copy()).toList())
            .toList(),
      );

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    List<List<WorkoutTemplateExercise>> exercises = [];
    if (json.containsKey("exercises") && json['exercises'] is List) {
      for (var i in json['exercises']) {
        List<WorkoutTemplateExercise> e = [];
        for (var j in i) {
          e.add(WorkoutTemplateExercise.fromJson(j));
        }
        exercises.add(e);
      }
    }

    return WorkoutTemplate(
      id: json['template']['id'],
      workoutId: json['template']['workoutId'],
      title: json['template']['title'],
      description: json['template']['description'],
      keywords: json['template']['keywords'],
      metadata: json['template']['metadata'] is String
          ? jsonDecode(json['template']['metadata'])
          : json['template']['metadata'],
      level: json['template']['level'],
      estTime: json['template']['estTime'],
      backgroundColor: json['template']['backgroundColor'],
      imageId: json['template']['imageId'],
      sha256: json['template']['sha256'] ?? "",
      createdAt: DateTime.parse(json['template']['createdAt']),
      updatedAt: DateTime.parse(json['template']['updatedAt']),
      exercises: exercises,
      categories: [],
      created: json['template']['createdAt'],
      updated: json['template']['updatedAt'],
      icon: "",
      template: false,
    );
  }

  static Future<WorkoutTemplate> fromDB(int id, {Database? db}) async {
    db ??= await DatabaseProvider().database;
    String query = """
      SELECT * FROM workout_template
      WHERE id = '$id'
    """;
    final List<Map<String, dynamic>> results = await db.rawQuery(query.trim());
    if (results.isEmpty) {
      throw Exception("Failed to find any workout templates with id: $id");
    }

    // create the object
    var template = WorkoutTemplate.fromJson({"template": results[0]});

    // fetch the children
    template._fetchChildren(db: db);

    return template;
  }

  static Future<List<WorkoutTemplate>> getLocalTemplates({Database? db}) async {
    db ??= await DatabaseProvider().database;
    String query = """
      SELECT * FROM workout_template
    """;
    final List<Map<String, dynamic>> results = await db.rawQuery(query.trim());
    if (results.isEmpty) {
      return [];
    }

    List<WorkoutTemplate> items = [];
    for (var i in results) {
      var template = WorkoutTemplate.fromJson({"template": i});
      await template._fetchChildren(db: db);

      items.add(template);
    }
    return items;
  }

  Future<List<List<WorkoutTemplateExercise>>> _fetchChildren({
    Database? db,
  }) async {
    try {
      db ??= await DatabaseProvider().database;
      String query = """
        SELECT * FROM exercise e
        JOIN workout_template_exercise wte ON wte.exerciseId = e.exerciseId
        WHERE wte.workoutTemplateId = ?
        ORDER BY wte.exerciseOrder
      """;
      final List<Map<String, dynamic>> results =
          await db.rawQuery(query.trim(), [id]);

      final Map<String, List<WorkoutTemplateExercise>> groupedData = {};

      // group by the supersetId
      for (final Map<String, dynamic> result in results) {
        final exercise = WorkoutTemplateExercise.fromJson(result);
        groupedData[exercise.supersetId] = groupedData.putIfAbsent(
            exercise.supersetId, () => [])
          ..add(exercise);
      }

      // sort exercises
      var exercises = groupedData.values
          .sorted((a, b) => a[0].exerciseOrder.compareTo(b[0].exerciseOrder));
      // sort supersets
      for (final List<WorkoutTemplateExercise> ss in exercises) {
        ss.sort((a, b) => a.supersetOrder.compareTo(b.supersetOrder));
      }

      _exercises = exercises;

      return _exercises;
    } catch (error, stack) {
      print(error);
      print(stack);
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "template": {
        'id': id,
        'workoutId': workoutId,
        'title': title,
        'description': description,
        'keywords': keywords,
        'metadata': jsonEncode(metadata),
        'level': level,
        'estTime': estTime,
        'backgroundColor': backgroundColor,
        'imageId': imageId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
      "exercises": _exercises
          .map((exerciseGroup) =>
              exerciseGroup.map((exercise) => exercise.toMap()).toList())
          .toList()
    };
  }

  // use this method to generate the JSON payload needed for
  // creating new workout templates in the app. The API
  // is responsible for creating IDs and hashes, so those
  // will be zero values (0, "", false, etc.).
  Map<String, dynamic> asTemplateJson() {
    return {
      "template": {
        "workoutId": workoutId,
        "title": title,
        "description": description,
        "keywords": keywords,
        "level": level,
        "estTime": estTime,
        "backgroundColor": backgroundColor,
        "metadata": metadata,
      },
      "exercises": _exercises.map((group) => group.map((item) => item.toMap())),
    };
  }

  // --------------------------------
  // Exercise operations
  // --------------------------------
  @override
  List<List<WorkoutTemplateExercise>> getExercises() {
    return _exercises;
  }

  @override
  void setExercises(List<List<Exercise>> exercises) {
    _exercises = exercises
        .map((group) => group
            .map((e) => WorkoutTemplateExercise.fromExercise(this, e))
            .toList())
        .toList();
  }

  @override
  void setSuperSets(int i, List<Exercise> exercises) {
    _exercises[i] = exercises
        .map((e) => WorkoutTemplateExercise.fromExercise(this, e))
        .toList();
  }

  @override
  void addExercise(int i, Exercise e) {
    var we = WorkoutTemplateExercise.fromExercise(this, e);
    while (_exercises.length <= i) {
      _exercises.add([]);
    }

    // set superset id if need to
    if (_exercises[i].isNotEmpty) {
      we.supersetId = _exercises[i][0].supersetId;
    }
    _exercises[i].add(we);
  }

  @override
  void removeExercise(int i) {
    _exercises.removeAt(i);
  }

  @override
  void removeSuperSet(int i, int j) {
    _exercises[i].removeAt(j);
    if (_exercises[i].isEmpty) {
      _exercises.removeAt(i);
    }
  }

  @override
  List<WorkoutTemplateExercise> getFlatExercises({int? limit}) {
    if (limit == null) {
      return _exercises.flattened.toList();
    }
    if (_exercises.flattened.length > limit) {
      return _exercises.flattened.toList().slice(0, limit);
    }
    return _exercises.flattened.toList();
  }
  // --------------------------------

  // --------------------------------
  // UI options
  // --------------------------------
  @override
  Color? getBackgroundColor(BuildContext context) {
    try {
      if (backgroundColor.isNotEmpty) {
        return ColorUtil.hexToColor(backgroundColor);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // --------------------------------

  // --------------------------------
  // Database operations
  // --------------------------------
  @override
  Future<bool> handleInsert({Database? db}) async {
    try {
      db ??= await DatabaseProvider().database;

      bool response = await db.transaction((txn) async {
        // when updating, remove all existing exercises
        await txn.delete(
          "workout_template_exercise",
          where: "workoutTemplateId = ?",
          whereArgs: [id],
        );

        // loop through all exercises and group and add as supersets
        var uuid = const Uuid();
        for (int i = 0; i < _exercises.length; i++) {
          var supersetId = uuid.v4();
          for (int j = 0; j < _exercises[i].length; j++) {
            // configure the exercise fields
            _exercises[i][j].workoutTemplateId = id;
            _exercises[i][j].exerciseOrder = i;
            _exercises[i][j].supersetId = supersetId;
            _exercises[i][j].supersetOrder = j;

            // check if the exercise has already been imported
            var exerciseTmp = await txn.rawQuery(
                "SELECT * FROM exercise WHERE exerciseId = ?",
                [_exercises[i][j].exerciseId]);

            // if not already imported, create it
            if (exerciseTmp.isEmpty) {
              var r = await txn.insert(
                  "exercise", _exercises[i][j].rootExerciseMap());
              if (r == 0) {
                throw Exception(
                    "Failed to create the exercise from the exercise template data");
              }
            }

            var r = await txn.insert(
                "workout_template_exercise", _exercises[i][j].toMap());
            if (r == 0) {
              throw Exception("failed to create the workout template exercise");
            }
          }
        }

        // add or update the workout
        var r = await txn.insert(
          "workout_template",
          toMap()['template'],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (r == 0) {
          throw Exception("failed to create the template");
        }

        return true;
      });

      if (!response) {
        throw Exception("There was an issue completing the transaction");
      }

      return true;
    } catch (error, stack) {
      print(error);
      print(stack);
      NewrelicMobile.instance.recordError(error, stack);
      return false;
    }
  }
  // --------------------------------
}

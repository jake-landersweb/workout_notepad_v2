import 'package:collection/collection.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/getDB.dart';

class WorkoutTemplate {
  late int id;
  late String workoutId;
  late String title;
  late String description;
  late String keywords;
  late Map<String, dynamic> metadata;
  late String level;
  late String estTime;
  late String backgroundColor;
  late String? imageId;
  late String sha256;
  late DateTime createdAt;
  late DateTime updatedAt;

  List<List<WorkoutTemplateExercise>> exercises = [];

  WorkoutTemplate({
    required this.id,
    required this.workoutId,
    required this.title,
    required this.description,
    required this.keywords,
    required this.metadata,
    required this.level,
    required this.estTime,
    required this.backgroundColor,
    this.imageId,
    required this.sha256,
    required this.createdAt,
    required this.updatedAt,
    this.exercises = const [],
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    print(json);
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
      metadata: json['template']['metadata'] ?? {},
      level: json['template']['level'],
      estTime: json['template']['estTime'],
      backgroundColor: json['template']['backgroundColor'],
      imageId: json['template']['imageId'],
      sha256: json['template']['sha256'],
      createdAt: DateTime.parse(json['template']['createdAt']),
      updatedAt: DateTime.parse(json['template']['updatedAt']),
      exercises: exercises,
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

    return WorkoutTemplate.fromJson(results[0]);
  }

  static Future<List<WorkoutTemplate>> getLocalTemplates({Database? db}) async {
    db ??= await DatabaseProvider().database;
    String query = """
      SELECT * FROM workout_template
    """;
    final List<Map<String, dynamic>> results = await db.rawQuery(query.trim());
    if (results.isEmpty) {
      throw Exception("failed to get the workout templates");
    }

    List<WorkoutTemplate> items = [];
    for (var i in results) {
      items.add(WorkoutTemplate.fromJson(i));
    }
    return items;
  }

  Map<String, dynamic> toJson() {
    return {
      "template": {
        'id': id,
        'workoutId': workoutId,
        'title': title,
        'description': description,
        'keywords': keywords,
        'metadata': metadata,
        'level': level,
        'estTime': estTime,
        'backgroundColor': backgroundColor,
        'imageId': imageId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
      "exercises": exercises
          .map((exerciseGroup) =>
              exerciseGroup.map((exercise) => exercise.toJson()).toList())
          .toList()
    };
  }

  Workout asWorkout() {
    return Workout(
      workoutId: workoutId,
      title: title,
      icon: "",
      created: createdAt.toIso8601String(),
      updated: updatedAt.toIso8601String(),
      template: true,
      workoutTemplateId: id,
      categories: exercises
          .map((group) => group.map((item) => item.category).toList())
          .flattened
          .toList(),
      exercises: exercises
          .map(
            (group) => group.map((item) => item.asWorkoutExercise()).toList(),
          )
          .toList(),
    );
  }
}

class WorkoutTemplateExercise extends Exercise {
  late int id;
  late bool isImport;
  late int workoutTemplateId;
  late int exerciseOrder;
  late String supersetId;
  late int supersetOrder;
  late DateTime createdAt;
  late DateTime updatedAt;

  WorkoutTemplateExercise({
    required this.id,
    required this.isImport,
    required this.workoutTemplateId,
    required this.exerciseOrder,
    required this.supersetId,
    required this.supersetOrder,
    required this.createdAt,
    required this.updatedAt,
    required super.exerciseId,
    required super.title,
    required super.category,
    required super.description,
    required super.difficulty,
    required super.icon,
    required super.type,
    required super.sets,
    required super.reps,
    required super.time,
    super.filename,
  });

  WorkoutTemplateExercise.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    id = json['id'];
    isImport = json['isImport'];
    workoutTemplateId = json['workoutTemplateId'];
    exerciseOrder = json['exerciseOrder'];
    supersetId = json['supersetId'];
    supersetOrder = json['supersetOrder'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'icon': icon,
      "type": exerciseTypeToJson(type),
      'isImport': isImport,
      'id': id,
      'workoutTemplateId': workoutTemplateId,
      'exerciseId': exerciseId,
      'exerciseOrder': exerciseOrder,
      'supersetId': supersetId,
      'supersetOrder': supersetOrder,
      'sets': sets,
      'reps': reps,
      'time': time,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  WorkoutExercise asWorkoutExercise() {
    return WorkoutExercise(
      workoutExerciseId: "$id",
      workoutId: "$workoutTemplateId",
      exerciseOrder: exerciseOrder,
      supersetId: supersetId,
      supersetOrder: supersetOrder,
      exerciseId: exerciseId,
      title: title,
      category: category,
      description: description,
      difficulty: difficulty,
      icon: icon,
      type: type,
      sets: sets,
      reps: reps,
      time: time,
    );
  }
}

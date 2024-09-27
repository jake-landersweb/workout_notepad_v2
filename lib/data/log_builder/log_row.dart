import 'package:workout_notepad_v2/data/exercise.dart';

class LogRow {
  late String exerciseLogMetaId;
  late String exerciseLogId;
  late String exerciseId;
  late int reps;
  late int time;
  late int weight;
  late String weightPost;
  late int setPosition;
  late num normalizedWeight;
  late String tags;
  late String workoutExerciseId;
  late int exerciseOrder;
  late String supersetId;
  late int supersetOrder;
  late String workoutLogId;
  late String title;
  late String category;
  late String categoryId;
  late ExerciseType type;
  late int sets;
  late String note;
  late DateTime created;
  late DateTime updated;
  DateTime? savedDate;
  late String workoutLogTitle;
  late int workoutLogDuration;

  LogRow({
    required this.exerciseLogMetaId,
    required this.exerciseLogId,
    required this.exerciseId,
    required this.reps,
    required this.time,
    required this.weight,
    required this.weightPost,
    required this.setPosition,
    required this.normalizedWeight,
    required this.tags,
    required this.workoutExerciseId,
    required this.exerciseOrder,
    required this.supersetId,
    required this.supersetOrder,
    required this.workoutLogId,
    required this.title,
    required this.category,
    required this.categoryId,
    required this.type,
    required this.sets,
    required this.note,
    required this.created,
    required this.updated,
    this.savedDate,
    required this.workoutLogTitle,
    required this.workoutLogDuration,
  });

  LogRow.fromJson(dynamic json) {
    exerciseLogMetaId = json['exerciseLogMetaId'];
    exerciseLogId = json['exerciseLogId'];
    exerciseId = json['exerciseId'];
    reps = json['reps'];
    time = json['time'];
    weight = json['weight'];
    weightPost = json['weightPost'];
    setPosition = json['setPosition'];
    normalizedWeight = json['normalizedWeight'];
    tags = json['tags'] ?? "";
    workoutExerciseId = json['workoutExerciseId'];
    exerciseOrder = json['exerciseOrder'];
    supersetId = json['supersetId'];
    supersetOrder = json['supersetOrder'];
    workoutLogId = json['workoutLogId'];
    title = json['title'];
    category = json['category'];
    categoryId = json['categoryId'];
    type = exerciseTypeFromJson(json['type']);
    sets = json['sets'];
    note = json['note'] ?? "";
    created = DateTime.parse(json['created']);
    updated = DateTime.parse(json['updated']);
    savedDate = DateTime.tryParse(json['savedDate'] ?? "");
    workoutLogTitle = json['workoutLogTitle'] ?? "";
    workoutLogDuration = json['workoutLogDuration'] ?? 0;
  }
}

import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_template.dart';

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

  @override
  WorkoutTemplateExercise copy() => WorkoutTemplateExercise(
        id: id,
        isImport: isImport,
        workoutTemplateId: workoutTemplateId,
        exerciseOrder: exerciseOrder,
        supersetId: supersetId,
        supersetOrder: supersetOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
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

  WorkoutTemplateExercise.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    id = json['id'];
    isImport = json['isImport'] ?? false;
    workoutTemplateId = json['workoutTemplateId'];
    exerciseOrder = json['exerciseOrder'];
    supersetId = json['supersetId'];
    supersetOrder = json['supersetOrder'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
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

  Map<String, dynamic> toMapRAW() {
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

  WorkoutTemplateExercise.fromExercise(WorkoutTemplate wt, Exercise e)
      : super.fromSelf(e) {
    var uuid = const Uuid();
    id = 0;
    workoutTemplateId = wt.id;
    isImport = false;
    exerciseOrder = 0;
    supersetId = uuid.v4();
    supersetOrder = 0;
  }

  WorkoutExercise toWorkoutExercise() {
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

  @override
  Comparable getUniqueId() {
    return id;
  }
}

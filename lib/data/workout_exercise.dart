import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';

class WorkoutExercise extends Exercise {
  late String workoutExerciseId;
  late String workoutId;
  late int exerciseOrder;
  late String supersetId;
  late int supersetOrder;

  WorkoutExercise({
    required this.workoutExerciseId,
    required this.workoutId,
    required this.exerciseOrder,
    required this.supersetId,
    required this.supersetOrder,
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

  // WorkoutExercise.init(Workout w, Exercise e, ExerciseChildArgs args)
  //     : super(
  //         exerciseId: e.exerciseId,
  //         title: e.title,
  //         category: e.category,
  //         description: e.description,
  //         icon: e.icon,
  //         type: e.type,
  //         sets: args.sets ?? e.sets,
  //         reps: args.reps ?? e.reps,
  //         time: args.time ?? e.time,
  //       ) {
  //   var uuid = const Uuid();
  //   workoutExerciseId = uuid.v4();
  //   workoutId = w.workoutId;
  //   supersetId = uuid.v4();
  //   exerciseOrder = args.order;
  // }

  WorkoutExercise.fromExercise(Workout w, Exercise e) : super.fromSelf(e) {
    var uuid = const Uuid();
    workoutExerciseId = uuid.v4();
    workoutId = w.workoutId;
    exerciseOrder = 0;
    supersetId = uuid.v4();
    supersetOrder = 0;
  }

  @override
  WorkoutExercise copy() => WorkoutExercise(
        workoutExerciseId: workoutExerciseId,
        workoutId: workoutId,
        exerciseOrder: 0,
        supersetId: supersetId,
        supersetOrder: supersetOrder,
        // exercise fields
        exerciseId: exerciseId,
        title: title,
        category: category,
        description: description,
        difficulty: difficulty,
        icon: icon,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        filename: filename,
      );

  WorkoutExercise clone(Workout workout) => WorkoutExercise(
        workoutExerciseId: const Uuid().v4(),
        workoutId: workout.workoutId,
        exerciseOrder: exerciseOrder,
        supersetId: supersetId,
        supersetOrder: supersetOrder,
        // exercise fields
        exerciseId: exerciseId,
        title: title,
        category: category,
        description: description,
        difficulty: difficulty,
        icon: icon,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        filename: filename,
      );

  WorkoutExercise.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    workoutExerciseId = json['workoutExerciseId'];
    workoutId = json['workoutId'];
    exerciseOrder = json['exerciseOrder'];
    supersetId = json['supersetId'];
    supersetOrder = json['supersetOrder'];
  }

  /// for creating map objects for workout snapshots
  Map<String, dynamic> toMapRAW() {
    return {
      "workoutExerciseId": workoutExerciseId,
      "workoutId": workoutId,
      "exerciseOrder": exerciseOrder,
      "supersetId": supersetId,
      "supersetOrder": supersetOrder,
      // exercise fields
      "exerciseId": exerciseId,
      "title": title,
      "category": category,
      "description": description,
      "icon": icon,
      "type": exerciseTypeToJson(type),
      "sets": sets,
      "reps": reps,
      "time": time,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "workoutExerciseId": workoutExerciseId,
      "workoutId": workoutId,
      "exerciseOrder": exerciseOrder,
      "supersetId": supersetId,
      "supersetOrder": supersetOrder,
      // exercise fields saved on workout exercises
      "exerciseId": exerciseId,
      "sets": sets,
      "reps": reps,
      "time": time,
    };
  }

  @override
  Comparable getUniqueId() {
    return workoutExerciseId;
  }

  // Future<bool> delete(String workoutId) async {
  //   try {
  //     final db = await DatabaseProvider().database;
  //     // delete exercise
  //     String query = """
  //       DELETE FROM workout_exercise
  //       WHERE workoutExerciseId = '$workoutExerciseId'
  //     """;
  //     await db.rawQuery(query.trim());

  //     return true;
  //   } catch (e) {
  //     print(e);
  //     return false;
  //   }
  // }

  // Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
  //   final db = await DatabaseProvider().database;
  //   var response = await db.insert(
  //     'workout_exercise',
  //     toMap(),
  //     conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
  //   );
  //   return response;
  // }

  // Future<int> update() {
  //   // TODO: implement update
  //   throw UnimplementedError();
  // }
}

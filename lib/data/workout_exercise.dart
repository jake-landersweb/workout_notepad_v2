import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutExercise extends ExerciseBase {
  late String workoutExerciseId;
  late String workoutId;
  late String exerciseId;
  late int exerciseOrder;
  late String note;
  late int superSetOrdering;
  late String created;
  late String updated;

  WorkoutExercise({
    required this.workoutExerciseId,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.note,
    required this.superSetOrdering,
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

  WorkoutExercise.init(Workout w, Exercise e, ExerciseChildArgs args)
      : super(
          title: e.title,
          category: e.category,
          description: e.description,
          icon: e.icon,
          type: e.type,
          sets: args.sets ?? e.sets,
          reps: args.reps ?? e.reps,
          time: args.time ?? e.time,
          timePost: args.timePost ?? e.timePost,
        ) {
    var uuid = const Uuid();
    workoutExerciseId = uuid.v4();
    workoutId = w.workoutId;
    exerciseId = e.exerciseId;
    exerciseOrder = args.order;
    note = "";
    superSetOrdering = 0;
    created = "";
    updated = "";
  }

  WorkoutExercise.fromExercise(Workout w, Exercise e) : super.fromSelf(e) {
    var uuid = const Uuid();
    workoutExerciseId = uuid.v4();
    workoutId = w.workoutId;
    exerciseId = e.exerciseId;
    exerciseOrder = 0;
    note = "";
    superSetOrdering = 0;
    created = "";
    updated = "";
  }

  WorkoutExercise copy() => WorkoutExercise(
        workoutExerciseId: workoutExerciseId,
        workoutId: workoutId,
        exerciseId: exerciseId,
        exerciseOrder: exerciseOrder,
        note: note,
        superSetOrdering: superSetOrdering,
        created: created,
        updated: updated,
        title: title,
        category: category,
        description: description,
        icon: icon,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        timePost: timePost,
      );

  WorkoutExercise.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    workoutExerciseId = json['workoutExerciseId'];
    workoutId = json['workoutId'];
    exerciseId = json['exerciseId'];
    exerciseOrder = json['exerciseOrder'];
    note = json['note'] ?? "";
    superSetOrdering = json['superSetOrdering'] ?? 0;
    created = json['created'];
    updated = json['updated'];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "workoutExerciseId": workoutExerciseId,
      "workoutId": workoutId,
      "exerciseId": exerciseId,
      "exerciseOrder": exerciseOrder,
      "sets": sets,
      "reps": reps,
      "time": time,
      "timePost": timePost,
      "note": note,
      "superSetOrdering": superSetOrdering,
    };
  }

  Future<List<ExerciseSet>> getChildren(String workoutId) async {
    final db = await getDB();
    String query = """
      SELECT * FROM exercise e
      JOIN exercise_set es ON e.exerciseId = es.childId
      WHERE es.parentId = '$exerciseId' AND es.workoutId = '$workoutId' AND es.workoutExerciseId = '$workoutExerciseId'
      ORDER BY es.exerciseOrder
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(query.trim());
    List<ExerciseSet> e = [];
    for (var i in response) {
      e.add(ExerciseSet.fromJson(i));
    }
    return e;
  }

  @override
  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'workout_exercise',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    return response;
  }

  @override
  Future<int> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}

import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

class WorkoutExercise {
  late String id;
  late String workoutId;
  late String exerciseId;
  late int exerciseOrder;
  late int sets;
  late int reps;
  late int time;
  late String timePost;
  late String created;
  late String updated;

  WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.exerciseOrder,
    required this.sets,
    required this.reps,
    required this.time,
    required this.timePost,
    required this.created,
    required this.updated,
  });

  WorkoutExercise.init(Workout w, Exercise e, ExerciseChildArgs args) {
    var uuid = const Uuid();
    id = uuid.v4();
    workoutId = w.id;
    exerciseId = e.id;
    exerciseOrder = args.order;
    sets = args.sets ?? e.sets;
    reps = args.reps ?? e.reps;
    time = args.time ?? e.time;
    timePost = args.timePost ?? e.timePost;
    created = "";
    updated = "";
  }

  WorkoutExercise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workoutId = json['workoutId'];
    exerciseId = json['exerciseId'];
    exerciseOrder = json['exerciseOrder'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = json['timePost'];
    created = json['created'];
    updated = json['updated'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "workoutId": workoutId,
      "exerciseId": exerciseId,
      "exerciseOrder": exerciseOrder,
      "sets": sets,
      "reps": reps,
      "time": time,
      "timePost": timePost,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'workout_exercise',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

class ExerciseSet {
  late String id;
  late String workoutId;
  late String parentId;
  late String childId;
  late int exerciseOrder;
  late int sets;
  late int reps;
  late int time;
  late String timePost;
  late String created;
  late String updated;

  ExerciseSet({
    required this.id,
    required this.workoutId,
    required this.parentId,
    required this.childId,
    required this.exerciseOrder,
    required this.sets,
    required this.reps,
    required this.time,
    required this.timePost,
    required this.created,
    required this.updated,
  });

  ExerciseSet.init(Workout workout, Exercise parent, Exercise child,
      ExerciseChildArgs args) {
    var uuid = const Uuid();
    id = uuid.v4();
    workoutId = workout.id;
    parentId = parent.id;
    childId = child.id;
    exerciseOrder = args.order;
    sets = args.sets ?? child.sets;
    reps = args.reps ?? child.reps;
    time = args.time ?? child.time;
    timePost = args.timePost ?? child.timePost;
    created = "";
    updated = "";
  }

  ExerciseSet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    workoutId = json['workoutId'];
    parentId = json['parentId'];
    childId = json['childId'];
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
      "parentId": parentId,
      "childId": childId,
      "exerciseOrder": exerciseOrder,
      "sets": sets,
      "reps": reps,
      "time": time,
      "timePost": timePost,
      "created": created,
      "updated": updated,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'exercise_set',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

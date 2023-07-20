import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

class ExerciseSet extends ExerciseBase {
  late String exerciseSetId;
  late String workoutExerciseId;
  late String workoutId;
  late String parentId;
  late String childId;
  late int exerciseOrder;
  late String created;
  late String updated;

  ExerciseSet({
    required this.exerciseSetId,
    required this.workoutId,
    required this.workoutExerciseId,
    required this.parentId,
    required this.childId,
    required this.exerciseOrder,
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
  });

  ExerciseSet copy() => ExerciseSet(
        exerciseSetId: exerciseSetId,
        workoutId: workoutId,
        workoutExerciseId: workoutExerciseId,
        parentId: parentId,
        childId: childId,
        exerciseOrder: exerciseOrder,
        created: created,
        updated: updated,
        title: title,
        category: category,
        description: description,
        icon: icon,
        type: type,
        sets: sets,
        reps: reps,
        time: time,
      );

  ExerciseSet clone(Workout workout, WorkoutExercise parent) => ExerciseSet(
        exerciseSetId: const Uuid().v4(),
        workoutId: workout.workoutId,
        workoutExerciseId: parent.workoutExerciseId,
        parentId: parent.exerciseId,
        childId: childId,
        exerciseOrder: exerciseOrder,
        created: created,
        updated: updated,
        title: title,
        category: category,
        description: description,
        icon: icon,
        type: type,
        sets: sets,
        reps: reps,
        time: time,
      );

  ExerciseSet.init(Workout workout, WorkoutExercise parent, Exercise child,
      ExerciseChildArgs args)
      : super(
          title: child.title,
          category: child.category,
          description: child.description,
          icon: child.icon,
          type: child.type,
          sets: args.sets ?? child.sets,
          reps: args.reps ?? child.reps,
          time: args.time ?? child.time,
        ) {
    var uuid = const Uuid();
    exerciseSetId = uuid.v4();
    workoutExerciseId = parent.workoutExerciseId;
    workoutId = workout.workoutId;
    parentId = parent.exerciseId;
    childId = child.exerciseId;
    exerciseOrder = args.order;
    created = "";
    updated = "";
  }

  ExerciseSet.fromExercise(String wid, WorkoutExercise parent, Exercise e)
      : super.fromSelf(e) {
    var uuid = const Uuid();
    exerciseSetId = uuid.v4();
    workoutExerciseId = parent.workoutExerciseId;
    workoutId = wid;
    parentId = parent.exerciseId;
    childId = e.exerciseId;
    exerciseOrder = 0;
    created = "";
    updated = "";
  }

  ExerciseSet.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    exerciseSetId = json['exerciseSetId'];
    workoutExerciseId = json['workoutExerciseId'];
    workoutId = json['workoutId'];
    parentId = json['parentId'];
    childId = json['childId'];
    exerciseOrder = json['exerciseOrder'];
    created = json['created'];
    updated = json['updated'];
  }

  /// for creating map objects when creating snapshots and such
  Map<String, dynamic> toMapRAW() {
    return {
      "title": title,
      "category": category,
      "description": description,
      "icon": icon,
      "type": exerciseTypeToJson(type),
      "exerciseSetId": exerciseSetId,
      "workoutExerciseId": workoutExerciseId,
      "workoutId": workoutId,
      "parentId": parentId,
      "childId": childId,
      "exerciseOrder": exerciseOrder,
      "sets": sets,
      "reps": reps,
      "time": time,
      "created": created,
      "updated": updated,
    };
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "exerciseSetId": exerciseSetId,
      "workoutExerciseId": workoutExerciseId,
      "workoutId": workoutId,
      "parentId": parentId,
      "childId": childId,
      "exerciseOrder": exerciseOrder,
      "sets": sets,
      "reps": reps,
      "time": time,
      "created": created,
      "updated": updated,
    };
  }

  @override
  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'exercise_set',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    return response;
  }

  Future<bool> delete(String workoutId) async {
    try {
      final db = await getDB();
      // delete exercise
      String query = """
        DELETE FROM exercise_set
        WHERE workoutId = '$workoutId'
        AND workoutExerciseId = '$workoutExerciseId'
        AND parentId = '$parentId'
        AND childId = '$childId'
      """;
      await db.rawQuery(query.trim());

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<int> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}

import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:intl/intl.dart';

class ExerciseLog {
  late String exerciseLogId;
  late String userId;
  late String exerciseId;
  String? workoutLogId;
  late int type;
  late int sets;
  late String timePost;
  late String weightPost;
  String? note;
  late List<ExerciseLogMeta> metadata;
  late String created;
  late String updated;

  ExerciseLog({
    required this.exerciseLogId,
    required this.userId,
    required this.exerciseId,
    this.workoutLogId,
    required this.sets,
    required this.type,
    required this.timePost,
    required this.weightPost,
    this.note,
    required this.metadata,
    required this.created,
    required this.updated,
  });

  ExerciseLog.init(String uid, String eid, ExerciseBase exercise) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    userId = uid;
    exerciseId = eid;
    sets = exercise.sets;
    type = exercise.type;
    timePost = exercise.timePost;
    weightPost = "lbs";
    metadata = [];
    note = "";
    for (int i = 0; i < exercise.sets; i++) {
      metadata.add(
        ExerciseLogMeta(
          reps: exercise.reps,
          time: exercise.time,
          weight: 0,
          saved: false,
        ),
      );
    }
    created = "";
    updated = "";
  }

  ExerciseLog.workoutInit(
    String uid,
    String eid,
    String wlid,
    ExerciseBase exercise,
  ) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    userId = uid;
    exerciseId = eid;
    workoutLogId = wlid;
    sets = exercise.sets;
    type = exercise.type;
    timePost = exercise.timePost;
    weightPost = "lbs";
    metadata = [];
    note = "";
    for (int i = 0; i < exercise.sets; i++) {
      metadata.add(
        ExerciseLogMeta(
          reps: exercise.reps,
          time: exercise.time,
          weight: 0,
          saved: false,
        ),
      );
    }
    created = "";
    updated = "";
  }

  ExerciseLog.fromJson(Map<String, dynamic> json) {
    exerciseLogId = json['exerciseLogId'];
    userId = json['userId'];
    exerciseId = json['exerciseId'];
    workoutLogId = json['workoutLogId'];
    type = json['type'];
    sets = json['sets'];
    timePost = json['timePost'];
    weightPost = json['weightPost'];
    note = json['note'];
    metadata = [];
    var r = json['reps'].split(",");
    var t = json['time'].split(",");
    var w = json['weight'].split(",");
    for (int i = 0; i < sets; i++) {
      metadata.add(
        ExerciseLogMeta(
          reps: int.parse(r[i]),
          time: int.parse(t[i]),
          weight: int.parse(w[i]),
          saved: true,
        ),
      );
    }
    created = json['created'];
    updated = json['updated'];
  }

  bool removeSet(int index) {
    if (sets < 2) {
      return false;
    }
    sets -= 1;
    metadata.removeAt(index);
    return true;
  }

  bool addSet() {
    sets += 1;
    metadata.add(ExerciseLogMeta.from(metadata.elementAt(metadata.length - 1)));
    return true;
  }

  Map<String, dynamic> toMap() {
    var r = [];
    var t = [];
    var w = [];
    for (int i = 0; i < sets; i++) {
      r.add(metadata[i].reps);
      t.add(metadata[i].time);
      w.add(metadata[i].weight);
    }
    return {
      "exerciseLogId": exerciseLogId,
      "userId": userId,
      "exerciseId": exerciseId,
      "workoutLogId": workoutLogId,
      "type": type,
      "sets": sets,
      "reps": r.join(","),
      "time": t.join(","),
      "timePost": timePost,
      "weight": w.join(","),
      "weightPost": weightPost,
      "note": note,
    };
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'exercise_log',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    return response;
  }

  DateTime getCreated() => DateTime.parse(created);
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

  @override
  String toString() {
    return toMap().toString();
  }
}

class ExerciseLogMeta {
  late String id;
  late int reps;
  late int time;
  late int weight;
  late bool saved;

  ExerciseLogMeta({
    required this.reps,
    required this.time,
    required this.weight,
    required this.saved,
  }) {
    var uuid = const Uuid();
    id = uuid.v4();
  }

  ExerciseLogMeta.from(ExerciseLogMeta m) {
    var uuid = const Uuid();
    id = uuid.v4();
    reps = m.reps;
    time = m.time;
    weight = m.weight;
    saved = false;
  }
}

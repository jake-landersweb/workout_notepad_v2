import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:intl/intl.dart';

class ExerciseLog {
  late String exerciseLogId;
  late String exerciseId;
  String? parentId;
  String? workoutLogId;
  late String title;
  late ExerciseType type;
  late int sets;
  late String weightPost;
  String? note;
  late List<ExerciseLogMeta> metadata;
  late String created;
  late String updated;

  ExerciseLog({
    required this.exerciseLogId,
    required this.exerciseId,
    this.parentId,
    this.workoutLogId,
    required this.title,
    required this.sets,
    required this.type,
    required this.weightPost,
    this.note,
    required this.metadata,
    required this.created,
    required this.updated,
  });

  ExerciseLog.init(String eid, ExerciseBase exercise) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    exerciseId = eid;
    title = exercise.title;
    sets = exercise.sets;
    type = exercise.type;
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
          tags: [],
        ),
      );
    }
    created = "";
    updated = "";
  }

  ExerciseLog.workoutInit(
    String eid,
    String wlid,
    ExerciseBase exercise,
  ) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    exerciseId = eid;
    workoutLogId = wlid;
    title = exercise.title;
    sets = exercise.sets;
    type = exercise.type;
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
          tags: [],
        ),
      );
    }
    created = "";
    updated = "";
  }

  ExerciseLog.exerciseSetInit(
    String eid,
    String parentEid,
    String wlid,
    ExerciseBase exercise,
  ) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    exerciseId = eid;
    parentId = parentEid;
    workoutLogId = wlid;
    title = exercise.title;
    sets = exercise.sets;
    type = exercise.type;
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
          tags: [],
        ),
      );
    }
    created = "";
    updated = "";
  }

  ExerciseLog.fromJson(Map<String, dynamic> json) {
    exerciseLogId = json['exerciseLogId'];
    exerciseId = json['exerciseId'];
    parentId = json['parentId'];
    workoutLogId = json['workoutLogId'];
    title = json['title'];
    type = exerciseTypeFromJson(json['type']);
    sets = json['sets'];
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
          tags: [],
        ),
      );
    }
    created = json['created'];
    updated = json['updated'];
    setTags();
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

  void setDuration(int index, Duration duration) {
    if (index == -1) return;
    metadata[index].setDuration(duration);
  }

  Map<String, dynamic> toMap() {
    var r = [];
    var t = [];
    var w = [];
    for (int i = 0; i < metadata.length; i++) {
      r.add(metadata[i].reps);
      t.add(metadata[i].time);
      w.add(metadata[i].weight);
    }
    return {
      "exerciseLogId": exerciseLogId,
      "exerciseId": exerciseId,
      "parentId": parentId,
      "workoutLogId": workoutLogId,
      "title": title,
      "type": exerciseTypeToJson(type),
      "sets": metadata.length,
      "reps": r.join(","),
      "time": t.join(","),
      "weight": w.join(","),
      "weightPost": weightPost,
      "note": note,
    };
  }

  Future<void> setTags() async {
    var db = await getDB();
    var resp = await db.rawQuery("""
      SELECT * from exercise_log_tag elt
      JOIN tag t ON t.tagId = elt.tagId
      WHERE elt.exerciseLogId = '$exerciseLogId'
    """);
    for (var i in resp) {
      var elt = ExerciseLogTag.fromJson(i);
      metadata[elt.setIndex].tags.add(elt);
    }
  }

  bool addSetTag(Tag tag, int index) {
    metadata[index].insertTag(exerciseLogId, tag, index);
    return true;
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'exercise_log',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
    if (response != 0) {
      // delete all tags
      var _ = await db.rawDelete(
          "DELETE FROM exercise_log_tag WHERE exerciseLogId = '$exerciseLogId'");
      // insert all tags from metadata
      for (int i = 0; i < metadata.length; i++) {
        for (int j = 0; j < metadata[i].tags.length; j++) {
          // make sure set index is okay
          metadata[i].tags[j].setIndex = i;
          var resp = await metadata[i].tags[j].insert();
          if (resp == 0) {
            throw "THERE WAS AN ERROR";
            // TODO!! -- HANDLE ERROR
          }
        }
      }
    }
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
  late List<ExerciseLogTag> tags;

  ExerciseLogMeta({
    required this.reps,
    required this.time,
    required this.weight,
    required this.saved,
    required this.tags,
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
    tags = [for (var i in m.tags) i.clone()];
  }

  void setDuration(Duration duration) {
    time = duration.inSeconds;
  }

  bool insertTag(String exerciseLogId, Tag tag, int index) {
    if (tags.any((element) => element.tagId == tag.tagId)) {
      return false;
    }
    tags.add(
      ExerciseLogTag.init(
          exerciseLogId: exerciseLogId, tag: tag, setIndex: index),
    );
    return true;
  }
}

class Tag {
  late String tagId;
  late String title;

  Tag({
    required this.tagId,
    required this.title,
  });

  Tag.init({required this.title}) {
    tagId = const Uuid().v4();
  }

  Tag.fromJson(dynamic json) {
    tagId = json['tagId'];
    title = json['title'];
  }

  Map<String, dynamic> toMap() {
    return {
      "tagId": tagId,
      "title": title,
    };
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'tag',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    return response;
  }

  static Future<List<Tag>> getList() async {
    final db = await getDB();
    var response = await db.rawQuery("SELECT * FROM tag");
    List<Tag> t = [];
    for (var i in response) {
      t.add(Tag.fromJson(i));
    }
    return t;
  }
}

class ExerciseLogTag {
  late String exerciseLogTagId;
  late String exerciseLogId;
  late String tagId;
  late String title;
  late int setIndex;

  ExerciseLogTag({
    required this.exerciseLogTagId,
    required this.exerciseLogId,
    required this.tagId,
    required this.title,
    required this.setIndex,
  });

  ExerciseLogTag.init({
    required this.exerciseLogId,
    required Tag tag,
    required this.setIndex,
  }) {
    exerciseLogTagId = const Uuid().v4();
    tagId = tag.tagId;
    title = tag.title;
  }

  ExerciseLogTag clone() => ExerciseLogTag(
        exerciseLogTagId: exerciseLogTagId,
        exerciseLogId: exerciseLogId,
        tagId: tagId,
        title: title,
        setIndex: setIndex,
      );

  ExerciseLogTag.fromJson(dynamic json) {
    exerciseLogTagId = json['exerciseLogTagId'];
    exerciseLogId = json['exerciseLogId'];
    tagId = json['tagId'];
    title = json['title'];
    setIndex = json['setIndex'];
  }

  Map<String, dynamic> toMap() {
    return {
      "exerciseLogTagId": exerciseLogTagId,
      "exerciseLogId": exerciseLogId,
      "tagId": tagId,
      "setIndex": setIndex,
    };
  }

  Future<int> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    var response = await db.insert(
      'exercise_log_tag',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    return response;
  }
}

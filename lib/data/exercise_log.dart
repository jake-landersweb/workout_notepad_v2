import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/root.dart';
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
  String? note;
  late bool isSuperSet;
  late String created;
  late String updated;

  // not in db
  late List<ExerciseLogMeta> metadata;

  ExerciseLog({
    required this.exerciseLogId,
    required this.exerciseId,
    this.parentId,
    this.workoutLogId,
    required this.title,
    required this.sets,
    required this.type,
    this.note,
    required this.isSuperSet,
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
    note = "";
    isSuperSet = false;
    created = "";
    updated = "";
    metadata = [];
  }

  ExerciseLog.workoutInit({
    required String eid,
    required String wlid,
    required ExerciseBase exercise,
    Tag? defaultTag,
  }) {
    exerciseLogId = const Uuid().v4();
    exerciseId = eid;
    workoutLogId = wlid;
    title = exercise.title;
    sets = exercise.sets;
    type = exercise.type;
    note = "";
    isSuperSet = false;
    created = "";
    updated = "";
    metadata = [];
    for (int i = 0; i < exercise.sets; i++) {
      metadata.add(
        ExerciseLogMeta.init(
          log: this,
          exercise: exercise,
          defaultTag: defaultTag,
        ),
      );
    }
  }

  ExerciseLog.exerciseSetInit({
    required String eid,
    required String parentEid,
    required String wlid,
    required ExerciseBase exercise,
    Tag? defaultTag,
  }) {
    exerciseLogId = const Uuid().v4();
    exerciseId = eid;
    parentId = parentEid;
    workoutLogId = wlid;
    title = exercise.title;
    sets = exercise.sets;
    type = exercise.type;
    note = "";
    isSuperSet = true;
    created = "";
    updated = "";
    metadata = [];
    for (int i = 0; i < exercise.sets; i++) {
      metadata.add(
        ExerciseLogMeta.init(
          log: this,
          exercise: exercise,
          defaultTag: defaultTag,
        ),
      );
    }
  }

  static Future<ExerciseLog> fromJson(
    Map<String, dynamic> json, {
    Database? db,
  }) async {
    var el = ExerciseLog(
      exerciseLogId: json['exerciseLogId'],
      exerciseId: json['exerciseId'],
      parentId: json['parentId'],
      workoutLogId: json['workoutLogId'],
      title: json['title'],
      type: exerciseTypeFromJson(json['type']),
      sets: json['sets'],
      note: json['note'],
      isSuperSet: (json['isSuperSet'] ?? 0) == 0 ? false : true,
      created: json['created'],
      updated: json['updated'],
    );
    el.metadata = await el.getMetadata(db: db) ?? [];
    return el;
  }

  bool removeSet(int index) {
    if (sets < 2) {
      return false;
    }
    sets -= 1;
    metadata.removeAt(index);
    return true;
  }

  bool addSet({
    Tag? defaultTag,
  }) {
    sets += 1;
    if (metadata.isNotEmpty) {
      metadata
          .add(ExerciseLogMeta.from(metadata.elementAt(metadata.length - 1)));
    } else {
      metadata.add(ExerciseLogMeta.empty(
        log: this,
        defaultTag: defaultTag,
      ));
    }
    return true;
  }

  void setDuration(int index, Duration duration) {
    if (index == -1) return;
    metadata[index].setDuration(duration);
  }

  Map<String, dynamic> toMap() => {
        "exerciseLogId": exerciseLogId,
        "exerciseId": exerciseId,
        "parentId": parentId,
        "workoutLogId": workoutLogId,
        "title": title,
        "type": exerciseTypeToJson(type),
        "isSuperSet": isSuperSet ? 1 : 0,
        "sets": sets,
        "note": note,
      };

  Future<bool> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    try {
      final db = await getDB();
      // insert under transaction
      await db.transaction((txn) async {
        // insert the exercise log
        await txn.insert("exercise_log", toMap());

        // delete all metadata objects
        await txn.rawDelete(
            "DELETE FROM exercise_log_meta WHERE exerciseLogId = '$exerciseLogId'");

        // insert all metadata items
        for (var meta in metadata) {
          // insert the metadata object
          await txn.insert("exercise_log_meta", meta.toMap());

          // insert all metadata tags
          for (var tag in meta.tags) {
            await txn.insert("exercise_log_meta_tag", tag.toMap());
          }
        }
        // success
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<ExerciseLogMeta>?> getMetadata({Database? db}) async {
    try {
      db ??= await getDB();
      var response = await db.rawQuery("""
      SELECT * FROM exercise_log_meta
      WHERE exerciseLogId = '$exerciseLogId'
    """);
      List<ExerciseLogMeta> elm = [];
      for (var i in response) {
        elm.add(await ExerciseLogMeta.fromJson(i));
      }
      return elm;
    } catch (e) {
      print(e);
      return null;
    }
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
  late String exerciseLogMetaId;
  late String exerciseLogId;
  late String exerciseId;
  late int reps;
  late int time;
  late int weight;
  late String weightPost;

  // not in database
  late bool saved;
  late List<ExerciseLogMetaTag> tags;

  ExerciseLogMeta({
    required this.exerciseLogMetaId,
    required this.exerciseLogId,
    required this.exerciseId,
    required this.reps,
    required this.time,
    required this.weight,
    required this.weightPost,
  });

  ExerciseLogMeta.init({
    required ExerciseLog log,
    required ExerciseBase exercise,
    Tag? defaultTag,
  }) {
    exerciseLogMetaId = const Uuid().v4();
    exerciseLogId = log.exerciseLogId;
    exerciseId = log.exerciseId;
    reps = exercise.reps;
    time = exercise.time;
    weight = 0;
    saved = false;
    tags = [];
    if (defaultTag != null) {
      tags.add(ExerciseLogMetaTag.init(
        exerciseLogId: exerciseLogId,
        exerciseLogMetaId: exerciseLogMetaId,
        sortPos: 0,
        tag: defaultTag,
      ));
    }
    weightPost = "lbs";
  }

  ExerciseLogMeta.empty({
    required ExerciseLog log,
    Tag? defaultTag,
  }) {
    exerciseLogMetaId = const Uuid().v4();
    exerciseLogId = log.exerciseLogId;
    exerciseId = log.exerciseId;
    reps = 0;
    time = 0;
    weight = 0;
    saved = false;
    tags = [];
    if (defaultTag != null) {
      tags.add(
        ExerciseLogMetaTag.init(
          exerciseLogId: exerciseLogId,
          exerciseLogMetaId: exerciseLogMetaId,
          tag: defaultTag,
          sortPos: 0,
        ),
      );
    }
    weightPost = "lbs";
  }

  ExerciseLogMeta.from(ExerciseLogMeta m) {
    exerciseLogMetaId = const Uuid().v4();
    exerciseLogId = m.exerciseLogId;
    exerciseLogMetaId = m.exerciseLogMetaId;
    reps = m.reps;
    time = m.time;
    weight = m.weight;
    saved = false;
    tags = [for (var i in m.tags) i.clone()];
    weightPost = m.weightPost;
  }

  static Future<ExerciseLogMeta> fromJson(dynamic json, {Database? db}) async {
    var elm = ExerciseLogMeta(
      exerciseLogMetaId: json['exerciseLogMetaId'],
      exerciseLogId: json['exerciseLogId'],
      exerciseId: json['exerciseId'],
      reps: json['reps'],
      time: json['time'],
      weight: json['weight'],
      weightPost: json['weightPost'] ?? "lbs",
    );
    elm.tags = await elm.getTags(db: db) ?? [];
    return elm;
  }

  void setDuration(Duration duration) {
    time = duration.inSeconds;
  }

  bool addTag(Tag tag) {
    if (tags.any((element) => element.tagId == tag.tagId)) {
      return false;
    }
    tags.add(
      ExerciseLogMetaTag.init(
        exerciseLogId: exerciseLogId,
        exerciseLogMetaId: exerciseLogMetaId,
        tag: tag,
        sortPos: tags.length,
      ),
    );
    return true;
  }

  Future<List<ExerciseLogMetaTag>?> getTags({Database? db}) async {
    try {
      db ??= await getDB();
      var response = await db.rawQuery("""
      SELECT * from exercise_log_meta_tag et
      JOIN tag t ON t.tagId = et.tagId
      WHERE et.exerciseLogMetaId = '$exerciseLogMetaId'
    """);
      List<ExerciseLogMetaTag> t = [];
      for (var i in response) {
        t.add(ExerciseLogMetaTag.fromJson(i));
      }
      return t;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        "exerciseLogMetaId": exerciseLogMetaId,
        "exerciseLogId": exerciseLogId,
        "exerciseId": exerciseId,
        "reps": reps,
        "time": time,
        "weight": weight,
        "weightPost": weightPost,
      };
}

class ExerciseLogMetaTag {
  late String exerciseLogMetaTagId;
  late String exerciseLogMetaId;
  late String exerciseLogId;
  late String tagId;
  late int sortPos;

  // not stored in database
  late String title;

  ExerciseLogMetaTag({
    required this.exerciseLogMetaTagId,
    required this.exerciseLogMetaId,
    required this.exerciseLogId,
    required this.tagId,
    required this.title,
    required this.sortPos,
  });

  ExerciseLogMetaTag.init({
    required this.exerciseLogId,
    required this.exerciseLogMetaId,
    required Tag tag,
    required this.sortPos,
  }) {
    exerciseLogMetaTagId = const Uuid().v4();
    tagId = tag.tagId;
    title = tag.title;
  }

  ExerciseLogMetaTag clone() => ExerciseLogMetaTag(
        exerciseLogMetaTagId: exerciseLogMetaTagId,
        exerciseLogMetaId: exerciseLogMetaId,
        exerciseLogId: exerciseLogId,
        tagId: tagId,
        title: title,
        sortPos: sortPos,
      );

  ExerciseLogMetaTag.fromJson(dynamic json) {
    exerciseLogMetaTagId = json['exerciseLogMetaTagId'];
    exerciseLogMetaId = json['exerciseLogMetaId'];
    exerciseLogId = json['exerciseLogId'];
    tagId = json['tagId'];
    title = json['title'];
    sortPos = json['sortPos'];
  }

  Map<String, dynamic> toMap() {
    return {
      "exerciseLogMetaTagId": exerciseLogMetaTagId,
      "exerciseLogMetaId": exerciseLogMetaId,
      "exerciseLogId": exerciseLogId,
      "tagId": tagId,
      "sortPos": sortPos,
    };
  }
}

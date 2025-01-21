import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:intl/intl.dart';
import 'package:workout_notepad_v2/logger.dart';

class ExerciseLog {
  late String exerciseLogId;
  late String exerciseId;
  String? workoutExerciseId;
  late int exerciseOrder;
  late String supersetId;
  late int supersetOrder;
  String? workoutLogId;

  late String title;
  late String category;
  late ExerciseType type;
  late int sets;
  String? note;
  late String created;
  late String updated;

  // not in db
  late List<ExerciseLogMeta> metadata;

  ExerciseLog({
    required this.exerciseLogId,
    required this.exerciseId,
    this.workoutExerciseId,
    required this.exerciseOrder,
    required this.supersetId,
    required this.supersetOrder,
    this.workoutLogId,
    required this.title,
    required this.category,
    required this.sets,
    required this.type,
    this.note,
    required this.created,
    required this.updated,
  });

  ExerciseLog.init(String eid, Exercise exercise) {
    var uuid = const Uuid();
    exerciseLogId = uuid.v4();
    exerciseId = eid;
    exerciseOrder = 0;
    title = exercise.title;
    category = exercise.category;
    sets = exercise.sets;
    type = exercise.type;
    note = "";
    created = "";
    updated = "";
    metadata = [];
  }

  ExerciseLog.workoutInit({
    required WorkoutLog workoutLog,
    required WorkoutExercise exercise,
    Tag? defaultTag,
  }) {
    exerciseLogId = const Uuid().v4();
    exerciseId = exercise.exerciseId;
    supersetId = exercise.supersetId;
    workoutExerciseId = exercise.workoutExerciseId;
    exerciseOrder = 0;
    supersetOrder = exercise.supersetOrder;
    workoutLogId = workoutLog.workoutLogId;
    title = exercise.title;
    category = exercise.category;
    sets = exercise.sets;
    type = exercise.type;
    note = "";
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
      exerciseOrder: json['exerciseOrder'],
      workoutExerciseId: json['workoutExerciseId'],
      supersetId: json['supersetId'],
      supersetOrder: json['supersetOrder'] ?? 0,
      workoutLogId: json['workoutLogId'],
      title: json['title'],
      category: json['category'] ?? "",
      type: exerciseTypeFromJson(json['type']),
      sets: json['sets'],
      note: json['note'],
      created: json['created'],
      updated: json['updated'],
    );
    el.metadata = await el.getMetadata(db: db) ?? [];
    return el;
  }

  static Future<ExerciseLog> fromDump(
    Map<String, dynamic> json, {
    Database? db,
  }) async {
    var el = ExerciseLog(
      exerciseLogId: json['exerciseLogId'],
      exerciseId: json['exerciseId'],
      exerciseOrder: json['exerciseOrder'],
      workoutExerciseId: json['workoutExerciseId'],
      supersetId: json['supersetId'],
      supersetOrder: json['supersetOrder'] ?? 0,
      workoutLogId: json['workoutLogId'],
      title: json['title'],
      category: json['category'] ?? "",
      type: exerciseTypeFromJson(json['type']),
      sets: json['sets'],
      note: json['note'],
      created: json['created'],
      updated: json['updated'],
    );
    el.metadata = [
      for (var i in json['metadata']) await ExerciseLogMeta.fromDump(i)
    ];
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
        "supersetId": supersetId,
        "workoutExerciseId": workoutExerciseId,
        "exerciseOrder": exerciseOrder,
        "supersetOrder": supersetOrder,
        "workoutLogId": workoutLogId,
        "title": title,
        "category": category,
        "type": exerciseTypeToJson(type),
        "sets": sets,
        "note": note,
      };

  Map<String, dynamic> toDump() => {
        "exerciseLogId": exerciseLogId,
        "exerciseId": exerciseId,
        "supersetId": supersetId,
        "workoutExerciseId": workoutExerciseId,
        "exerciseOrder": exerciseOrder,
        "supersetOrder": supersetOrder,
        "workoutLogId": workoutLogId,
        "title": title,
        "category": category,
        "type": exerciseTypeToJson(type),
        "sets": sets,
        "note": note,
        "created": created,
        "updated": updated,
        "metadata": [for (var i in metadata) i.toDump()],
      };

  Future<bool> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    try {
      final db = await DatabaseProvider().database;
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
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return false;
    }
  }

  Future<List<ExerciseLogMeta>?> getMetadata({Database? db}) async {
    try {
      db ??= await DatabaseProvider().database;
      var response = await db.rawQuery("""
      SELECT * FROM exercise_log_meta
      WHERE exerciseLogId = '$exerciseLogId'
    """);
      List<ExerciseLogMeta> elm = [];
      for (var i in response) {
        elm.add(await ExerciseLogMeta.fromJson(i));
      }
      return elm;
    } catch (e, stack) {
      logger.exception(e, stack);
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
  DateTime? savedDate;

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
    this.savedDate,
  });

  ExerciseLogMeta.init({
    required ExerciseLog log,
    required Exercise exercise,
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
    exerciseId = m.exerciseId;
    reps = m.reps;
    time = m.time;
    weight = m.weight;
    saved = false;
    tags = [for (var i in m.tags) i.clone()];
    weightPost = m.weightPost;
    // savedDate = m.savedDate;
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
      savedDate: DateTime.tryParse(json['savedDate'] ?? ""),
    );
    elm.tags = await elm.getTags(db: db) ?? [];
    return elm;
  }

  static Future<ExerciseLogMeta> fromDump(dynamic json, {Database? db}) async {
    var elm = ExerciseLogMeta(
      exerciseLogMetaId: json['exerciseLogMetaId'],
      exerciseLogId: json['exerciseLogId'],
      exerciseId: json['exerciseId'],
      reps: json['reps'],
      time: json['time'],
      weight: json['weight'],
      weightPost: json['weightPost'] ?? "lbs",
      savedDate: DateTime.tryParse(json['savedDate'] ?? ""),
    );
    elm.tags = [for (var i in json['tags']) ExerciseLogMetaTag.fromJson(i)];
    elm.saved = json['saved'];
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

  String savedDifference(DateTime? other, {String format = "mm:ss"}) {
    if (savedDate == null) {
      return "";
    }
    if (other == null) {
      return "";
    }
    Duration difference = savedDate!.difference(other);
    String formattedDifference = DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(difference.inMilliseconds));
    return formattedDifference;
  }

  Future<List<ExerciseLogMetaTag>?> getTags({Database? db}) async {
    try {
      db ??= await DatabaseProvider().database;
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
    } catch (e, stack) {
      logger.exception(e, stack);
      print(e);
      return null;
    }
  }

  Map<String, dynamic> toMap() => {
        "exerciseLogMetaId": exerciseLogMetaId,
        "exerciseLogId": exerciseLogId,
        "exerciseId": "",
        "reps": reps,
        "time": time,
        "weight": weight,
        "weightPost": weightPost,
        "savedDate": savedDate?.toString(),
      };

  Map<String, dynamic> toDump() => {
        "exerciseLogMetaId": exerciseLogMetaId,
        "exerciseLogId": exerciseLogId,
        "exerciseId": "",
        "reps": reps,
        "time": time,
        "weight": weight,
        "weightPost": weightPost,
        "tags": [for (var i in tags) i.toDump()],
        "saved": saved,
        "savedDate": savedDate?.toString(),
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

  Map<String, dynamic> toDump() {
    return {
      "exerciseLogMetaTagId": exerciseLogMetaTagId,
      "exerciseLogMetaId": exerciseLogMetaId,
      "exerciseLogId": exerciseLogId,
      "tagId": tagId,
      "sortPos": sortPos,
      "title": title,
    };
  }
}

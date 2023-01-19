import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Exercise {
  late String id;
  late String userId;
  late String category;
  late String title;
  String? description;
  late String icon;
  late String created;
  late String updated;
  late int type;
  late int sets;
  late int reps;
  late int time;
  late String timePost;

  Exercise({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
    required this.type,
    required this.reps,
    required this.sets,
    required this.time,
    required this.timePost,
  });

  Exercise copy() => Exercise(
        id: id,
        userId: userId,
        category: category,
        title: title,
        description: description,
        icon: icon,
        created: created,
        updated: updated,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        timePost: timePost,
      );

  Exercise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    category = json['category'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    created = json['created'];
    updated = json['updated'];
    type = json['type'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = json['timePost'];
  }

  Exercise.fromTest(Map<String, dynamic> json) {
    id = json['id'];
    userId = "1";
    category = json['category'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'] ?? "";
    created = "";
    updated = "";
    type = json['type'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = "";
  }

  Exercise.testWorkoutChild(Map<String, dynamic> json, Exercise e) {
    id = json['id'];
    userId = "1";
    category = json['category'] ?? e.category;
    title = json['title'] ?? e.title;
    description = json['description'] ?? e.description;
    created = "";
    updated = "";
    type = json['type'] ?? e.type;
    sets = json['sets'] ?? e.sets;
    reps = json['reps'] ?? e.reps;
    time = json['time'] ?? e.time;
    timePost = json['timePost'] ?? e.timePost;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "category": category,
      "title": title,
      "description": description,
      "icon": icon,
      "type": type,
      "reps": reps,
      "sets": sets,
      "time": time,
      "timePost": timePost,
    };
  }

  Future<void> insert() async {
    final db = await getDB();
    await db.insert(
      'exercise',
      toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Exercise>> getChildren() async {
    final db = await getDB();
    String query = """
      SELECT * FROM exercise_set es
      JOIN exercise e ON e.id = es.parentId
      WHERE es.parentId = '$id'
      ORDER BY es.exerciseOrder
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(query.trim());
    List<Exercise> e = [];
    for (var i in response) {
      e.add(Exercise.fromJson(i));
    }
    return e;
  }

  static Future<List<Exercise>> getList(String userId) async {
    final db = await getDB();
    final List<Map<String, dynamic>> response =
        await db.query('exercise', where: "userId = ?", whereArgs: [userId]);
    List<Exercise> w = [];
    for (var i in response) {
      w.add(Exercise.fromJson(i));
    }
    return w;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

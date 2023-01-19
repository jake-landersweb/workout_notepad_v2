import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Workout {
  late String id;
  late String userId;
  late String title;
  String? description;
  late String icon;
  late String created;
  late String updated;

  Workout({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.icon,
    required this.created,
    required this.updated,
  });

  Workout copy() => Workout(
        id: id,
        userId: userId,
        title: title,
        description: description,
        icon: icon,
        created: created,
        updated: updated,
      );

  Workout.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    title = json['title'];
    description = json['description'];
    icon = json['icon'];
    created = json['created'];
    updated = json['updated'];
  }

  Workout.fromTest(Map<String, dynamic> json) {
    id = json['id'];
    userId = "1";
    title = json['title'];
    description = json['description'];
    icon = json['icon'] ?? "";
    created = "";
    updated = "";
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "icon": icon,
      "description": description,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'workout',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  Future<List<Exercise>> getChildren() async {
    final db = await getDB();
    String query = """
      SELECT * FROM workout_exercise we
      JOIN exercise e ON e.id = we.exerciseId
      WHERE we.workoutId = '$id'
      ORDER BY we.exerciseOrder;
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(query.trim());
    List<Exercise> e = [];
    for (var i in response) {
      e.add(Exercise.fromJson(i));
    }
    return e;
  }

  Future<List<String>> getCategories() async {
    var exercises = await getChildren();
    List<String> c = [];
    for (var i in exercises) {
      if (i.category.isNotEmpty) {
        c.add(i.category);
      }
    }
    return c.toSet().toList();
  }

  static Future<List<Workout>> getList(String userId) async {
    final db = await getDB();
    final List<Map<String, dynamic>> response =
        await db.query('workout', where: "userId = ?", whereArgs: [userId]);
    List<Workout> w = [];
    for (var i in response) {
      w.add(Workout.fromJson(i));
    }
    return w;
  }
}

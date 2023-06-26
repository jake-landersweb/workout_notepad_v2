import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Category {
  late String title;
  late String userId;
  late String icon;

  Category({
    required this.title,
    required this.userId,
    required this.icon,
  });

  Category copy() => Category(title: title, userId: userId, icon: icon);

  Category.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    userId = json['userId'];
    icon = json['icon'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "userId": userId,
      "icon": icon,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await getDB();
    await db.insert(
      'category',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  static Future<List<Category>> getList(String userId) async {
    final db = await getDB();
    final List<Map<String, dynamic>> response =
        await db.query('category', where: "userId = ?", whereArgs: [userId]);
    List<Category> w = [];
    for (var i in response) {
      w.add(Category.fromJson(i));
    }
    return w;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

import 'package:sqflite/sql.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Category {
  late String title;
  late String icon;

  Category({
    required this.title,
    required this.icon,
  });

  Category copy() => Category(title: title, icon: icon);

  Category.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    icon = json['icon'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
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

  static Future<List<Category>> getList() async {
    final db = await getDB();
    final List<Map<String, dynamic>> response = await db.query('category');
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

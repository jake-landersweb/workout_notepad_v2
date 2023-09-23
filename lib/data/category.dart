import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Category {
  late String categoryId;
  late String title;
  late String icon;

  Category({
    required this.categoryId,
    required this.title,
    required this.icon,
  });

  Category.init({required this.title, required this.icon}) {
    categoryId = const Uuid().v4();
  }

  Category copy() => Category(categoryId: categoryId, title: title, icon: icon);

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    title = json['title'];
    icon = json['icon'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      "title": title.toLowerCase(),
      "icon": icon,
    };
  }

  Future<void> insert({ConflictAlgorithm? conflictAlgorithm}) async {
    final db = await DatabaseProvider().database;
    await db.insert(
      'category',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  static Future<List<Category>> getList({Database? db}) async {
    db ??= await DatabaseProvider().database;
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

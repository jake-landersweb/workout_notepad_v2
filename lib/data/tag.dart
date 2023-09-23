import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/model/root.dart';

class Tag {
  late String tagId;
  late String title;
  late bool isDefault;

  Tag({
    required this.tagId,
    required this.title,
    required this.isDefault,
  });

  Tag clone() => Tag(
        tagId: tagId,
        title: title,
        isDefault: isDefault,
      );

  Tag.init({required this.title}) {
    tagId = const Uuid().v4();
    isDefault = false;
  }

  Tag.fromJson(dynamic json) {
    tagId = json['tagId'];
    title = json['title'];
    isDefault = json['isDefault'] == 1;
  }

  Map<String, dynamic> toMap() {
    return {
      "tagId": tagId,
      "title": title,
      "isDefault": isDefault ? 1 : 0,
    };
  }

  Future<int> insert({
    ConflictAlgorithm? conflictAlgorithm,
    Database? db,
  }) async {
    db ??= await DatabaseProvider().database;
    var response = await db.insert(
      'tag',
      toMap(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    return response;
  }

  static Future<List<Tag>> getList({Database? db}) async {
    db ??= await DatabaseProvider().database;
    var response = await db.rawQuery("SELECT * FROM tag");
    List<Tag> t = [];
    for (var i in response) {
      t.add(Tag.fromJson(i));
    }
    return t;
  }
}

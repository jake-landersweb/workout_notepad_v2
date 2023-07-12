import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDB() async {
  // get db path
  String path = join(await getDatabasesPath(), 'workout_notepad.db');
  // delete the database
  // await databaseFactory.deleteDatabase(path);
  // create db
  Database db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      print("CREATING DATABASE");
      // open sql file
      String contents = await rootBundle.loadString("sql/init.sql");
      // split into sql functions
      List<String> functions = contents.split("--");
      // loop through and execute
      for (var i in functions) {
        if (i.isNotEmpty) {
          await db.execute(i.trim());
        }
      }
    },
  );
  return db;
}

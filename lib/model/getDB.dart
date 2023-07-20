import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> getDB() async {
  var prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey("dbVersion")) {
    await prefs.setInt("dbVersion", 1);
  }
  // get db path
  String path = join(await getDatabasesPath(), 'workout_notepad.db');
  // create db
  Database db = await openDatabase(
    path,
    version: prefs.getInt("dbVersion"),
    onDowngrade: (db, oldVersion, newVersion) {
      print("IGNORING DOWNGRADE");
    },
    onUpgrade: (db, oldVersion, newVersion) {
      print("UPGRADING DATABASE $oldVersion -> $newVersion");
    },
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

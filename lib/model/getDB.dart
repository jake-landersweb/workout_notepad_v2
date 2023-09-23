import 'package:flutter/services.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final DatabaseProvider _databaseService = DatabaseProvider._internal();
  factory DatabaseProvider() => _databaseService;
  DatabaseProvider._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // get db path
    String path = join(await getDatabasesPath(), 'workout_notepad.db');
    // create db
    Database db = await openDatabase(
      path,
      version: 1,
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

  Future<bool> delete() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      String path = join(await getDatabasesPath(), 'workout_notepad.db');
      await databaseFactory.deleteDatabase(path);
      return true;
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "db_delete"},
      );
      return false;
    }
  }
}

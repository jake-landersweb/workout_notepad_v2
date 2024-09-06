import 'dart:io';

import 'package:flutter/services.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const CURRENT_DATABASE_VERSION = 2;

class DatabaseProvider {
  static final DatabaseProvider _databaseService = DatabaseProvider._internal();
  factory DatabaseProvider() => _databaseService;
  DatabaseProvider._internal();
  static Database? _database;

  Future<String> _getPath() async {
    return join(await getDatabasesPath(), 'workout_notepad.db');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // get db path
    String path = await _getPath();
    // create db
    Database db = await openDatabase(
      path,
      version: 1,
      onDowngrade: (db, oldVersion, newVersion) {
        print("IGNORING DOWNGRADE");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          print("UPGRADING DATABASE $oldVersion -> $newVersion");
          // run through all migrations
          for (var i = oldVersion + 1; i <= newVersion; i++) {
            print("Migrating version: $i");
            String contents =
                await rootBundle.loadString("sql/migration_$i.sql");
            List<String> functions = contents.split("--");
            for (var i in functions) {
              if (i.isNotEmpty) {
                print("EXECUTING: $i");
                await db.execute(i.trim());
              }
            }
          }
        } catch (e) {
          print("FATAL ERROR RUNNING MIGRATIONS");
          print(e);
          rethrow;
        }
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

    // check for migrations
    print("Running initial migration ...");
    try {
      String contents = await rootBundle.loadString("sql/migration_1.sql");
      await db.execute(contents.trim());
    } catch (e, stack) {
      print("failed to run the initial migration");
      print(e);
      print(stack);
      rethrow;
    }

    print("Running all migrations");
    await runMigrations(db);

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

  Future<DateTime> getLastModifiedTime() async {
    var path = await _getPath();
    File file = File(path);
    return await file.lastModified();
  }

  Future<void> runMigrations(Database db) async {
    try {
      const migrations = [2];

      for (var i in migrations) {
        print("----");
        print("Checking migration: $i");

        var response =
            await db.rawQuery("SELECT * FROM migrations WHERE id = ?", [i]);
        if (response.isEmpty) {
          print("Migration $i not present");
          print("Running migration: $i");
          await db.transaction((txn) async {
            String contents =
                await rootBundle.loadString("sql/migration_$i.sql");
            List<String> functions = contents.split("--");
            for (var i in functions) {
              if (i.isNotEmpty) {
                print("EXECUTING: $i");
                await txn.execute(i.trim());
              }
            }

            // insert the new migration record
            await txn.insert("migrations", {"id": i});
          });
          print("Migration $i run successfully");
        } else {
          print("Migration $i present");
        }
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      rethrow;
    }
  }
}

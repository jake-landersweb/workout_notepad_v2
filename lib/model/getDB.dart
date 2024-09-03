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
      version: CURRENT_DATABASE_VERSION,
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
}

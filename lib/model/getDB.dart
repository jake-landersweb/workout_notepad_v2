import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/logger.dart';

class Mutex {
  Completer<void>? _completer;

  Future<void> acquire() async {
    while (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer<void>();
  }

  void release() {
    _completer?.complete();
    _completer = null;
  }
}

class DatabaseProvider {
  static final DatabaseProvider _databaseService = DatabaseProvider._internal();
  factory DatabaseProvider() => _databaseService;
  DatabaseProvider._internal();
  static Database? _database;
  final Mutex _mutex = Mutex();

  Future<String> _getPath() async {
    return join(await getDatabasesPath(), 'workout_notepad.db');
  }

  Future<Database> get database async {
    await _mutex.acquire();
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } finally {
      _mutex.release();
    }
  }

  Future<Database> _initDatabase() async {
    // get db path
    String path = await _getPath();
    // create db
    Database db = await openDatabase(
      path,
      version: 1,
      onDowngrade: (db, oldVersion, newVersion) {
        logger.debug("IGNORING DOWNGRADE");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        logger.debug("IGNORING UPGRADE");
      },
      onCreate: (db, version) async {
        logger.debug("CREATING DATABASE");
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
    logger.debug("Running initial migration ...");
    try {
      String contents = await rootBundle.loadString("sql/migration_1.sql");
      await db.execute(contents.trim());
      logger.debug("Running all migrations");
      await runMigrations(db);
      return db;
    } catch (e, stack) {
      logger.exception(e, stack);
      rethrow;
    }
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
    } catch (e, stack) {
      logger.exception(e, stack);
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
      const migrations = [2, 3, 4, 5];

      // await db.rawQuery("DELETE FROM migrations WHERE id = 4");

      for (var i in migrations) {
        var l = logger.withData({"migration": i});
        l.debug("Checking migration");

        var response =
            await db.rawQuery("SELECT * FROM migrations WHERE id = ?", [i]);
        if (response.isEmpty) {
          l.debug("Migration not present");
          l.debug("Running migration ...");
          await db.transaction((txn) async {
            String contents =
                await rootBundle.loadString("sql/migration_$i.sql");
            List<String> functions = contents.split("--");
            for (var i in functions) {
              if (i.isNotEmpty) {
                l.debug("Executing sql", {"sql": i});
                await txn.execute(i.trim());
              }
            }

            // insert the new migration record
            await txn.insert("migrations", {"id": i});
          });
          l.debug("Migration successful");
        } else {
          l.debug("Migration already exists");
        }
      }
    } catch (e, stack) {
      logger.exception(e, stack);
      rethrow;
    }
  }
}

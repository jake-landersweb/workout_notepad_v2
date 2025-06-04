// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:cached_query/cached_query.dart';
import 'package:flutter/foundation.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class QueryKey {
  static String PREVIOUS_WORKOUT_LOG() => "previous-workout-log";
}

class QueryModel extends ChangeNotifier {
  QueryModel() {
    CachedQuery.instance.config(
      config: QueryConfig(),
    );
  }

  void invalidate(String key) {
    CachedQuery.instance.invalidateCache(key: key);
    notifyListeners();
  }

  void invalidateAll() {
    CachedQuery.instance.invalidateCache(filterFn: (unencodedKey, key) => true);
    notifyListeners();
  }

  Stream<QueryState<Tuple2<WorkoutLog, List<List<ExerciseLog>>>?>>
      getPreviousWorkout() {
    final query = Query(
      key: QueryKey.PREVIOUS_WORKOUT_LOG(),
      queryFn: () async {
        var db = await DatabaseProvider().database;
        var response = await db.rawQuery(
            "SELECT * FROM workout_log ORDER BY created DESC LIMIT 1");
        if (response.isNotEmpty) {
          var wl = await WorkoutLog.fromJson(response[0]);
          var logs = await wl.getExercises(db: db);
          return Tuple2(wl, logs!);
        }
        return null;
      },
    );

    return query.stream;
  }
}

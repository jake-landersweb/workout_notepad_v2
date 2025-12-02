// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:cached_query/cached_query.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:workout_notepad_v2/model/getDB.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class QueryKey {
  static String PREVIOUS_WORKOUT_LOG([String? workoutLogId]) =>
      "previous-workout-log-${workoutLogId ?? ''}";
  static String PROFILE_PHOTO(String userId) {
    return "profile-photo-$userId";
  }
}

class QueryModel extends ChangeNotifier {
  QueryModel() {
    CachedQuery.instance.config(
      config: GlobalQueryConfig(
        staleDuration: Duration(minutes: 30),
        cacheDuration: Duration(minutes: 30),
      ),
    );
  }

  void invalidate(String key) {
    logger.info("Invalidating query", {"key": key});
    CachedQuery.instance.invalidateCache(key: key);
    notifyListeners();
  }

  void invalidateAll({KeyFilterFunc? fn}) {
    logger.info("Invalidating all queries");
    CachedQuery.instance.invalidateCache(filterFn: fn);
    notifyListeners();
  }

  Stream<QueryState<Tuple2<WorkoutLog, List<List<ExerciseLog>>>?>>
      getPreviousWorkout() {
    final query = Query(
      key: QueryKey.PREVIOUS_WORKOUT_LOG(),
      queryFn: () async {
        logger.debug("FETCHING PREVIOUS WORKOUT");
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

  Stream<QueryState<Tuple2<WorkoutLog, List<List<ExerciseLog>>>?>>
      getWorkoutLog(String workoutLogId) {
    final query = Query(
      key: QueryKey.PREVIOUS_WORKOUT_LOG(workoutLogId),
      queryFn: () async {
        logger.debug(
            "Fetching a previous workout log", {"workoutLogId": workoutLogId});
        var db = await DatabaseProvider().database;
        var response = await db.rawQuery(
            "SELECT * FROM workout_log WHERE workoutLogId = ?", [workoutLogId]);
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

  Stream<QueryState<Uint8List>> getProfilePhoto(String userId, String? imgUrl) {
    final query = Query(
      key: QueryKey.PROFILE_PHOTO(imgUrl ?? "default"),
      queryFn: () async {
        try {
          logger.debug("Fetching profile photo", {"imgUrl": imgUrl});

          // fetch the default avatar from the client
          if (imgUrl == null || imgUrl == "" || (imgUrl.contains("default"))) {
            logger.debug("fetching default profile photo", {
              "url": "/users/$userId/avatar",
            });
            final client = GoClient(client: http.Client());
            var resp = await client.fetch("/users/$userId/avatar");
            if (resp.statusCode != 200) {
              throw Exception("failed to fetch the default profile pic");
            }
            return resp.bodyBytes;
          }

          // fetch from a normal http request
          if (imgUrl.contains("http")) {
            logger.debug("fetching remote profile photo", {"url": imgUrl});
            var resp = await http.get(Uri.parse(imgUrl));
            if (resp.statusCode >= 300) {
              throw Exception("failed to fetch internet profile pic");
            }
            return resp.bodyBytes;
          }

          // fetch from a presigned url in s3
          logger.debug("fetching pre-signed url");
          var signedUrl = await getPresignedUrl(imgUrl);
          logger.debug("fetching s3 profile photo", {"url": signedUrl});
          var resp = await http.get(Uri.parse(signedUrl));
          if (resp.statusCode != 200) {
            throw Exception("failed to get image from s3: ${resp.body}");
          }

          logger.raw("resp.body");
          return resp.bodyBytes;
        } catch (error, stack) {
          logger.exception(error, stack);
          rethrow;
        }
      },
    );
    return query.stream;
  }
}

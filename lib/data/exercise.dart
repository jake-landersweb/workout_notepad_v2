import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum ExerciseType { weight, timed, duration, bw, distance, stretch }

ExerciseType exerciseTypeFromJson(int type) {
  switch (type) {
    case 0:
      return ExerciseType.weight;
    case 1:
      return ExerciseType.timed;
    case 2:
      return ExerciseType.duration;
    case 3:
      return ExerciseType.bw;
    case 4:
      return ExerciseType.distance;
    case 5:
      return ExerciseType.stretch;
    default:
      print(
          "Error, there was a default value in de-serializing exercise type $type");
      return ExerciseType.weight;
  }
}

String exerciseTypeTitle(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return "Weighted";
    case ExerciseType.timed:
      return "Count-up";
    case ExerciseType.duration:
      return "Count-down";
    case ExerciseType.bw:
      return "Body-weight";
    case ExerciseType.distance:
      return "Distance";
    case ExerciseType.stretch:
      return "Stretch";
  }
}

String exerciseTypeDesc(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return "An exercise where you track your reps completed and weight lifted for every set.";
    case ExerciseType.timed:
      return "This gives you a timer that counts up from 00:00, giving you an open goal to reach.";
    case ExerciseType.duration:
      return "An exercise with a traditional count-down timer. Gives you the convenience of a count-down timer.";
    case ExerciseType.bw:
      return "Exercises where you are not pushing any weight, such as calisthenics or air squats.";
    case ExerciseType.distance:
      return "For exercises where you are trying to track a distance. Includes the distance and the time elapsed.";
    case ExerciseType.stretch:
      return "For exercises that are stretching or warmups. Logging is turned off by default.";
  }
}

String exerciseTypeIcon(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return "assets/icons/strength-96.png";
    case ExerciseType.timed:
      return "assets/icons/time-96.png";
    case ExerciseType.duration:
      return "assets/icons/clock-96.png";
    case ExerciseType.bw:
      return "assets/icons/sit-ups-96.png";
    case ExerciseType.distance:
      return "assets/icons/exercise-96.png";
    case ExerciseType.stretch:
      return "assets/icons/floating-guru-skin-type-2-96.png";
  }
}

Color exerciseTypeColor(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return Colors.red[300]!;
    case ExerciseType.timed:
      return Colors.green[300]!;
    case ExerciseType.duration:
      return Colors.blue[300]!;
    case ExerciseType.bw:
      return Colors.yellow[700]!;
    case ExerciseType.distance:
      return Colors.yellow[700]!;
    case ExerciseType.stretch:
      return Colors.yellow[700]!;
  }
}

int exerciseTypeToJson(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return 0;
    case ExerciseType.timed:
      return 1;
    case ExerciseType.duration:
      return 2;
    case ExerciseType.bw:
      return 3;
    case ExerciseType.distance:
      return 4;
    case ExerciseType.stretch:
      return 5;
  }
}

class Exercise {
  late String exerciseId;
  late String title;
  late String category;
  late String description;
  late String difficulty;
  late String icon;
  late ExerciseType type;
  late int sets;
  late int reps;
  late int time;
  String? filename;

  // after v1.1.0
  late double distance;
  late String distancePost;

  Exercise({
    required this.exerciseId,
    required this.title,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.type,
    required this.sets,
    required this.reps,
    required this.time,
    this.filename,
    required this.distance,
    required this.distancePost,
  });

  Exercise copy() => Exercise(
        exerciseId: exerciseId,
        title: title,
        category: category,
        description: description,
        difficulty: difficulty,
        icon: icon,
        type: type,
        reps: reps,
        sets: sets,
        time: time,
        filename: filename,
        distance: distance,
        distancePost: distancePost,
      );

  // create a copy of sorts, mostly helpful for implementations
  // converting between each other
  Exercise.fromSelf(Exercise e) {
    exerciseId = e.exerciseId;
    title = e.title;
    category = e.category;
    description = e.description;
    difficulty = e.difficulty;
    icon = e.icon;
    type = e.type;
    sets = e.sets;
    reps = e.reps;
    time = e.time;
    filename = e.filename;
    distance = e.distance;
    distancePost = e.distancePost;
  }

  // for converting to json
  Exercise.fromJson(dynamic json) {
    exerciseId = json['exerciseId'];
    title = json['title'];
    category = json['category'];
    description = json['description'];
    difficulty = json['difficulty'] ?? "";
    icon = json['icon'];
    type = exerciseTypeFromJson(json['type']);
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    filename = json['fname'];
    distance = json['distance'] ?? 0;
    distancePost = json['distancePost'] ?? "";
  }

  Exercise.empty() {
    exerciseId = const Uuid().v4();
    title = "";
    category = "";
    description = "";
    difficulty = "Intermediate";
    icon = "";
    type = ExerciseType.weight;
    sets = 1;
    reps = 1;
    time = 0;
    distance = 1;
    distancePost = "km";
  }

  Widget getIcon(List<Category> categories, {double? size}) {
    Category? match = categories.firstWhereOrNull(
      (element) => element.categoryId.toLowerCase() == category.toLowerCase(),
    );
    if (match == null) {
      return SizedBox(height: size, width: size);
    }
    return getImageIcon(match.icon, size: size);
  }

  // method implementations
  Map<String, dynamic> toMap() {
    return {
      "exerciseId": exerciseId,
      "category": category,
      "title": title,
      "description": description,
      "difficulty": difficulty,
      "icon": icon,
      "type": exerciseTypeToJson(type),
      "reps": reps,
      "sets": sets,
      "time": time,
      "fname": filename,
      "distance": distance,
      "distancePost": distancePost,
    };
  }

  // easy printing
  @override
  String toString() {
    return toMap().toString();
  }

  Widget info(
    BuildContext context, {
    TextStyle? style,
  }) {
    return RichText(text: infoRaw(context, style: style));
  }

  TextSpan infoRaw(
    BuildContext context, {
    TextStyle? style,
  }) {
    var s = "";
    if (sets == 1) {
      s = "";
    } else {
      s = "$sets ";
    }
    switch (type) {
      // TODO -- add the info here
      case ExerciseType.timed:
      case ExerciseType.duration:
        return TextSpan(
          text: "${s}x ${getTime()}",
          style: style ?? ttBody(context),
        );

      default:
        return TextSpan(
          text: "${s}x $reps",
          style: style ?? ttBody(context),
        );
    }
  }

  // get as hh:mm:ss
  String getTime() {
    return formatHHMMSS(time);
  }

  /// Convert 00:00:00 to time
  void setTime(String hhmmss) {
    var items = hhmmss.split(":").reversed.toList();
    var secs = int.parse(items[0]);
    var mins = int.parse(items[1]);
    var hours = 0;
    if (items.length > 2) {
      hours = int.parse(items[2]);
    }
    time = Duration(hours: hours, minutes: mins, seconds: secs).inSeconds;
  }

  int getHours() {
    var items = formatHHMMSS(time, truncate: false).split(":");
    return int.parse(items[0]);
  }

  int getMinutes() {
    var items = formatHHMMSS(time, truncate: false).split(":");
    return int.parse(items[1]);
  }

  int getSeconds() {
    var items = formatHHMMSS(time, truncate: false).split(":");
    return int.parse(items[2]);
  }

  void setHours(int hours) {
    var items = formatHHMMSS(time, truncate: false).split(":");
    time = Duration(
      hours: hours,
      minutes: int.parse(items[1]),
      seconds: int.parse(items[2]),
    ).inSeconds;
  }

  void setMinutes(int min) {
    var items = formatHHMMSS(time, truncate: false).split(":");
    time = Duration(
      hours: int.parse(items[0]),
      minutes: min,
      seconds: int.parse(items[2]),
    ).inSeconds;
  }

  void setSeconds(int sec) {
    var items = formatHHMMSS(time, truncate: false).split(":");
    time = Duration(
      hours: int.parse(items[0]),
      minutes: int.parse(items[1]),
      seconds: sec,
    ).inSeconds;
  }

  Duration getDuration() {
    return Duration(seconds: time);
  }

  void setDuration(Duration duration) {
    time = duration.inSeconds;
  }

  Future<List<ExerciseLog>> getLogs(String exerciseId, bool premiumUser) async {
    var db = await DatabaseProvider().database;
    String sql = """
      SELECT * FROM exercise_log WHERE exerciseId = '$exerciseId'
      ORDER BY created DESC
      ${premiumUser ? '' : 'LIMIT 7'}
    """;
    var response = await db.rawQuery(sql);
    List<ExerciseLog> items = [];
    for (var i in response) {
      items.add(await ExerciseLog.fromJson(i));
    }
    return items;
  }

  static Future<List<Exercise>> getList({Database? db}) async {
    db ??= await DatabaseProvider().database;
    var sql = """
      SELECT * FROM exercise
      ORDER BY created DESC
    """;
    final List<Map<String, dynamic>> response = await db.rawQuery(sql);
    List<Exercise> w = [];
    for (var i in response) {
      w.add(Exercise.fromJson(i));
    }
    return w;
  }
}

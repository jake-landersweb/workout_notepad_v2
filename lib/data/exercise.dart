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

enum ExerciseType { weight, timed, duration, bw }

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
  }
}

String exerciseTypeDesc(ExerciseType type) {
  switch (type) {
    case ExerciseType.weight:
      return "An exercise where you track your reps completed and weight lifted for every set. This is the default exercise type and suitable for most exericses in a traditional workout plan.";
    case ExerciseType.timed:
      return "This gives you a timer that counts up from 00:00, giving you an open goal to either complete the exercise in less than the time, or edure the exercise for longer than this time.";
    case ExerciseType.duration:
      return "An exercise with a traditional count-down timer. This is good for ab workouts where you want to hold something for x minutes, and want the convenience of a timer in the app.";
    case ExerciseType.bw:
      return "Suitable for workouts where you are not moving any weight. This can be air squats, pullups, burpees, etc. If you do plan on adding weight later, either create another exercise or use a weighed exercise with weight 0.";
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
  }

  // for converting to json
  Exercise.fromJson(dynamic json) {
    exerciseId = json['exerciseId'];
    title = json['title'];
    category = json['category'].toString();
    description = json['description'];
    difficulty = json['difficulty'] ?? "";
    icon = json['icon'];
    type = exerciseTypeFromJson(json['type']);
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    filename = json['fname'];
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

  // helpful function for getting exercise values inside of
  // a workout template, where an exercise needs to be imported
  Map<String, dynamic> rootExerciseMap() {
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
    };
  }

  // method implementations
  Map<String, dynamic> toMap() {
    return rootExerciseMap();
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

  Comparable getUniqueId() {
    return exerciseId;
  }
}

import 'package:flutter/material.dart';
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

abstract class ExerciseBase {
  late String title;
  late String category;
  late String description;
  late String icon;
  late ExerciseType type;
  late int sets;
  late int reps;
  late int time;

  ExerciseBase({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.type,
    required this.sets,
    required this.reps,
    required this.time,
  });

  // create a copy of sorts, mostly helpful for implementations
  // converting between each other
  ExerciseBase.fromSelf(ExerciseBase e) {
    title = e.title;
    category = e.category;
    description = e.description;
    icon = e.icon;
    type = e.type;
    sets = e.sets;
    reps = e.reps;
    time = e.time;
  }

  // for converting to json
  ExerciseBase.fromJson(dynamic json) {
    title = json['title'];
    category = json['category'];
    description = json['description'];
    icon = json['icon'];
    type = exerciseTypeFromJson(json['type']);
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
  }

  ExerciseBase.empty() {
    title = "";
    category = "";
    description = "";
    icon = "";
    type = ExerciseType.weight;
    sets = 1;
    reps = 1;
    time = 0;
  }

  Widget getIcon(List<Category> categories, {double? size}) {
    Category match = categories.firstWhere(
      (element) => element.title.toLowerCase() == category.toLowerCase(),
      orElse: () => Category(title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return const SizedBox(height: 50, width: 50);
    }
    return getImageIcon(match.icon, size: size);
  }

  // method implementations
  Future<int> insert();
  Future<int> update();
  Map<String, dynamic> toMap();

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

  Future<List<ExerciseLog>> getLogs(String exerciseId) async {
    var db = await getDB();
    String sql = """
      SELECT * FROM exercise_log WHERE exerciseId = '$exerciseId'
      ORDER BY created DESC
    """;
    var response = await db.rawQuery(sql);
    List<ExerciseLog> items = [];
    for (var i in response) {
      items.add(ExerciseLog.fromJson(i));
    }
    return items;
  }
}

import 'dart:io';

import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:path/path.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:http/http.dart' as http;
import 'package:workout_notepad_v2/model/env.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class ExerciseDetails {
  late String exerciseId;
  late String objectId;
  late String description;
  late String difficultyLevel;
  late String equipmentNeeded;
  late int restTime;
  late String cues;

  // not in database
  late AppFile file;

  ExerciseDetails({
    required this.exerciseId,
    required this.objectId,
    required this.description,
    required this.difficultyLevel,
    required this.equipmentNeeded,
    required this.restTime,
    required this.cues,
  }) {
    file = AppFile(objectId: objectId);
  }

  ExerciseDetails.init({
    required this.exerciseId,
  }) {
    objectId = "";
    description = "";
    difficultyLevel = "";
    equipmentNeeded = "";
    restTime = 60;
    cues = "";
    file = AppFile(objectId: objectId);
  }

  static Future<ExerciseDetails> fromJson(dynamic json) async {
    var details = ExerciseDetails(
      exerciseId: json['exerciseId'],
      objectId: json['objectId'],
      description: json['description'],
      difficultyLevel: json['difficultyLevel'],
      equipmentNeeded: json['equipmentNeeded'],
      restTime: json['restTime'],
      cues: json['cues'],
    );
    details.file = AppFile(objectId: details.objectId);
    // load caches
    if (details.objectId.isNotEmpty) {
      await details.file.getCached();
    }
    return details;
  }

  int getHours() {
    var items = formatHHMMSS(restTime, truncate: false).split(":");
    return int.parse(items[0]);
  }

  int getMinutes() {
    var items = formatHHMMSS(restTime, truncate: false).split(":");
    return int.parse(items[1]);
  }

  int getSeconds() {
    var items = formatHHMMSS(restTime, truncate: false).split(":");
    return int.parse(items[2]);
  }

  Map<String, dynamic> toMap() => {
        "exerciseId": exerciseId,
        "objectId": objectId,
        "description": description,
        "difficultyLevel": difficultyLevel,
        "equipmentNeeded": equipmentNeeded,
        "restTime": restTime,
        "cues": cues,
      };

  @override
  String toString() => toMap().toString();
}

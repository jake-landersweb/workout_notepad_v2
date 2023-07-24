import 'dart:io';

import 'package:workout_notepad_v2/components/root.dart';

class ExerciseDetails {
  late String exerciseId;
  File? file;
  late String description;
  late String difficultyLevel;
  late String equipmentNeeded;
  late int restTime;
  late String cues;

  ExerciseDetails({
    required this.exerciseId,
    this.file,
    required this.description,
    required this.difficultyLevel,
    required this.equipmentNeeded,
    required this.restTime,
    required this.cues,
  });

  ExerciseDetails.init({
    required this.exerciseId,
  }) {
    description = "";
    difficultyLevel = "";
    equipmentNeeded = "";
    restTime = 60;
    cues = "";
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
}

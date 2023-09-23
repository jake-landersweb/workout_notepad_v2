import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';

class WorkoutSnapshot {
  late String workoutSnapshotId;
  late String workoutId;
  late Map<String, dynamic> jsonData;
  String? created;
  late int createdEpoch;

  WorkoutSnapshot({
    required this.workoutSnapshotId,
    required this.workoutId,
    required this.jsonData,
    this.created,
    required this.createdEpoch,
  });

  WorkoutSnapshot.init({
    required this.workoutId,
    required this.jsonData,
  }) {
    workoutSnapshotId = const Uuid().v4();
    createdEpoch = DateTime.now().millisecondsSinceEpoch;
  }

  WorkoutSnapshot.fromJson(dynamic json) {
    workoutSnapshotId = json['workoutSnapshotId'];
    workoutId = json['workoutId'];
    jsonData = jsonDecode(json['jsonData']);
    created = json['created'];
    createdEpoch = json['createdEpoch'];
  }

  Map<String, dynamic> toMap() => {
        "workoutSnapshotId": workoutSnapshotId,
        "workoutId": workoutId,
        "jsonData": jsonEncode(jsonData),
        "createdEpoch": createdEpoch,
      };

  WorkoutCloneObject renderSnapshot() {
    Workout w = Workout(
      workoutId: workoutId,
      title: jsonData['title'],
      description: jsonData['description'],
      icon: jsonData['icon'],
      created: "",
      updated: "",
      template: false,
      categories: [],
      exercises: [],
    );
    List<List<WorkoutExercise>> items = [];
    for (var i in jsonData['children']) {
      List<WorkoutExercise> tmp = [];
      for (var j in i) {
        var we = WorkoutExercise.fromJson(j);
        tmp.add(we);
      }
      items.add(tmp);
    }
    return WorkoutCloneObject(workout: w, exercises: items);
  }

  @override
  String toString() => toMap().toString();
}

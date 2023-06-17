import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:sqflite/sql.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';

Future<void> loadTests() async {
  String contents = await rootBundle.loadString("sql/tests.json");
  Map<String, dynamic> json = const JsonDecoder().convert(contents);

  // read and create all exercises
  for (var i in json['exercises']) {
    Exercise e = Exercise.fromTest(i);
    await e.insert();
    // create a category
    if (e.category.isNotEmpty) {
      Category c = Category(title: e.category, userId: "1");
      await c.insert(
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  final db = await getDB();

  List<Map<String, dynamic>> response = await db.query("exercise");
  List<Exercise> exercises = [];
  for (var i in response) {
    exercises.add(Exercise.fromJson(i));
  }

  // load all workouts
  for (var jworkout in json['workouts']) {
    Workout w = Workout.fromTest(jworkout['workout']);
    await w.insert(
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<WorkoutExercise> workoutExercises = [];
    // get the exercise and create the relations
    for (var jexercise in jworkout['exercises']) {
      List<ExerciseSet> exerciseSets = [];
      try {
        Exercise parentExercise = exercises.firstWhere((element) =>
            element.exerciseId == jexercise['parent']['exerciseId']);
        var we = WorkoutExercise.init(
          w,
          parentExercise,
          ExerciseChildArgs(
            order: 0,
            sets: jexercise['parent']['sets'],
            reps: jexercise['parent']['reps'],
            time: jexercise['parent']['time'],
            timePost: jexercise['parent']['timePost'],
          ),
        );
        // create the workout exercise
        workoutExercises.add(we);
        // look for exercise children
        for (var jchild in jexercise['children']) {
          try {
            Exercise childEx = exercises.firstWhere(
              (element) => element.exerciseId == jchild['exerciseId'],
            );
            // create exercise set
            exerciseSets.add(
              ExerciseSet.init(
                w,
                we,
                childEx,
                ExerciseChildArgs(
                  order: 0,
                  sets: jchild['sets'],
                  reps: jchild['reps'],
                  time: jchild['time'],
                  timePost: jchild['timePost'],
                ),
              ),
            );
          } catch (_) {}
        }
        // add all exercise sets
        for (int i = 0; i < exerciseSets.length; i++) {
          exerciseSets[i].exerciseOrder = i;
          await exerciseSets[i].insert(
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      } catch (_) {}
    }
    // add all workout exercises
    for (int i = 0; i < workoutExercises.length; i++) {
      workoutExercises[i].exerciseOrder = i;
      await workoutExercises[i].insert(
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // add all logs
    for (int i = 0; i < json['logs'].length; i++) {
      json['logs'][i]['exerciseLogId'] = const Uuid().v4();
      json['logs'][i]['userId'] = "1";
      await db.insert(
        'exercise_log',
        json['logs'][i],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  log("[TEST] successfully created test data");
}

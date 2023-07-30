// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_details.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/image.dart';

class CreateExerciseModel extends ChangeNotifier {
  late Exercise exercise;
  late ExerciseDetails exerciseDetails;
  late String fileObjectId;
  bool deleteFile = false;
  bool initWithFile = false;
  bool existingDetail = false;

  CreateExerciseModel.create(DataModel dmodel, String uid) {
    exercise = Exercise.empty(uid);
    exerciseDetails = ExerciseDetails.init(exerciseId: exercise.exerciseId);
    fileObjectId = "${dmodel.user!.userId}-${exercise.exerciseId}";
  }

  CreateExerciseModel.update(
    DataModel dmodel,
    Exercise exercise,
  ) {
    this.exercise = exercise.copy();
    fileObjectId = "${dmodel.user!.userId}-${exercise.exerciseId}";
    updateInit();
  }

  Future<void> updateInit() async {
    var db = await getDB();
    var response = await db.rawQuery(
      "SELECT * FROM exercise_detail WHERE exerciseId = '${exercise.exerciseId}'",
    );
    print(response);
    var r2 = await db.rawQuery("SELECT * FROM exercise_detail");
    print(r2);
    // exerciseDetails = ExerciseDetails.init(exerciseId: exercise.exerciseId);
    if (response.isEmpty) {
      exerciseDetails = ExerciseDetails.init(exerciseId: exercise.exerciseId);
    } else {
      exerciseDetails = await ExerciseDetails.fromJson(response[0]);
      if (exerciseDetails.objectId.isNotEmpty) {
        initWithFile = true;
      }
      existingDetail = true;
    }
    notifyListeners();
  }

  bool isValid() {
    if (exercise.title.isEmpty) {
      return false;
    }
    return true;
  }

  Future<Exercise?> post(
    BuildContext context,
    DataModel dmodel,
    bool update,
  ) async {
    if (!isValid()) {
      return null;
    }

    // try to upload the exercise detail asset first if applicable
    if (exerciseDetails.file.file != null) {
      print("uploading image for this exercise detail ...");
      // upload every time the user updates. Sometimes this will result in duplicate uploads, but they get handled

      // compress the file
      var response = await exerciseDetails.file.upload(dmodel.user!.userId);
      if (!response) {
        print("There was an issue uploading the image");
        var cont = false;
        await showAlert(
          context: context,
          title: "Issue Uploading Media",
          body: const Text(
              "There was an error uploading the asset you specified for this exercise. Do you want to continue anyways? This can always be tried again later."),
          cancelText: "Cancel",
          onCancel: () {},
          submitText: "Continue",
          onSubmit: () {
            cont = true;
          },
        );
        if (!cont) {
          return null;
        }
      } else {
        print("Successfully uploaded");
        exerciseDetails.objectId = exerciseDetails.file.objectId;
      }
    } else if (deleteFile && initWithFile) {
      await exerciseDetails.file.deleteAWS();
      exerciseDetails.objectId = "";
    }

    // create in transaction
    var db = await getDB();

    if (update) {
      try {
        await db.transaction((txn) async {
          await txn.update(
            'exercise',
            exercise.toMap(),
            where: "exerciseId = ?",
            whereArgs: [exercise.exerciseId],
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (existingDetail) {
            await txn.update(
              "exercise_detail",
              exerciseDetails.toMap(),
              where: "exerciseId = ?",
              whereArgs: [exerciseDetails.exerciseId],
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          } else {
            await txn.insert("exercise_detail", exerciseDetails.toMap());
          }
        });

        return exercise;
      } catch (e) {
        NewrelicMobile.instance.recordError(
          e,
          StackTrace.current,
          attributes: {"err_code": "exercise_update"},
        );
        print(e);
        return null;
      }
    } else {
      try {
        await db.transaction((txn) async {
          await txn.insert("exercise", exercise.toMap());
          await txn.insert("exercise_detail", exerciseDetails.toMap());
        });

        return exercise;
      } catch (e) {
        NewrelicMobile.instance.recordError(
          e,
          StackTrace.current,
          attributes: {"err_code": "exercise_create"},
        );
        print(e);
        return null;
      }
    }
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/image.dart';

class CreateExerciseModel extends ChangeNotifier {
  late Exercise exercise;
  late String fileObjectId;
  late AppFile file;
  bool deleteFile = false;
  bool initWithFile = false;
  bool fileChanged = true;

  CreateExerciseModel.create(DataModel dmodel, String uid) {
    exercise = Exercise.empty();
    fileObjectId = "${dmodel.user!.userId}-${exercise.exerciseId}";
    file = AppFile.init(objectId: fileObjectId);
  }

  CreateExerciseModel.update(
    DataModel dmodel,
    Exercise exercise,
  ) {
    this.exercise = exercise.copy();

    if (this.exercise.filename?.isEmpty ?? true) {
      file = AppFile.init(
          objectId: "${dmodel.user!.userId}-${exercise.exerciseId}");
    } else {
      file = AppFile.fromFilenameSync(filename: this.exercise.filename!);
      updateInit();
    }
  }

  Future<void> updateInit() async {
    // check if file exists in remote
    await file.getCached();
    if (file.file?.existsSync() ?? false) {
      initWithFile = true;
      fileChanged = false;
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
    if (file.file != null && fileChanged) {
      print("uploading image for this exercise detail ...");
      // upload every time the user updates. Sometimes this will result in duplicate uploads, but they get handled

      // compress the file
      var response = await file.upload(dmodel.user!.userId);
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
        exercise.filename = file.filename;
      }
    } else if (deleteFile && initWithFile) {
      await file.deleteAWS();
      exercise.filename = "";
    }

    // create in transaction
    var db = await DatabaseProvider().database;

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

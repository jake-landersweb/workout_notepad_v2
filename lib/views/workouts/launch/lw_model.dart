import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/exercise_set.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/model/root.dart';

class LaunchWorkoutModel extends ChangeNotifier {
  late String userId;

  int workoutIndex = 0;
  late Workout workout;
  late List<WorkoutExercise> exercises;
  late PageController pageController;
  late WorkoutLog wl;
  late int duration;
  List<List<ExerciseSet>> exerciseChildren = [];
  List<ExerciseLog> exerciseLogs = [];
  List<List<ExerciseLog>> exerciseChildLogs = [];

  double offsetY = -5;

  LaunchWorkoutModel(String uid, Workout w, List<WorkoutExercise>? e) {
    userId = uid;
    workout = w;
    exercises = e ?? [];
    pageController = PageController(initialPage: workoutIndex);
    wl = WorkoutLog.init(userId, workout);
    duration = 0;
    _getExerciseChildren();
    init();
  }

  Future<void> _getExerciseChildren() async {
    if (exercises.isEmpty) {
      // get the exercise children
      exercises = await workout.getChildren();
    }
    for (int i = 0; i < exercises.length; i++) {
      var tmp = await exercises[i].getChildren(workout.workoutId);
      exerciseChildren.add(tmp);
      // create the log group for each exercise
      exerciseLogs.add(
        ExerciseLog.workoutInit(
          userId,
          exercises[i].exerciseId,
          wl.workoutLogId,
          exercises[i],
        ),
      );

      // create the logs for the children as well
      exerciseChildLogs.add([]);
      for (var j in tmp) {
        exerciseChildLogs[i].add(
          ExerciseLog.workoutInit(
            userId,
            j.childId,
            wl.workoutLogId,
            j,
          ),
        );
      }
    }

    notifyListeners();
  }

  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    offsetY = 0;
    notifyListeners();
  }

  void setIndex(int index) {
    workoutIndex = index;
    notifyListeners();
  }

  void setPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
    );
  }

  void setLogReps(int index, int row, int val) {
    exerciseLogs[index].metadata[row].reps = val;
    notifyListeners();
  }

  void setLogWeight(int index, int row, int val) {
    exerciseLogs[index].metadata[row].weight = val;
    notifyListeners();
  }

  void setLogWeightPost(int index, String val) {
    exerciseLogs[index].weightPost = val;
    notifyListeners();
  }

  void setLogTime(int index, int row, int val) {
    exerciseLogs[index].metadata[row].time = val;
    notifyListeners();
  }

  void setLogTimePost(int index, String val) {
    exerciseLogs[index].timePost = val;
    notifyListeners();
  }

  void setLogSaved(int index, int row, bool val) {
    exerciseLogs[index].metadata[row].saved = val;
    notifyListeners();
  }

  void removeLogSet(int index, int row) {
    exerciseLogs[index].removeSet(row);
    notifyListeners();
  }

  void addLogSet(int index) {
    exerciseLogs[index].addSet();
    notifyListeners();
  }

  void setLogChildReps(int i, int j, int row, int val) {
    exerciseChildLogs[i][j].metadata[row].reps = val;
    notifyListeners();
  }

  void setLogChildWeight(int i, int j, int row, int val) {
    exerciseChildLogs[i][j].metadata[row].weight = val;
    notifyListeners();
  }

  void setLogChildWeightPost(int i, int j, String val) {
    exerciseChildLogs[i][j].weightPost = val;
    notifyListeners();
  }

  void setLogChildTime(int i, int j, int row, int val) {
    exerciseChildLogs[i][j].metadata[row].time = val;
    notifyListeners();
  }

  void setLogChildTimePost(int i, int j, String val) {
    exerciseChildLogs[i][j].timePost = val;
    notifyListeners();
  }

  void setLogChildSaved(int i, int j, int row, bool val) {
    exerciseChildLogs[i][j].metadata[row].saved = val;
    notifyListeners();
  }

  void removeLogChildSet(int i, int j, int row) {
    exerciseChildLogs[i][j].removeSet(row);
    notifyListeners();
  }

  void addLogChildSet(int i, int j) {
    exerciseChildLogs[i][j].addSet();
    notifyListeners();
  }

  Future<void> finishWorkout(DataModel dmodel) async {
    // loop through all logs and create log records
    for (var i in exerciseLogs) {
      // remove all logs entries that are not complete
      i.metadata.removeWhere((element) => !element.saved);
      // check if empty
      if (i.metadata.isEmpty) {
        continue;
      }
      // add log
      await i.insert();
    }

    // loop through all log children to create records
    for (var i in exerciseChildLogs) {
      for (var j in i) {
        j.metadata.removeWhere((element) => !element.saved);
        if (j.metadata.isEmpty) {
          continue;
        }
        await j.insert();
      }
    }

    // determine duration workout has gone on
    wl.duration = duration;

    // insert the workout
    await wl.insert();
  }
}

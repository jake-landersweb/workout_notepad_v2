import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/root.dart';

enum AccumulateType { avg, max, min }

enum DistributionBarType { weight, reps }

class ELModel extends ChangeNotifier {
  late PageController pageController;
  int index = 0;

  late Exercise exercise;
  List<ExerciseLog> logs = [];
  bool isLoading = true;
  bool isLbs = true;
  double _max = double.negativeInfinity;
  final List<num> _all = [];
  double _min = double.infinity;
  double maxReps = double.negativeInfinity;
  final List<num> _allReps = [];
  double minReps = double.infinity;

  ELModel({required this.exercise, required bool premiumUser}) {
    pageController = PageController();
    init(premiumUser: premiumUser);
  }

  Future<void> init({required bool premiumUser}) async {
    isLoading = true;
    notifyListeners();
    // get logs
    logs = await exercise.getLogs(exercise.exerciseId, premiumUser);
    // create dashboard data from these logs
    await compose();
    isLoading = false;
    notifyListeners();
  }

  Future<void> compose() async {
    // create the data needed for the dashboard
    for (var l in logs) {
      for (var m in l.metadata) {
        switch (exercise.type) {
          case ExerciseType.weight:
            var adjustedWeight = _getAdjustedWeight(l, m.weight, isLbs);
            _max = max(_max, adjustedWeight);
            _min = min(_min, adjustedWeight);
            _all.add(adjustedWeight);
            break;
          case ExerciseType.timed:
          case ExerciseType.duration:
            _max = max(_max, m.time.toDouble());
            _min = min(_min, m.time.toDouble());
            _all.add(m.time);
            break;
          case ExerciseType.bw:
            break;
        }
        maxReps = max(maxReps, m.reps.toDouble());
        minReps = min(minReps, m.reps.toDouble());
        _allReps.add(m.reps);
      }
    }
  }

  String get weightPost {
    return isLbs ? "lbs" : "kg";
  }

  String get maxVal {
    switch (exercise.type) {
      case ExerciseType.weight:
        return "${_max.toStringAsFixed(2)} $weightPost";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return formatHHMMSS(_max.round());
      case ExerciseType.distance:
      case ExerciseType.stretch:
      case ExerciseType.bw:
        throw "unimplemented";
    }
  }

  String get minVal {
    switch (exercise.type) {
      case ExerciseType.weight:
        return "${_min.toStringAsFixed(2)} $weightPost";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return formatHHMMSS(_min.round());
      case ExerciseType.distance:
      case ExerciseType.stretch:
      case ExerciseType.bw:
        throw "unimplemented";
    }
  }

  String get avgVal {
    var a = _all.reduce((a, b) => a + b) / _all.length;
    switch (exercise.type) {
      case ExerciseType.weight:
        return "${a.toStringAsFixed(2)} $weightPost";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return formatHHMMSS(a.round());
      case ExerciseType.distance:
      case ExerciseType.stretch:
      case ExerciseType.bw:
        throw "unimplemented";
    }
  }

  double get avgReps {
    return _allReps.reduce((a, b) => a + b) / _allReps.length;
  }

  void setIndex(int i) {
    index = i;
    notifyListeners();
  }

  void setPage(int i) {
    pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
    );
  }
}

/// Account for logs being represented in kg or lbs
double _getAdjustedWeight(ExerciseLog log, num val, bool isLbs) {
  // if (log.weightPost == "lbs") {
  //   if (isLbs) {
  //     return val.toDouble();
  //   } else {
  //     return val / 2.205;
  //   }
  // } else {
  //   if (isLbs) {
  //     return val * 2.205;
  //   } else {
  //     return val.toDouble();
  //   }
  // }
  // TODO--
  return val.toDouble();
}

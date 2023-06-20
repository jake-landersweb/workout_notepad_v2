import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

import 'package:workout_notepad_v2/utils/root.dart';

enum AccumulateType { avg, max, min }

class ELModel extends ChangeNotifier {
  late Exercise exercise;
  List<ExerciseLog> logs = [];

  List<FlSpot> wData = [];
  List<String> wDates = [];
  double wMax = 0;
  double wMin = double.infinity;
  int wPage = 1;
  int wPageSize = 5;
  AccumulateType accumulateType = AccumulateType.avg;
  bool isLbs = false;

  late PageController pageController;
  late int currentIndex;

  ELModel({
    required this.exercise,
  }) {
    currentIndex = 0;
    pageController = PageController(initialPage: currentIndex);
    init();
  }

  Future<void> init() async {
    logs = await exercise.getLogs(exercise.exerciseId);
    createWeightData();
    notifyListeners();
  }

  void onPageChange(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void navigateTo(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Sprung(36),
    );
  }

  void wNextPage() {
    if (wData.length - (wPageSize * wPage) > 0) {
      wPage += 1;
    }
    notifyListeners();
  }

  void wPrevPage() {
    if (wPage > 1) {
      wPage -= 1;
    }
    notifyListeners();
  }

  void toggleAccumulate() {
    switch (accumulateType) {
      case AccumulateType.avg:
        accumulateType = AccumulateType.max;
        break;
      case AccumulateType.max:
        accumulateType = AccumulateType.min;
        break;
      case AccumulateType.min:
        accumulateType = AccumulateType.avg;
        break;
    }
    createWeightData();
    notifyListeners();
  }

  void toggleWeight() {
    isLbs = !isLbs;
    createWeightData();
    notifyListeners();
  }

  List<FlSpot> wgetData() {
    if (wData.length <= wPageSize) {
      return wData;
    } else {
      var start = wData.length - (wPageSize * wPage);
      if (start < 0) {
        start = 0;
      }
      return wData.sublist(start, start + wPageSize);
    }
  }

  List<String> wgetDates() {
    if (wDates.length <= wPageSize) {
      return wDates;
    } else {
      var start = wData.length - (wPageSize * wPage);
      if (start < 0) {
        start = 0;
      }
      return wDates.sublist(start, start + wPageSize);
    }
  }

  void createWeightData() {
    List<FlSpot> spots = [];
    wMax = 0;
    wMin = double.infinity;
    // get the furthest back date
    DateTime beginDate = logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();
    for (var i in logs) {
      var w = handleWeightData(i.metadata);
      double correctedW;

      // convert between lbs and kg
      if (i.weightPost == "lbs") {
        if (isLbs) {
          correctedW = w;
        } else {
          correctedW = w / 2.205;
        }
      } else {
        if (isLbs) {
          correctedW = w * 2.205;
        } else {
          correctedW = w;
        }
      }

      if (correctedW > wMax) {
        wMax = correctedW;
      }
      if (correctedW < wMin) {
        wMin = correctedW;
      }
      // var r = i.metadata.map((e) => e.reps).toList().reduce((a, b) => a + b);
      var begin = DateTime(beginDate.year);
      spots.add(FlSpot(
          i.getCreated().difference(begin).inDays.toDouble(), correctedW));
      wDates.add(i.getCreatedFormatted());
    }
    wData = spots.reversed.toList();
    wDates = wDates.reversed.toList();
  }

  double handleWeightData(
    List<ExerciseLogMeta> metadata,
  ) {
    switch (accumulateType) {
      case AccumulateType.avg:
        return metadata.map((e) => e.weight).toList().reduce((a, b) => a + b) /
            metadata.length;
      case AccumulateType.max:
        return metadata
            .map((e) => e.weight)
            .toList()
            .reduce((a, b) => max(a, b))
            .toDouble();
      case AccumulateType.min:
        return metadata
            .map((e) => e.weight)
            .toList()
            .reduce((a, b) => min(a, b))
            .toDouble();
    }
  }
}

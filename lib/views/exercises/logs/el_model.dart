import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/utils/root.dart';

class ELModel extends ChangeNotifier {
  late Exercise exercise;
  List<ExerciseLog> logs = [];

  List<FlSpot> wData = [];
  List<String> wDates = [];
  double wMax = 0;
  double wMin = double.infinity;
  int wPage = 1;
  int wPageSize = 3;

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
    if (wData.length <= wPageSize * wPage) {
      return wDates;
    } else {
      var start = wDates.length - (wPageSize * wPage);
      return wDates.sublist(start, wData.length - (wPageSize * (wPage - 1)));
    }
  }

  void createWeightData() {
    List<FlSpot> spots = [];
    // get the furthest back date
    DateTime beginDate = logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();
    for (var i in logs) {
      var w = i.metadata.map((e) => e.weight).toList().reduce((a, b) => a + b) /
          i.metadata.length;
      // TODO: -- parse from kg to lbs
      if (w > wMax) {
        wMax = w;
      }
      if (w < wMin) {
        wMin = w;
      }
      // var r = i.metadata.map((e) => e.reps).toList().reduce((a, b) => a + b);
      var begin = DateTime(beginDate.year);
      spots.add(FlSpot(i.getCreated().difference(begin).inDays.toDouble(), w));
      wDates.add(i.getCreatedFormatted());
    }
    wData = spots;
  }
}

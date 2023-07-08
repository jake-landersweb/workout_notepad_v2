import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_base.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

import 'package:workout_notepad_v2/utils/root.dart';

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

  ELModel({required this.exercise}) {
    pageController = PageController();
    init();
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    // get logs
    logs = await exercise.getLogs(exercise.exerciseId);
    // create dashboard data from these logs
    await compose();
    isLoading = false;
    notifyListeners();
    // wait a small bit for log tags to finish fetching
    await Future.delayed(const Duration(milliseconds: 200));
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

enum BarDataType { weight, reps }

class GraphDataItem {
  late double low;
  late List<double> items;
  late double high;

  GraphDataItem({
    required this.low,
    required this.items,
    required this.high,
  });

  double get avg => items.reduce((a, b) => a + b) / items.length;
}

class BarDataModel extends ChangeNotifier {
  // List<GraphDataItem> items = [];
  double low = double.infinity;
  double high = double.negativeInfinity;
  BarDataType type = BarDataType.weight;

  BarDataModel({required ELModel elmodel});

  void toggleType(ELModel elmodel) {
    switch (type) {
      case BarDataType.weight:
        type = BarDataType.reps;
        break;
      case BarDataType.reps:
        type = BarDataType.weight;
        break;
      default:
    }
    notifyListeners();
  }

  String get titleButton {
    switch (type) {
      case BarDataType.weight:
        return "Weight";
      case BarDataType.reps:
        return "Reps";
    }
  }

  String titleType(ELModel elmodel) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        return "";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return "Time";
      case ExerciseType.bw:
        return "Reps";
    }
  }

  String barY(ELModel elmodel, double val) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        switch (type) {
          case BarDataType.weight:
            return "${val.toStringAsFixed(2)} ${elmodel.weightPost}";
          case BarDataType.reps:
            return "${val.round()} Reps";
        }
      case ExerciseType.timed:
      case ExerciseType.duration:
        return formatHHMMSS(val.round());
      case ExerciseType.bw:
        return "${val.toStringAsFixed(2)} Reps";
    }
  }

  String tooltip(ELModel elmodel, double val, int set, int group) {
    String g = "";
    switch (group) {
      case 0:
        g = "Low";
        break;
      case 1:
        g = "Avg";
        break;
      case 2:
        g = "High";
        break;
    }
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        switch (type) {
          case BarDataType.weight:
            return "${val.toStringAsFixed(2)} ${elmodel.weightPost}\n#${set + 1} $g";
          case BarDataType.reps:
            return "${val.toStringAsFixed(2)} Reps\n#${set + 1} $g";
        }
      case ExerciseType.timed:
      case ExerciseType.duration:
        return "${formatHHMMSS(val.round())}\n#${set + 1} $g";
      case ExerciseType.bw:
        return "${val.toStringAsFixed(2)} Reps\n#${set + 1} $g";
    }
  }

  List<GraphDataItem> getItems(ELModel elmodel) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        switch (type) {
          case BarDataType.weight:
            return createWeightData(elmodel.logs, elmodel.isLbs);
          case BarDataType.reps:
            return createRepsData(elmodel.logs);
        }
      case ExerciseType.timed:
      case ExerciseType.duration:
        return createTimeData(elmodel.logs);
      case ExerciseType.bw:
        return createRepsData(elmodel.logs);
    }
  }

  List<GraphDataItem> createWeightData(List<ExerciseLog> logs, bool isLbs) {
    List<GraphDataItem> items = [];
    high = double.negativeInfinity;
    low = double.infinity;
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            GraphDataItem(
              low: double.infinity,
              items: [],
              high: double.negativeInfinity,
            ),
          );
        }
        var adjustedWeight =
            _getAdjustedWeight(log, log.metadata[i].weight, isLbs);
        // set min and max
        items[i].high = max(items[i].high, adjustedWeight);
        items[i].low = min(items[i].low, adjustedWeight);
        high = max(high, adjustedWeight);
        low = min(low, adjustedWeight);
        // add to running count
        items[i].items.add(adjustedWeight);
      }
    }
    return items;
  }

  List<GraphDataItem> createRepsData(List<ExerciseLog> logs) {
    List<GraphDataItem> items = [];
    high = double.negativeInfinity;
    low = double.infinity;
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            GraphDataItem(
              low: double.infinity,
              items: [],
              high: double.negativeInfinity,
            ),
          );
        }

        // set min and max
        items[i].high = max(items[i].high, log.metadata[i].reps.toDouble());
        items[i].low = min(items[i].low, log.metadata[i].reps.toDouble());
        high = max(high, items[i].high);
        low = min(low, items[i].low);
        // add to running count
        items[i].items.add(log.metadata[i].reps.toDouble());
      }
    }
    return items;
  }

  List<GraphDataItem> createTimeData(List<ExerciseLog> logs) {
    List<GraphDataItem> items = [];
    high = double.negativeInfinity;
    low - double.infinity;
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            GraphDataItem(
              low: double.infinity,
              items: [],
              high: double.negativeInfinity,
            ),
          );
        }

        // set min and max
        if (log.metadata[i].time > items[i].high) {
          items[i].high = log.metadata[i].time.toDouble();
        }
        if (log.metadata[i].time < items[i].low) {
          items[i].low = log.metadata[i].time.toDouble();
        }
        // add to running count
        items[i].items.add(log.metadata[i].time.toDouble());
      }
    }
    return items;
  }

  List<BarChartGroupData> getBarData(BuildContext context, ELModel elmodel) {
    List<BarChartGroupData> data = [];
    List<GraphDataItem> items = getItems(elmodel);
    for (int i = 0; i < items.length; i++) {
      data.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: items[i].low.toDouble(),
              color: i % 2 == 0
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : AppColors.cell(context),
              width: ((MediaQuery.of(context).size.width / items.length) / 3) -
                  (36 / items.length),
            ),
            BarChartRodData(
              toY: items[i].avg,
              color: i % 2 == 0
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : AppColors.cell(context),
              width: ((MediaQuery.of(context).size.width / items.length) / 3) -
                  (36 / items.length),
            ),
            BarChartRodData(
              toY: items[i].high.toDouble(),
              color: i % 2 == 0
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                  : AppColors.cell(context),
              width: ((MediaQuery.of(context).size.width / items.length) / 3) -
                  (36 / items.length),
            ),
          ],
        ),
      );
    }
    return data;
  }
}

class LineDataModel extends ChangeNotifier {
  late List<String> dates;
  double low = double.infinity;
  double high = double.negativeInfinity;
  AccumulateType accumulateType = AccumulateType.avg;

  LineDataModel({required ELModel elmodel}) {
    // create date vector
    dates = elmodel.logs.map((e) => e.getCreatedFormatted()).toList();

    // create low and high
    for (var i in elmodel.logs) {
      for (var m in i.metadata) {
        switch (elmodel.exercise.type) {
          case ExerciseType.weight:
            var adjustedWeight = _getAdjustedWeight(i, m.weight, elmodel.isLbs);
            high = max(high, adjustedWeight);
            low = min(low, adjustedWeight);
            break;
          case ExerciseType.timed:
          case ExerciseType.duration:
            high = max(high, m.time.toDouble());
            low = min(low, m.time.toDouble());
            break;
          case ExerciseType.bw:
            high = max(high, m.reps.toDouble());
            low = min(low, m.reps.toDouble());
        }
      }
    }
  }

  List<FlSpot> getItems(ELModel elmodel) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        return createWeightData(elmodel);
      case ExerciseType.timed:
      case ExerciseType.duration:
        return createTimeData(elmodel);
      case ExerciseType.bw:
        return createRepsData(elmodel);
    }
  }

  String barY(ELModel elmodel, double val) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        return "${val.toStringAsFixed(2)} ${elmodel.weightPost}";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return formatHHMMSS(val.round());
      case ExerciseType.bw:
        return "${val.toStringAsFixed(2)} Reps";
    }
  }

  String tooltip(ELModel elmodel, double val, int index) {
    switch (elmodel.exercise.type) {
      case ExerciseType.weight:
        return "${val.toStringAsFixed(2)} ${elmodel.weightPost}\n${dates[index]}";
      case ExerciseType.timed:
      case ExerciseType.duration:
        return "${formatHHMMSS(val.round())}\n${dates[index]}";
      case ExerciseType.bw:
        return "${val.toStringAsFixed(2)} Reps\n${dates[index]}";
    }
  }

  List<FlSpot> createWeightData(ELModel elmodel) {
    List<FlSpot> items = [];
    // get the furthest back date
    DateTime beginDate = elmodel.logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();

    for (var i in elmodel.logs) {
      // handle max and min
      var scaledWeight = accumulateData(
          i.metadata.map((e) => e.weight.toDouble()).toList(), accumulateType);
      var adjustedWeight = _getAdjustedWeight(i, scaledWeight, elmodel.isLbs);

      var begin = DateTime(beginDate.year);
      items.add(FlSpot(
          i.getCreated().difference(begin).inDays.toDouble(), adjustedWeight));
    }
    return items;
  }

  List<FlSpot> createRepsData(ELModel elmodel) {
    List<FlSpot> items = [];
    // get the furthest back date
    DateTime beginDate = elmodel.logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();

    for (var i in elmodel.logs) {
      // handle max and min
      var scaledReps = accumulateData(
          i.metadata.map((e) => e.reps.toDouble()).toList(), accumulateType);

      var begin = DateTime(beginDate.year);
      items.add(FlSpot(
          i.getCreated().difference(begin).inDays.toDouble(), scaledReps));
    }
    return items;
  }

  List<FlSpot> createTimeData(ELModel elmodel) {
    List<FlSpot> items = [];
    // get the furthest back date
    DateTime beginDate = elmodel.logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();

    for (var i in elmodel.logs) {
      // handle max and min
      var scaledTime = accumulateData(
          i.metadata.map((e) => e.time.toDouble()).toList(), accumulateType);

      var begin = DateTime(beginDate.year);
      items.add(FlSpot(
          i.getCreated().difference(begin).inDays.toDouble(), scaledTime));
    }
    return items;
  }

  /// composes the datapoint for the specified day using an accumulate method
  double accumulateData(
    List<double> list,
    AccumulateType type,
  ) {
    switch (type) {
      case AccumulateType.avg:
        return list.reduce((a, b) => a + b) / list.length;
      case AccumulateType.max:
        return list.reduce((a, b) => max(a, b)).toDouble();
      case AccumulateType.min:
        return list.reduce((a, b) => min(a, b)).toDouble();
    }
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
    notifyListeners();
  }
}

/// Account for logs being represented in kg or lbs
double _getAdjustedWeight(ExerciseLog log, num val, bool isLbs) {
  if (log.weightPost == "lbs") {
    if (isLbs) {
      return val.toDouble();
    } else {
      return val / 2.205;
    }
  } else {
    if (isLbs) {
      return val * 2.205;
    } else {
      return val.toDouble();
    }
  }
}

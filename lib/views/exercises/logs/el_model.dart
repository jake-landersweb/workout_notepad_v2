import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';

import 'package:workout_notepad_v2/utils/root.dart';

enum AccumulateType { avg, max, min }

enum TimeType { sec, min, hour }

enum DistributionBarType { weight, reps }

class ELModel extends ChangeNotifier {
  late Exercise exercise;
  List<ExerciseLog> logs = [];
  late PageController pageController;
  late int currentIndex;
  LineData? lineData;
  BarData barData = BarData();

  bool _isLbs = true;
  bool get isLbs => _isLbs;
  void toggleIsLbs() {
    _isLbs = !_isLbs;
    setData(logs);
    notifyListeners();
  }

  late TimeType _timeType;
  TimeType get timeType => _timeType;
  void toggleTimeType() {
    switch (_timeType) {
      case TimeType.sec:
        _timeType = TimeType.min;
        break;
      case TimeType.min:
        _timeType = TimeType.hour;
        break;
      case TimeType.hour:
        _timeType = TimeType.min;
        break;
    }
    notifyListeners();
  }

  int _page = 1;
  int get page => _page;
  int _pageSize = 5;
  int get pageSize => _pageSize;
  void setPageSize(int s) {
    _pageSize = s;
    notifyListeners();
  }

  DistributionBarType _distributionBarType = DistributionBarType.weight;
  DistributionBarType get distributionBarType => _distributionBarType;
  void toggleDistributionBarType() {
    if (_distributionBarType == DistributionBarType.weight) {
      _distributionBarType = DistributionBarType.reps;
      barData.createRepsData(logs);
    } else {
      _distributionBarType = DistributionBarType.weight;
      barData.createWeightData(logs, isLbs);
    }
    notifyListeners();
  }

  ELModel({
    required this.exercise,
  }) {
    currentIndex = 0;
    pageController = PageController(initialPage: currentIndex);
    switch (exercise.timePost) {
      case "sec":
        _timeType = TimeType.sec;
        break;
      case "min":
        _timeType = TimeType.min;
        break;
      default:
        _timeType = TimeType.hour;
        break;
    }
    init();
  }

  Future<void> init() async {
    logs = await exercise.getLogs(exercise.exerciseId);
    setData(logs);
  }

  void setData(List<ExerciseLog> l) {
    lineData = LineData.init(exercise.type);
    barData = BarData();
    switch (exercise.type) {
      case 1:
      case 2:
        lineData!.createTimedData(logs, timeType);
        barData.createTimeData(logs, timeType);
        break;
      default:
        lineData!.createWeightData(l, isLbs);
        barData.createWeightData(logs, isLbs);
        break;
    }
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

  void nextPage() {
    if (lineData == null) {
      return;
    }
    if (lineData!.spots.length - (pageSize * page) > 0) {
      _page += 1;
    }
    notifyListeners();
  }

  void wPrevPage() {
    if (page > 1) {
      _page -= 1;
    }
    notifyListeners();
  }

  List<FlSpot> getLineData() {
    if (lineData == null) {
      return [];
    }
    return paginate(lineData!.spots) as List<FlSpot>;
  }

  List<String> getLineDates() {
    if (lineData == null) {
      return [];
    }
    return paginate(lineData!.dates) as List<String>;
  }

  /// paginate the log data for the graph view
  List<dynamic> paginate(List<dynamic> input) {
    if (input.length <= pageSize) {
      return input;
    } else {
      var start = input.length - (pageSize * page);
      if (start < 0) {
        start = 0;
      }
      return input.sublist(start, start + pageSize);
    }
  }

  String getPost() {
    switch (exercise.type) {
      case 1:
      case 2:
        return _timeType.name;
      default:
        return isLbs ? "lbs" : "kg";
    }
  }

  String getBarTitle() {
    switch (exercise.type) {
      case 1:
      case 2:
        return "Time";
      default:
        switch (distributionBarType) {
          case DistributionBarType.weight:
            return "Weight";
          case DistributionBarType.reps:
            return "Reps";
        }
    }
  }

  String getDistributionPost() {
    switch (exercise.type) {
      case 1:
      case 2:
        return _timeType.name;
      default:
        switch (distributionBarType) {
          case DistributionBarType.weight:
            return getPost();
          case DistributionBarType.reps:
            return "Reps";
        }
    }
  }
}

class BarDataItem {
  late double low;
  late List<double> items;
  late double high;

  BarDataItem({
    required this.low,
    required this.items,
    required this.high,
  });

  double get avg => items.reduce((a, b) => a + b) / items.length;
}

class BarData {
  List<BarDataItem> items = [];

  void createWeightData(List<ExerciseLog> logs, bool isLbs) {
    items = [];
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            BarDataItem(
              low: 9999999,
              items: [],
              high: -9999999,
            ),
          );
        }
        var adjustedWeight =
            _getAdjustedWeight(log, log.metadata[i].weight.toDouble(), isLbs);
        // set min and max
        if (adjustedWeight > items[i].high) {
          items[i].high = adjustedWeight;
        }
        if (adjustedWeight < items[i].low) {
          items[i].low = adjustedWeight;
        }
        // add to running count
        items[i].items.add(adjustedWeight);
      }
    }
  }

  void createRepsData(List<ExerciseLog> logs) {
    items = [];
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            BarDataItem(
              low: 9999999,
              items: [],
              high: -9999999,
            ),
          );
        }

        // set min and max
        if (log.metadata[i].reps > items[i].high) {
          items[i].high = log.metadata[i].reps.toDouble();
        }
        if (log.metadata[i].reps < items[i].low) {
          items[i].low = log.metadata[i].reps.toDouble();
        }
        // add to running count
        items[i].items.add(log.metadata[i].reps.toDouble());
      }
    }
  }

  void createTimeData(List<ExerciseLog> logs, TimeType timeType) {
    items = [];
    // create the weight items
    for (var log in logs) {
      for (int i = 0; i < log.metadata.length; i++) {
        // add the item
        if (i >= items.length) {
          items.add(
            BarDataItem(
              low: 9999999,
              items: [],
              high: -9999999,
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
  }

  List<BarChartGroupData> getBarData(BuildContext context) {
    List<BarChartGroupData> data = [];
    for (int i = 0; i < items.length; i++) {
      data.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: items[i].low.toDouble(),
              color: Theme.of(context).colorScheme.secondary,
              width: ((MediaQuery.of(context).size.width / items.length) / 3) -
                  (36 / items.length),
            ),
            BarChartRodData(
              toY: items[i].avg,
              color: Theme.of(context).colorScheme.primary,
              width: ((MediaQuery.of(context).size.width / items.length) / 3) -
                  (36 / items.length),
            ),
            BarChartRodData(
              toY: items[i].high.toDouble(),
              color: Theme.of(context).colorScheme.tertiary,
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

class LineData {
  late List<FlSpot> spots;
  late List<String> dates;
  late double graphLow;
  late double graphHigh;
  late double setLow;
  late double setHigh;
  late AccumulateType accumulateType;
  late int type;

  LineData({
    required this.spots,
    required this.dates,
    required this.graphLow,
    required this.graphHigh,
    required this.setLow,
    required this.setHigh,
    required this.accumulateType,
    required this.type,
  });

  LineData.init(this.type) {
    spots = [];
    dates = [];
    graphLow = double.infinity;
    graphHigh = double.negativeInfinity;
    setLow = double.infinity;
    setHigh = double.negativeInfinity;
    accumulateType = AccumulateType.avg;
  }

  String setLowFormatted() {
    if (setLow == double.infinity) {
      return "-";
    } else {
      return setLow.toStringAsFixed(2);
    }
  }

  String setHighFormatted() {
    if (setHigh == double.negativeInfinity) {
      return "-";
    } else {
      return setHigh.toStringAsFixed(2);
    }
  }

  void init(List<ExerciseLog> logs, bool isLbs, TimeType timeType) {
    switch (type) {
      case 1:
      case 2:
        break;
      default:
        createWeightData(logs, isLbs);
    }
  }

  void createWeightData(List<ExerciseLog> logs, bool isLbs) {
    spots = [];
    dates = [];
    graphLow = double.infinity;
    graphHigh = double.negativeInfinity;
    setLow = double.infinity;
    setHigh = double.negativeInfinity;

    // get the furthest back date
    DateTime beginDate = logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();
    for (var i in logs) {
      // handle max and min over all sets
      var tmpMax = _getAdjustedWeight(
          i, handleWeightData(i.metadata, AccumulateType.max), isLbs);
      var tmpMin = _getAdjustedWeight(
          i, handleWeightData(i.metadata, AccumulateType.min), isLbs);
      if (tmpMax > setHigh) {
        setHigh = tmpMax;
      }
      if (tmpMin < setLow) {
        setLow = tmpMin;
      }

      // compose log data
      var w = handleWeightData(i.metadata, accumulateType);
      double correctedW = _getAdjustedWeight(i, w, isLbs);

      if (correctedW > graphHigh) {
        graphHigh = correctedW;
      }
      if (correctedW < graphLow) {
        graphLow = correctedW;
      }
      // var r = i.metadata.map((e) => e.reps).toList().reduce((a, b) => a + b);
      var begin = DateTime(beginDate.year);
      spots.add(FlSpot(
          i.getCreated().difference(begin).inDays.toDouble(), correctedW));
      dates.add(i.getCreatedFormatted());
    }

    // reverse to maintain order
    spots = spots.reversed.toList();
    dates = dates.reversed.toList();
  }

  void createTimedData(List<ExerciseLog> logs, TimeType timeType) {
    spots = [];
    dates = [];
    graphLow = double.infinity;
    graphHigh = double.negativeInfinity;
    setLow = double.infinity;
    setHigh = double.negativeInfinity;

    // get the furthest back date
    DateTime beginDate = logs
        .reduce((a, b) => a.getCreated().isAfter(b.getCreated()) ? b : a)
        .getCreated();
    for (var i in logs) {
      // handle max and min over all sets
      var tmpMax = _getAdjustedTime(
          i, handleTimeData(i.metadata, AccumulateType.max), timeType);
      var tmpMin = _getAdjustedTime(
          i, handleTimeData(i.metadata, AccumulateType.min), timeType);
      if (tmpMax > setHigh) {
        setHigh = tmpMax;
      }
      if (tmpMin < setLow) {
        setLow = tmpMin;
      }

      // compose log data
      double t = _getAdjustedTime(
          i, handleTimeData(i.metadata, accumulateType), timeType);

      if (t > graphHigh) {
        graphHigh = t;
      }
      if (t < graphLow) {
        graphLow = t;
      }
      // var r = i.metadata.map((e) => e.reps).toList().reduce((a, b) => a + b);
      var begin = DateTime(beginDate.year);
      spots.add(FlSpot(i.getCreated().difference(begin).inDays.toDouble(), t));
      dates.add(i.getCreatedFormatted());
    }

    // reverse to maintain order
    spots = spots.reversed.toList();
    dates = dates.reversed.toList();
  }

  /// composes the datapoint for the specified day using an accumulate method
  double handleWeightData(
    List<ExerciseLogMeta> metadata,
    AccumulateType type,
  ) {
    switch (type) {
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

  /// composes the datapoint for the specified day using an accumulate method
  double handleTimeData(
    List<ExerciseLogMeta> metadata,
    AccumulateType type,
  ) {
    switch (type) {
      case AccumulateType.avg:
        return metadata.map((e) => e.time).toList().reduce((a, b) => a + b) /
            metadata.length;
      case AccumulateType.max:
        return metadata
            .map((e) => e.time)
            .toList()
            .reduce((a, b) => max(a, b))
            .toDouble();
      case AccumulateType.min:
        return metadata
            .map((e) => e.time)
            .toList()
            .reduce((a, b) => min(a, b))
            .toDouble();
    }
  }

  void toggleAccumulate(List<ExerciseLog> logs, bool isLbs, TimeType timeType) {
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
    init(logs, isLbs, timeType);
  }
}

/// Account for logs being represented in kg or lbs
double _getAdjustedWeight(ExerciseLog log, double val, bool isLbs) {
  if (log.weightPost == "lbs") {
    if (isLbs) {
      return val;
    } else {
      return val / 2.205;
    }
  } else {
    if (isLbs) {
      return val * 2.205;
    } else {
      return val;
    }
  }
}

double _getAdjustedTime(ExerciseLog log, double val, TimeType timeType) {
  switch (timeType) {
    case TimeType.sec:
      switch (log.timePost) {
        case "sec":
          return val;
        case "min":
          return val / 60;
        default:
          return val / 60 / 60;
      }
    case TimeType.min:
      switch (log.timePost) {
        case "sec":
          return val * 60;
        case "min":
          return val;
        default:
          return val / 60;
      }
    case TimeType.hour:
      switch (log.timePost) {
        case "sec":
          return val * 60 * 60;
        case "min":
          return val * 60;
        default:
          return val;
      }
  }
}

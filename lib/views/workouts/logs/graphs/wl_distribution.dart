import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/components/timer.dart';
import 'package:workout_notepad_v2/data/exercise_log.dart';
import 'package:workout_notepad_v2/data/query_model.dart';
import 'package:workout_notepad_v2/data/workout_log.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class WLDistribution extends StatelessWidget {
  WLDistribution({super.key, required this.workoutLogId});
  final String workoutLogId;

  final _weightColor = Colors.green[400]!;
  final _repsColor = Colors.purple[300]!;
  final _timeColor = Colors.amber[700]!;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<QueryModel>().getWorkoutLog(workoutLogId),
      builder: (context, snapshot) {
        // check for stream error
        if (snapshot.hasError) {
          logger.error("Stream error:",
              {"error": snapshot.error, "stackTrace": snapshot.stackTrace});
          return Center(
            child: Text("Uh oh! Stream Error: ${snapshot.error}"),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting ||
            (snapshot.hasData &&
                snapshot.data?.data == null &&
                snapshot.data?.error == null)) {
          return const Center(child: LoadingIndicator());
        }

        // Error getting the actual data packet
        if (snapshot.hasData && snapshot.data?.error != null) {
          return Center(
            child: Text("Uh oh! Issue: ${snapshot.data!.error}"),
          );
        }

        // success case
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.data != null) {
          var data = snapshot.data!.data!; // Now this should be safe
          return _weightBySet(context, data.v1, data.v2);
        }

        logger.error(
            "Unexpected state or no data. Displaying loading as fallback.");
        return const Center(child: LoadingIndicator());
      },
    );
  }

  List<int> _getWeightDistribution(
      BuildContext context, List<List<ExerciseLog>> logs) {
    var localPrefs = context.read<LocalPrefs>();

    List<int> wd = [];

    for (var i in logs) {
      var weight = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            if (localPrefs.defaultWeightPost == "lbs") {
              weight += (j.metadata.map((e) => e.weight).sum * 2.2).toInt();
            } else {
              weight += j.metadata.map((e) => e.weight).sum;
            }
          } else {
            if (localPrefs.defaultWeightPost == "lbs") {
              weight += j.metadata.map((e) => e.weight).sum;
            } else {
              weight += (j.metadata.map((e) => e.weight).sum / 2.2).toInt();
            }
          }
        }
      }
      wd.add(weight);
    }

    return wd;
  }

  List<int> _getRepsDistribution(List<List<ExerciseLog>> logs) {
    List<int> rd = [];

    for (var i in logs) {
      var reps = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            reps += j.metadata.map((e) => e.reps).sum;
          } else {
            reps += j.metadata.map((e) => e.reps).sum;
          }
        }
      }
      rd.add(reps);
    }

    return rd;
  }

  List<int> _getTimeDistribution(List<List<ExerciseLog>> logs) {
    List<int> td = [];

    for (var i in logs) {
      var time = 0;
      for (var j in i) {
        // total weight
        if (j.metadata.isNotEmpty) {
          if (j.metadata[0].weightPost == "kg") {
            time += j.metadata.map((e) => e.time).sum;
          } else {
            time += j.metadata.map((e) => e.time).sum;
          }
        }
      }
      td.add(time);
    }

    return td;
  }

  // Function to normalize a list of integers to a list of doubles (0-1 range)
  List<double> _normalizeIntegerList(List<int> numbers) {
    if (numbers.isEmpty) {
      return []; // Return an empty list if the input is empty
    }

    // Find the minimum and maximum values in the list
    // We can do this with a simple loop or using reduce.
    // Loop approach (often clearer for beginners and handles single element lists well):
    int minVal = numbers[0];
    int maxVal = numbers[0];

    for (int i = 1; i < numbers.length; i++) {
      if (numbers[i] < minVal) {
        minVal = numbers[i];
      }
      if (numbers[i] > maxVal) {
        maxVal = numbers[i];
      }
    }

    // Alternative using reduce (requires 'dart:math' and list must not be empty):
    // if (numbers.isEmpty) return []; // Handled above
    // int minVal = numbers.reduce(min);
    // int maxVal = numbers.reduce(max);

    // Handle the case where all numbers are the same (to avoid division by zero)
    if (minVal == maxVal) {
      // If all numbers are the same, they are all "normalized" to 0.0
      // (or 0.5, or 1.0 depending on convention, 0.0 is common if there's no spread)
      return List<double>.filled(numbers.length, 0.0);
    }

    // Calculate the range
    double range = (maxVal - minVal).toDouble();

    // Normalize each number and add to the new list
    List<double> normalizedList = [];
    for (int value in numbers) {
      double normalizedValue = (value - minVal) / range;
      normalizedList.add(normalizedValue);
    }

    // More concise way using map:
    // return numbers.map((value) => (value - minVal) / range).toList();

    return normalizedList;
  }

  Widget _weightBySet(
    BuildContext context,
    WorkoutLog log,
    List<List<ExerciseLog>> logs,
  ) {
    var localPrefs = context.watch<LocalPrefs>();
    var wd = _getWeightDistribution(context, logs);
    var wdNormalized = _normalizeIntegerList(wd);
    var rd = _getRepsDistribution(logs);
    var rdNormalized = _normalizeIntegerList(rd);
    var td = _getTimeDistribution(logs);
    var tdNormalized = _normalizeIntegerList(td);
    Widget content = Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  if (wd.reduce((a, b) => a + b) > 0)
                    LineChartBarData(
                      barWidth: 3,
                      color: _weightColor,
                      isCurved: true,
                      preventCurveOverShooting: false,
                      curveSmoothness: 0.2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (p0, p1, p2, p3) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _weightColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      spots: [
                        for (int i = 0; i < wd.length; i++)
                          FlSpot(i + 1, wdNormalized[i].toDouble())
                      ],
                    ),
                  if (rd.reduce((a, b) => a + b) > 0)
                    LineChartBarData(
                      barWidth: 3,
                      color: _repsColor,
                      isCurved: true,
                      preventCurveOverShooting: false,
                      curveSmoothness: 0.2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (p0, p1, p2, p3) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _repsColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      spots: [
                        for (int i = 0; i < rd.length; i++)
                          FlSpot(i + 1, rdNormalized[i].toDouble())
                      ],
                    ),
                  if (td.reduce((a, b) => a + b) > 0)
                    LineChartBarData(
                      barWidth: 3,
                      color: _timeColor,
                      isCurved: true,
                      preventCurveOverShooting: false,
                      curveSmoothness: 0.2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (p0, p1, p2, p3) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _timeColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      spots: [
                        for (int i = 0; i < td.length; i++)
                          FlSpot(i + 1, tdNormalized[i].toDouble())
                      ],
                    ),
                ],
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipColor: (spot) {
                      return AppColors.cell(context);
                    },
                    getTooltipItems: (touchedSpots) {
                      List<LineTooltipItem> items = [];
                      for (int i = 0; i < touchedSpots.length; i++) {
                        String text = "";
                        if (i == 0) {
                          text += "Set #${touchedSpots[i].x.round()}\n";
                        }

                        final String colorString =
                            touchedSpots[i].bar.color!.toString();

                        if (colorString == _weightColor.toString()) {
                          text +=
                              "${wd[touchedSpots[i].spotIndex]} ${localPrefs.defaultWeightPost}";
                        } else if (colorString == _repsColor.toString()) {
                          text += "${rd[touchedSpots[i].spotIndex]} Reps";
                        } else if (colorString == _timeColor.toString()) {
                          text += formatHHMMSS(td[touchedSpots[i].spotIndex]);
                        }

                        items.add(
                          LineTooltipItem(
                            text,
                            ttBody(
                              context,
                              color: touchedSpots[i].bar.color,
                            ),
                          ),
                        );
                      }
                      return items;
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  leftTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.round() != value) {
                          return Container();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            value.round().toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.subtext(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (wd.reduce((a, b) => a + b) > 0)
              _barLegendItem(context, "Weight", _weightColor),
            if (rd.reduce((a, b) => a + b) > 0)
              _barLegendItem(context, "Reps", _repsColor),
            if (td.reduce((a, b) => a + b) > 0)
              _barLegendItem(context, "Time", _timeColor),
          ],
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: content),
      ],
    );
  }

  Widget _barLegendItem(
    BuildContext context,
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          height: 7,
          width: 7,
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 50,
          child: Text(title,
              style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
